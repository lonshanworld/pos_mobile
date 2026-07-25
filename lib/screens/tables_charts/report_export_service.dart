import 'dart:typed_data';

import 'package:excel_plus/excel_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:pos_mobile/blocs/item_bloc/item_cubit.dart';
import 'package:pos_mobile/blocs/transactions_bloc/transactions_cubit.dart';
import 'package:pos_mobile/blocs/shop_info_bloc/shop_info_cubit.dart';
import 'package:pos_mobile/models/item_model_folder/item_model.dart';
import 'package:pos_mobile/models/transaction_model_folder/stockout_model_folder/stock_out_model.dart';
import 'package:pos_mobile/utils/formula.dart';
import 'package:pos_mobile/services/public_document_storage.dart';

import 'report_export_dialog.dart';

enum ReportExportType { transactions, daily, weekly, monthly }

class ReportExportService {
  ReportExportService._();

  static final _dateTimeFormat = DateFormat('dd-MMM-yyyy HH:mm');
  static final _dateFormat = DateFormat('dd-MMM-yyyy');
  static final _monthFormat = DateFormat('MMMM-yyyy');

  static Future<void> requestExport({
    required BuildContext context,
    required ReportExportType type,
  }) async {
    final transactions = context
        .read<TransactionsCubit>()
        .state
        .activeStockOutList;
    if (transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('There is no sales data to export.')),
      );
      return;
    }
    final sorted = [...transactions]
      ..sort((a, b) => a.createTime.compareTo(b.createTime));
    final range = await showDialog<DateTimeRange>(
      context: context,
      builder: (_) => ReportDateRangeDialog(
        initialRange: DateTimeRange(
          start: sorted.first.createTime,
          end: sorted.last.createTime.isAfter(sorted.first.createTime)
              ? sorted.last.createTime
              : sorted.first.createTime.add(const Duration(minutes: 1)),
        ),
      ),
    );
    if (range == null || !context.mounted) return;
    try {
      final path = await export(context: context, type: type, range: range);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Excel report saved: $path')));
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Export failed: $error')));
    }
  }

  static Future<String> export({
    required BuildContext context,
    required ReportExportType type,
    required DateTimeRange range,
  }) async {
    final transactions =
        context
            .read<TransactionsCubit>()
            .state
            .activeStockOutList
            .where(
              (transaction) =>
                  !transaction.createTime.isBefore(range.start) &&
                  !transaction.createTime.isAfter(range.end),
            )
            .toList()
          ..sort((a, b) => b.createTime.compareTo(a.createTime));
    final itemModels = [
      ...context.read<ItemCubit>().state.activeItemList,
      ...context.read<ItemCubit>().state.inActiveItemList,
    ];

    final excel = Excel.createExcel();
    final sheetName = _sheetName(type);
    // Rename the default sheet instead of creating a second sheet and
    // deleting the default. This keeps the workbook's relationships intact.
    excel.rename('Sheet1', sheetName);
    final sheet = excel[sheetName];

    final rows = _rows(type, transactions, itemModels, context);
    sheet.appendRow([TextCellValue(_title(type))]);
    sheet.appendRow([
      TextCellValue(
        'Range: ${_dateTimeFormat.format(range.start)} - ${_dateTimeFormat.format(range.end)}',
      ),
    ]);
    sheet.appendRow(rows.headers.map(TextCellValue.new).toList());
    for (final row in rows.data) {
      sheet.appendRow(row.map(_cellValue).toList());
    }

    _styleSheet(sheet, rows.headers.length, rows.data.length + 3);
    final bytes = excel.save();
    if (bytes == null) throw StateError('Could not create Excel file.');

    final fileName =
        '${_filePrefix(type)}_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}';
    return PublicDocumentStorage.saveBytes(
      fileName: '$fileName.xlsx',
      directory: 'reports',
      bytes: Uint8List.fromList(bytes),
    );
  }

  static _ExportRows _rows(
    ReportExportType type,
    List<StockOutModel> transactions,
    List<ItemModel> itemModels,
    BuildContext context,
  ) {
    switch (type) {
      case ReportExportType.transactions:
        return _transactionRows(transactions, itemModels, context);
      case ReportExportType.daily:
        return _summaryRows(_groupByDay(transactions), 'Date', context);
      case ReportExportType.weekly:
        return _summaryRows(_groupByWeek(transactions), 'Week', context);
      case ReportExportType.monthly:
        return _summaryRows(_groupByMonth(transactions), 'Month', context);
    }
  }

  static _ExportRows _transactionRows(
    List<StockOutModel> transactions,
    List<ItemModel> itemModels,
    BuildContext context,
  ) {
    final headers = [
      'No.',
      'Date',
      'Code',
      'Item Name',
      'Item Count',
      'Original Price',
      'Sell Price',
      'Final Sell Price',
      'Profit',
      'Shopping Type',
      'Payment Method',
      'Delivery Charges',
    ];
    final taxVisible =
        context.read<ShopInfoCubit>().state.taxEnabled &&
        context.read<ShopInfoCubit>().state.checkoutTaxEnabled;
    if (taxVisible) headers.insert(headers.length - 1, 'Tax');
    final data = <List<Object?>>[];
    final cubit = context.read<TransactionsCubit>();
    for (var index = 0; index < transactions.length; index++) {
      final transaction = transactions[index];
      final items = cubit.getSelectedStockOutItemList(transaction.id);
      final names = <String>[];
      final counts = <int>[];
      var original = 0.0;
      var finalSell = 0.0;
      for (final item in items) {
        final model = itemModels
            .where((model) => model.id == item.itemId)
            .firstOrNull;
        names.add(model?.name ?? 'Unknown');
        counts.add(item.count);
        original += item.originalPrice * item.count;
        finalSell += item.finalSellPrice * item.count;
      }
      final delivery = transaction.deliveryModelId == null
          ? 0.0
          : cubit
                    .getDeliveryModel(transaction.deliveryModelId!)
                    ?.deliveryCharges ??
                0.0;
      final tax = taxVisible
          ? CalculationFormula.getPercentageToMMK(
              finalSell,
              transaction.taxPercentage ?? 0,
            )
          : 0.0;
      final row = <Object?>[
        index + 1,
        _dateTimeFormat.format(transaction.createTime),
        transaction.code,
        names.isEmpty ? '-' : names.join(', '),
        counts.isEmpty ? '-' : counts.join(', '),
        original,
        finalSell,
        transaction.finalTotalPrice,
        transaction.finalTotalPrice - delivery - tax - original,
        transaction.shoppingType.name.toUpperCase(),
        transaction.paymentMethod.name.toUpperCase(),
        delivery,
      ];
      if (taxVisible) row.insert(row.length - 1, tax);
      data.add(row);
    }
    return _ExportRows(headers, data);
  }

  static _ExportRows _summaryRows(
    Map<String, List<StockOutModel>> groups,
    String periodLabel,
    BuildContext context,
  ) {
    final headers = [
      'No.',
      periodLabel,
      'Original Price',
      'Sell Price',
      'Final Sell Price',
      'Profit',
    ];
    final data = <List<Object?>>[];
    var index = 1;
    for (final entry in groups.entries) {
      var original = 0.0;
      var sell = 0.0;
      var finalSell = 0.0;
      for (final transaction in entry.value) {
        final items = context
            .read<TransactionsCubit>()
            .getSelectedStockOutItemList(transaction.id);
        original += items.fold(
          0.0,
          (sum, item) => sum + item.originalPrice * item.count,
        );
        sell += items.fold(
          0.0,
          (sum, item) => sum + item.finalSellPrice * item.count,
        );
        final delivery = transaction.deliveryModelId == null
            ? 0.0
            : context
                      .read<TransactionsCubit>()
                      .getDeliveryModel(transaction.deliveryModelId!)
                      ?.deliveryCharges ??
                  0.0;
        finalSell += transaction.finalTotalPrice - delivery;
      }
      data.add([
        index++,
        entry.key,
        original,
        sell,
        finalSell,
        finalSell - original,
      ]);
    }
    return _ExportRows(headers, data);
  }

  static Map<String, List<StockOutModel>> _groupByDay(
    List<StockOutModel> list,
  ) => _group(
    list,
    (date) => DateTime(date.year, date.month, date.day),
    (date) => _dateFormat.format(date),
  );

  static Map<String, List<StockOutModel>> _groupByWeek(
    List<StockOutModel> list,
  ) => _group(
    list,
    (date) {
      final day = DateTime(date.year, date.month, date.day);
      return day.subtract(Duration(days: day.weekday - 1));
    },
    (date) =>
        '${_dateFormat.format(date)} - ${_dateFormat.format(date.add(const Duration(days: 6)))}',
  );

  static Map<String, List<StockOutModel>> _groupByMonth(
    List<StockOutModel> list,
  ) => _group(
    list,
    (date) => DateTime(date.year, date.month),
    (date) => _monthFormat.format(date),
  );

  static Map<String, List<StockOutModel>> _group(
    List<StockOutModel> list,
    DateTime Function(DateTime) keyDate,
    String Function(DateTime) label,
  ) {
    final grouped = <DateTime, List<StockOutModel>>{};
    for (final transaction in list) {
      grouped
          .putIfAbsent(keyDate(transaction.createTime), () => [])
          .add(transaction);
    }
    final keys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    return {for (final key in keys) label(key): grouped[key]!};
  }

  static void _styleSheet(Sheet sheet, int columnCount, int rowCount) {
    sheet.merge(
      CellIndex.indexByString('A1'),
      CellIndex.indexByColumnRow(columnIndex: columnCount - 1, rowIndex: 0),
    );
    final titleStyle = CellStyle(bold: true, fontSize: 14);
    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#E5D5EF'),
    );
    sheet.cell(CellIndex.indexByString('A1')).cellStyle = titleStyle;
    for (var column = 0; column < columnCount; column++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: column, rowIndex: 2),
      );
      cell.cellStyle = headerStyle;
      sheet.setColumnWidth(column, column == 3 ? 28 : 18);
    }
  }

  static CellValue _cellValue(Object? value) {
    if (value is int) return IntCellValue(value);
    if (value is num) return DoubleCellValue(value.toDouble());
    return TextCellValue(value?.toString() ?? '');
  }

  static String _title(ReportExportType type) => switch (type) {
    ReportExportType.transactions => 'Per Transaction Sales Report',
    ReportExportType.daily => 'Daily Sales Report',
    ReportExportType.weekly => 'Weekly Sales Report',
    ReportExportType.monthly => 'Monthly Sales Report',
  };

  static String _sheetName(ReportExportType type) => switch (type) {
    ReportExportType.transactions => 'Per Transaction',
    ReportExportType.daily => 'Daily',
    ReportExportType.weekly => 'Weekly',
    ReportExportType.monthly => 'Monthly',
  };

  static String _filePrefix(ReportExportType type) =>
      _sheetName(type).toLowerCase().replaceAll(' ', '_');
}

class _ExportRows {
  final List<String> headers;
  final List<List<Object?>> data;

  const _ExportRows(this.headers, this.data);
}

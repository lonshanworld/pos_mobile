import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:excel_plus/excel_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pos_mobile/blocs/item_bloc/item_cubit.dart';
import 'package:pos_mobile/blocs/transactions_bloc/transactions_cubit.dart';
import 'package:pos_mobile/blocs/shop_info_bloc/shop_info_cubit.dart';
import 'package:pos_mobile/utils/formula.dart';
import 'package:pos_mobile/services/public_document_storage.dart';

import '../../../screens/tables_charts/report_export_dialog.dart';

class StockInExportService {
  StockInExportService._();

  static final _dateTimeFormat = DateFormat('dd-MMM-yyyy HH:mm');
  static final _dateFormat = DateFormat('dd-MMM-yyyy');
  static final _timeFormat = DateFormat('HH:mm');

  static Future<void> requestExport(BuildContext context) async {
    final stockIns = context.read<TransactionsCubit>().state.activeStockInList;
    if (stockIns.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('There is no stock-in data to export.')),
      );
      return;
    }

    final sorted = [...stockIns]
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
      final path = await _export(context, range);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stock-in Excel report saved: $path')),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Stock-in export failed: $error')));
    }
  }

  static Future<String> _export(
    BuildContext context,
    DateTimeRange range,
  ) async {
    final stockIns =
        context
            .read<TransactionsCubit>()
            .state
            .activeStockInList
            .where(
              (stockIn) =>
                  !stockIn.createTime.isBefore(range.start) &&
                  !stockIn.createTime.isAfter(range.end),
            )
            .toList()
          ..sort((a, b) => b.createTime.compareTo(a.createTime));

    final itemCubit = context.read<ItemCubit>();
    final itemModels = [
      ...itemCubit.state.activeItemList,
      ...itemCubit.state.inActiveItemList,
    ];
    final uniqueItems = [
      ...itemCubit.state.activeUniqueItemList,
      ...itemCubit.state.inActiveUniqueItemList,
    ];
    final itemTaxVisible =
        context.read<ShopInfoCubit>().state.taxEnabled &&
        context.read<ShopInfoCubit>().state.itemTaxEnabled;

    final excel = Excel.createExcel();
    excel.rename('Sheet1', 'Stock-In History');
    final sheet = excel['Stock-In History'];
    const headers = [
      'No.',
      'Stock-In ID',
      'Code',
      'Date',
      'Time',
      'Item Name',
      'Quantity',
      'Unit Original Price',
      'Unit Sell Price',
      'Original Price',
      'Sell Price',
    ];

    sheet.appendRow([TextCellValue('Stock-In History Report')]);
    sheet.appendRow([
      TextCellValue(
        'Range: ${_dateTimeFormat.format(range.start)} - ${_dateTimeFormat.format(range.end)}',
      ),
    ]);
    sheet.appendRow(headers.map(TextCellValue.new).toList());

    var rowNumber = 1;
    for (final stockIn in stockIns) {
      final selected = uniqueItems
          .where((unique) => unique.stockInId == stockIn.id)
          .toList();
      final grouped = groupBy(
        selected,
        (unique) =>
            '${unique.itemId}|${unique.originalPrice}|${unique.profitPrice}|${itemTaxVisible ? unique.taxPercentage : 0}',
      );

      for (final entry in grouped.entries) {
        final units = entry.value;
        final itemId = units.first.itemId;
        final unitOriginalPrice = units.first.originalPrice;
        final unitSellPrice = CalculationFormula.getItemSellPrice(
          originalPrice: units.first.originalPrice,
          profitPrice: units.first.profitPrice,
          taxPercentage: itemTaxVisible ? units.first.taxPercentage : 0,
        );
        final item = itemModels.firstWhereOrNull((item) => item.id == itemId);
        final originalPrice = units.fold<double>(
          0,
          (sum, unit) => sum + unit.originalPrice,
        );
        final sellPrice = units.fold<double>(
          0,
          (sum, unit) =>
              sum +
              CalculationFormula.getItemSellPrice(
                originalPrice: unit.originalPrice,
                profitPrice: unit.profitPrice,
                taxPercentage: itemTaxVisible ? unit.taxPercentage : 0,
              ),
        );
        sheet.appendRow([
          IntCellValue(rowNumber++),
          IntCellValue(stockIn.id),
          TextCellValue(stockIn.code),
          TextCellValue(_dateFormat.format(stockIn.createTime)),
          TextCellValue(_timeFormat.format(stockIn.createTime)),
          TextCellValue(item?.name ?? 'Unknown'),
          IntCellValue(units.length),
          DoubleCellValue(unitOriginalPrice),
          DoubleCellValue(unitSellPrice),
          DoubleCellValue(originalPrice),
          DoubleCellValue(sellPrice),
        ]);
      }
    }

    final titleStyle = CellStyle(bold: true, fontSize: 14);
    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#E5D5EF'),
    );
    sheet.merge(
      CellIndex.indexByString('A1'),
      CellIndex.indexByColumnRow(columnIndex: headers.length - 1, rowIndex: 0),
    );
    sheet.cell(CellIndex.indexByString('A1')).cellStyle = titleStyle;
    for (var column = 0; column < headers.length; column++) {
      sheet
              .cell(
                CellIndex.indexByColumnRow(columnIndex: column, rowIndex: 2),
              )
              .cellStyle =
          headerStyle;
      sheet.setColumnWidth(column, column == 4 ? 28 : 18);
    }

    final bytes = excel.save();
    if (bytes == null) throw StateError('Could not create Excel file.');
    return PublicDocumentStorage.saveBytes(
      fileName:
          '${'stock_in_history_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}'}.xlsx',
      directory: 'reports',
      bytes: Uint8List.fromList(bytes),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_mobile/constants/uiConstants.dart';
import 'package:pos_mobile/widgets/cusTxt_widget.dart';

class TablesAndCharts {
  final BuildContext context;
  static final NumberFormat _numFormat = NumberFormat('#,##0.##');

  TablesAndCharts({required this.context});

  static String formatNum(double value) => _numFormat.format(value);

  DataCell normalDataCell(String txt) {
    return DataCell(
      CusTxtWidget(
        txtStyle: Theme.of(context).textTheme.bodyMedium!,
        txt: txt == "null" ? "- -" : txt,
      ),
      placeholder: true,
    );
  }

  DataCell sellPriceDataCell({
    required String formattedValue,
    required bool isLow,
  }) {
    return DataCell(
      CusTxtWidget(
        txtStyle: Theme.of(
          context,
        ).textTheme.bodyMedium!.copyWith(color: isLow ? Colors.red : null),
        txt: formattedValue,
      ),
      placeholder: true,
    );
  }

  DataCell profitDataCell({required double profitPrice}) {
    return DataCell(
      Container(
        padding: const EdgeInsets.symmetric(
          vertical: UIConstants.smallSpace,
          horizontal: UIConstants.mediumSpace,
        ),
        decoration: BoxDecoration(
          color: profitPrice == 0
              ? Colors.transparent
              : profitPrice < 0
              ? Colors.red.withValues(alpha: 0.4)
              : Colors.green.withValues(alpha: 0.4),
          borderRadius: UIConstants.smallBorderRadius,
        ),
        child: CusTxtWidget(
          txtStyle: Theme.of(context).textTheme.bodyMedium!,
          txt: formatNum(profitPrice),
        ),
      ),
    );
  }

  DataColumn tableTitle(String txt) {
    return DataColumn(
      label: CusTxtWidget(
        txt: txt,
        txtStyle: Theme.of(
          context,
        ).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMultilineCell({
    required List<String> values,
    TextStyle? style,
    int? maxVisibleValues,
  }) {
    final effectiveStyle = (style ?? Theme.of(context).textTheme.bodySmall!)
        .copyWith(height: 0.9);
    final List<String> visibleValues =
        maxVisibleValues == null || maxVisibleValues >= values.length
        ? values
        : values.take(maxVisibleValues).toList();
    final int remainingCount = values.length - visibleValues.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ...visibleValues.map(
          (value) => Text(
            value,
            style: effectiveStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (remainingCount > 0)
          Text(
            "+$remainingCount more",
            style: effectiveStyle.copyWith(color: Colors.grey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  DataCell multilineDataCell({
    required List<String> values,
    TextStyle? style,
    int? maxVisibleValues,
  }) {
    return DataCell(
      _buildMultilineCell(
        values: values,
        style: style,
        maxVisibleValues: maxVisibleValues,
      ),
      placeholder: true,
    );
  }

  DataRow transactionDataRow({
    required int index,
    required String dateTxt,
    required List<String> itemNames,
    required List<String> itemCounts,
    required List<String> originalPrices,
    required List<String> sellPrices,
    required String finalSellPrice,
    required String profit,
    required bool isEven,
    required VoidCallback onCheckDetail,
    int? maxVisibleValues,
  }) {
    return DataRow(
      color: WidgetStateProperty.resolveWith(
        (_) =>
            isEven ? Colors.grey.withValues(alpha: 0.07) : Colors.transparent,
      ),
      cells: [
        DataCell(
          CusTxtWidget(
            txtStyle: Theme.of(context).textTheme.bodyMedium!,
            txt: index.toString(),
          ),
        ),
        DataCell(
          CusTxtWidget(
            txtStyle: Theme.of(context).textTheme.bodyMedium!,
            txt: dateTxt,
          ),
        ),
        multilineDataCell(
          values: itemNames,
          maxVisibleValues: maxVisibleValues,
        ),
        multilineDataCell(
          values: itemCounts,
          maxVisibleValues: maxVisibleValues,
        ),
        multilineDataCell(
          values: originalPrices,
          maxVisibleValues: maxVisibleValues,
        ),
        multilineDataCell(
          values: sellPrices,
          maxVisibleValues: maxVisibleValues,
        ),
        DataCell(
          CusTxtWidget(
            txtStyle: Theme.of(context).textTheme.bodyMedium!,
            txt: finalSellPrice,
          ),
        ),
        DataCell(
          CusTxtWidget(
            txtStyle: Theme.of(context).textTheme.bodyMedium!,
            txt: profit,
          ),
        ),
        DataCell(
          ElevatedButton(
            onPressed: onCheckDetail,
            child: const Text("Check Detail"),
          ),
        ),
      ],
    );
  }

  DataRow dataRow({
    required int index,
    required String txt,
    required double originalPrice,
    required double sellPrice,
    required double finalSellPrice,
    required double profit,
    required bool isEven,
  }) {
    return DataRow(
      color: WidgetStateProperty.resolveWith(
        (_) =>
            isEven ? Colors.grey.withValues(alpha: 0.07) : Colors.transparent,
      ),
      cells: [
        normalDataCell(index.toString()),
        normalDataCell(txt),
        normalDataCell(formatNum(originalPrice)),
        sellPriceDataCell(
          formattedValue: formatNum(sellPrice),
          isLow: sellPrice < originalPrice,
        ),
        sellPriceDataCell(
          formattedValue: formatNum(finalSellPrice),
          isLow: finalSellPrice < originalPrice,
        ),
        profitDataCell(profitPrice: profit),
      ],
    );
  }
}

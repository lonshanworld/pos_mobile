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
        txtStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: isLow ? Colors.red : null,
        ),
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
        txtStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
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
        (_) => isEven ? Colors.grey.withValues(alpha: 0.07) : Colors.transparent,
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
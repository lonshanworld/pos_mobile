import 'package:flutter/material.dart';
import 'package:pos_mobile/constants/uiConstants.dart';
import 'package:pos_mobile/widgets/cusTxt_widget.dart';

class TablesAndCharts{
  final BuildContext context;
  TablesAndCharts({
    required this.context,
  });

  DataCell normalDataCell(String txt){
    return DataCell(
      CusTxtWidget(
        txtStyle:Theme.of(context).textTheme.bodyMedium!,
        txt: txt == "null" ? "- -" : txt,
      ),
      placeholder: true,
    );
  }

  DataCell sellPriceDataCell({
    required double sellPrice,
    required double originalPrice,
  }){
    return DataCell(
      CusTxtWidget(
        txtStyle:Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: sellPrice < originalPrice ? Colors.red : Theme.of(context).textTheme.bodyMedium!.color
        ),
        txt: sellPrice.toString(),
      ),
      placeholder: true,
    );
  }

  DataCell profitDataCell({
    required double profitPrice,
  }){
    // return DataCell(
    //   CusTxtWidget(
    //     txtStyle:Theme.of(context).textTheme.bodyMedium!.copyWith(
    //       color: profitPrice == 0 ? Theme.of(context).textTheme.bodyMedium!.color : profitPrice < 0 ? Colors.red : Colors.green ,
    //     ),
    //     txt: profitPrice.toString(),
    //   ),
    //   placeholder: true,
    // );
    return DataCell(
      Container(

        padding: const EdgeInsets.symmetric(
          vertical: UIConstants.smallSpace,
          horizontal: UIConstants.mediumSpace,
        ),
        decoration: BoxDecoration(
          color: profitPrice == 0 ? Colors.transparent : profitPrice < 0 ? Colors.red.withOpacity(0.4) : Colors.green.withOpacity(0.4),
          borderRadius: UIConstants.smallBorderRadius,
        ),
        child: CusTxtWidget(
          txtStyle:Theme.of(context).textTheme.bodyMedium!,
          txt: profitPrice.toString(),
        ),
      ),
    );
  }

  DataColumn tableTitle(String txt){
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
  }){
    return DataRow(
      cells: [
        normalDataCell(index.toString()),
        normalDataCell(txt),
        normalDataCell(originalPrice.toString()),
        sellPriceDataCell(sellPrice: sellPrice, originalPrice: originalPrice),
        sellPriceDataCell(sellPrice: finalSellPrice, originalPrice: originalPrice),
        profitDataCell(profitPrice: profit),
      ]
    );
  }
}
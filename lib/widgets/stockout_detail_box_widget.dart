import 'package:flutter/material.dart';
import 'package:pos_mobile/constants/uiConstants.dart';
import 'package:pos_mobile/widgets/cusTxt_widget.dart';
import 'package:pos_mobile/widgets/index_box_widget.dart';

class StockOutDetailBoxWidget extends StatelessWidget {

  final String index;
  final String itemName;
  final String count;
  final String sellPrice;
  final String finalSellPrice;
  final String totalPrice;
  const StockOutDetailBoxWidget({
    super.key,
    required this.itemName,
    required this.count,
    required this.sellPrice,
    required this.finalSellPrice,
    required this.totalPrice,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {

    Widget nameBox(){
      return CusTxtWidget(
        txtStyle: Theme.of(context).textTheme.bodyMedium!,
        txt: itemName,
      );
    }

    Widget numBox(String value){
      return CusTxtWidget(
        txtStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
          fontWeight: FontWeight.bold,
        ),
        txt: value,
      );
    }

    Widget finalBox(){
      return IndexBoxWidget(index: totalPrice);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: UIConstants.smallSpace
      ),
      child: Row(
        children: [
          numBox("$index."),
          Expanded(
            flex: 6,
            child: Column(
              children: [
                nameBox(),
                numBox(sellPrice),
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: numBox(finalSellPrice),
          ),
          Expanded(
            flex: 2,
            child: numBox(count),
          ),

          Expanded(
            flex: 5,
            child: finalBox(),
          ),
        ],
      ),
    );
  }
}

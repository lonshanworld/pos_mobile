import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:pos_mobile/blocs/promotion_bloc/promotion_cubit.dart";
import "package:pos_mobile/utils/formula.dart";

import "../../feature/printer_font_changer.dart";
import "../../models/item_model_folder/item_model.dart";
import "../../models/item_model_folder/uniqueItem_model.dart";
import "../../models/promotion_model_folder/promotion_model.dart";

class VoucherTable extends StatelessWidget {

  final List<ItemModel> itemModelList;
  final List<UniqueItemModel> uniqueItemList;
  const VoucherTable({
    super.key,
    required this.itemModelList,
    required this.uniqueItemList,
  });

  @override
  Widget build(BuildContext context) {
    final PrinterFontChanger printerFontChanger = PrinterFontChanger.instance;

    return Table(
      columnWidths: const {
        0 : FlexColumnWidth(8),
        1 : FlexColumnWidth(2),
        2 : FlexColumnWidth(5),
      },
      children: itemModelList.map((e){
        final List<UniqueItemModel> newList = [];
        final PromotionModel? promotionData = context.read<PromotionCubit>().getSinglePromotionFromItemId(e.id);
        for(int i = 0; i < uniqueItemList.length; i++){
          if(uniqueItemList[i].itemId == e.id){
            newList.add(uniqueItemList[i]);
          }
        }
        return TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 3,
              ),
              child: Text(
                e.name,
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Colors.black,
                  fontSize: printerFontChanger.printerFontSize,
                ),
              ),
            ),
            Text(
              "${newList.length}",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Colors.black,
                fontSize: printerFontChanger.printerFontSize,
              ),
            ),
            Text(
              "${(CalculationFormula.getItemAfterPromotionPrice(
                sellPrice: CalculationFormula.getItemSellPrice(
                  originalPrice: e.originalPrice,
                  profitPrice: e.profitPrice,
                  taxPercentage: e.taxPercentage ?? 0,
                ),
                promotionPrice: promotionData == null ? 0 : promotionData.promotionPrice,
                promotionPercentage: promotionData == null ? 0 : promotionData.promotionPercentage,
              ) * newList.length)}",
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Colors.black,
                fontSize: printerFontChanger.printerFontSize,
              ),
            ),
          ]
        );
      }).toList(),
    );
  }
}

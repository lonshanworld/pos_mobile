import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:pos_mobile/blocs/promotion_bloc/promotion_cubit.dart";
import "package:pos_mobile/blocs/shop_info_bloc/shop_info_cubit.dart";
import "package:pos_mobile/blocs/item_bloc/item_cubit.dart";
import "package:pos_mobile/features/printer_font_changer.dart";
import "package:pos_mobile/utils/checkout_helpers.dart";

import "../../constants/enums.dart";
import "../../models/item_model_folder/item_model.dart";
import "../../models/item_model_folder/uniqueItem_model.dart";
import "../../models/promotion_model_folder/promotion_model.dart";
import "../../widgets/checkout_line_detail.dart";

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
    final BusinessType businessType =
        context.watch<ShopInfoCubit>().state.businessType;
    final itemCubit = context.read<ItemCubit>();

    TextStyle cellStyle(BuildContext ctx) =>
        Theme.of(ctx).textTheme.bodyMedium!.copyWith(
              color: Colors.black,
              fontSize: printerFontChanger.printerFontSize,
            );

    TextStyle detailStyle(BuildContext ctx) =>
        Theme.of(ctx).textTheme.bodySmall!.copyWith(
              color: Colors.black87,
              fontSize: printerFontChanger.printerFontSize * 0.85,
            );

    final bool perUnitLines = businessType == BusinessType.clothing ||
        businessType == BusinessType.basicPharmacy ||
        businessType == BusinessType.grocery;

    if (perUnitLines && uniqueItemList.isNotEmpty) {
      return Table(
        columnWidths: const {
          0: FlexColumnWidth(8),
          1: FlexColumnWidth(2),
          2: FlexColumnWidth(5),
        },
        children: uniqueItemList.map((unit) {
          ItemModel? item;
          for (final candidate in itemModelList) {
            if (candidate.id == unit.itemId) {
              item = candidate;
              break;
            }
          }
          final name = item?.name ?? 'Item #${unit.itemId}';
          final promotion = context
              .read<PromotionCubit>()
              .getSinglePromotionFromItemId(unit.itemId);
          final detail = itemCubit.getBusinessDetail(unit.itemId);
          final lineTotal = CheckoutHelpers.uniqueItemPriceAfterPromotion(
            unit,
            promotion,
          );

          return TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: cellStyle(context)),
                    CheckoutUnitDetailText(
                      businessType: businessType,
                      unit: unit,
                      itemDetail: detail,
                      style: detailStyle(context),
                    ),
                  ],
                ),
              ),
              Text('1', textAlign: TextAlign.center, style: cellStyle(context)),
              Text(
                lineTotal.toStringAsFixed(0),
                textAlign: TextAlign.end,
                style: cellStyle(context),
              ),
            ],
          );
        }).toList(),
      );
    }

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(8),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(5),
      },
      children: itemModelList.map((e) {
        final List<UniqueItemModel> newList = [];
        final PromotionModel? promotionData =
            context.read<PromotionCubit>().getSinglePromotionFromItemId(e.id);
        final detail = itemCubit.getBusinessDetail(e.id);
        for (int i = 0; i < uniqueItemList.length; i++) {
          if (uniqueItemList[i].itemId == e.id) {
            newList.add(uniqueItemList[i]);
          }
        }

        double lineTotal = 0;
        for (final unit in newList) {
          lineTotal += CheckoutHelpers.uniqueItemPriceAfterPromotion(
            unit,
            promotionData,
          );
        }

        final subtitle = detail?.summaryLines(businessType).join(' · ');

        return TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.name, style: cellStyle(context)),
                  if (subtitle != null && subtitle.isNotEmpty)
                    Text(subtitle, style: detailStyle(context)),
                ],
              ),
            ),
            Text(
              '${newList.length}',
              textAlign: TextAlign.center,
              style: cellStyle(context),
            ),
            Text(
              lineTotal.toStringAsFixed(0),
              textAlign: TextAlign.end,
              style: cellStyle(context),
            ),
          ],
        );
      }).toList(),
    );
  }
}

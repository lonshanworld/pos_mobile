import 'package:flutter/material.dart';
import 'package:pos_mobile/constants/enums.dart';
import 'package:pos_mobile/constants/uiConstants.dart';
import 'package:pos_mobile/controller/ui_controller.dart';
import 'package:pos_mobile/models/item_model_folder/item_business_detail_model.dart';
import 'package:pos_mobile/models/item_model_folder/uniqueItem_model.dart';
import 'package:pos_mobile/utils/checkout_helpers.dart';
import 'package:pos_mobile/widgets/business_type_selector.dart';

/// Item-level business chips for checkout product tiles.
class CheckoutItemDetailChips extends StatelessWidget {
  final BusinessType businessType;
  final ItemBusinessDetailModel? detail;

  const CheckoutItemDetailChips({
    super.key,
    required this.businessType,
    this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return BusinessItemDetailChips(
      businessType: businessType,
      detail: detail,
      maxLines: 2,
    );
  }
}

/// Per-unit subtitle (size, batch, expiry) on checkout tiles and receipt lines.
class CheckoutUnitDetailText extends StatelessWidget {
  final BusinessType businessType;
  final UniqueItemModel unit;
  final ItemBusinessDetailModel? itemDetail;
  final TextStyle? style;

  const CheckoutUnitDetailText({
    super.key,
    required this.businessType,
    required this.unit,
    this.itemDetail,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final lines = CheckoutHelpers.unitDetailLines(
      businessType: businessType,
      unit: unit,
      itemDetail: itemDetail,
    );
    if (lines.isEmpty) return const SizedBox.shrink();

    final accent = UIController.instance.accentColor();
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        lines.join(' · '),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: style ??
            Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: accent.withValues(alpha: 0.85),
                  fontSize: 10,
                ),
      ),
    );
  }
}

/// Cart summary chip showing what's in cart for this item.
class CheckoutCartUnitSummary extends StatelessWidget {
  final BusinessType businessType;
  final List<UniqueItemModel> cartUnitsForItem;
  final Map<int, ItemBusinessDetailModel?> detailByItemId;

  const CheckoutCartUnitSummary({
    super.key,
    required this.businessType,
    required this.cartUnitsForItem,
    required this.detailByItemId,
  });

  @override
  Widget build(BuildContext context) {
    if (cartUnitsForItem.isEmpty) return const SizedBox.shrink();

    final accent = UIController.instance.accentColor();
    return Container(
      margin: const EdgeInsets.only(top: UIConstants.smallSpace),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: UIConstants.smallBorderRadius,
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: cartUnitsForItem.take(3).map((unit) {
          final lines = CheckoutHelpers.unitDetailLines(
            businessType: businessType,
            unit: unit,
            itemDetail: detailByItemId[unit.itemId],
          );
          final price =
              CheckoutHelpers.uniqueItemSellPrice(unit).toStringAsFixed(0);
          final label = lines.isEmpty
              ? '$price MMK'
              : '${lines.first} — $price MMK';
          return Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
          );
        }).toList(),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../constants/enums.dart';
import '../../../models/item_model_folder/item_model.dart';
import '../../../models/item_model_folder/uniqueItem_model.dart';
import '../../../models/promotion_model_folder/promotion_model.dart';
import '../../../widgets/voucher_box_widget.dart';

/// A readable, phone-width version of the checkout voucher.
///
/// The voucher itself is intentionally the same widget used by the drawer so
/// that the customer sees exactly the same invoice in both places.
class VoucherFullViewScreen extends StatelessWidget {
  final String? customerName;
  final String? deliveryName;
  final List<UniqueItemModel> selectedUniqueItemList;
  final List<ItemModel> selectedItemModelList;
  final ShoppingType shoppingType;
  final PaymentMethod paymentMethod;
  final double? additionalPromotionAmount;
  final double? deliCharges;
  final String? description;
  final String barCode;
  final double taxPercentage;
  final PromotionModel? promotionModel;
  final DateTime checkoutTime;
  final bool showAdditionalPromotion;

  const VoucherFullViewScreen({
    super.key,
    required this.customerName,
    required this.deliveryName,
    required this.selectedUniqueItemList,
    required this.selectedItemModelList,
    required this.shoppingType,
    required this.paymentMethod,
    required this.additionalPromotionAmount,
    required this.deliCharges,
    required this.description,
    required this.barCode,
    required this.taxPercentage,
    required this.promotionModel,
    required this.checkoutTime,
    required this.showAdditionalPromotion,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voucher / Invoice - Preview')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Keep the invoice phone-like on tablets while using the available
          // width on smaller phones.
          final width = constraints.maxWidth < 420
              ? constraints.maxWidth
              : 420.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: SizedBox(
                width: width,
                child: VoucherBox(
                  customerName: customerName,
                  deliveryName: deliveryName,
                  selectedUniqueItemList: selectedUniqueItemList,
                  selectedItemModelList: selectedItemModelList,
                  shoppingType: shoppingType,
                  paymentMethod: paymentMethod,
                  additionalPromotionAmount: additionalPromotionAmount,
                  deliCharges: deliCharges,
                  description: description,
                  barCode: barCode,
                  taxPercentage: taxPercentage,
                  promotionModel: promotionModel,
                  orderDateTime: checkoutTime,
                  showAdditionalPromotion: showAdditionalPromotion,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

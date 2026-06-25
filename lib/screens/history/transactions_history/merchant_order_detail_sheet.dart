import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import 'package:pos_mobile/blocs/shop_info_bloc/shop_info_cubit.dart';
import 'package:pos_mobile/blocs/transactions_bloc/transactions_cubit.dart';
import 'package:pos_mobile/blocs/promotion_bloc/promotion_cubit.dart';
import 'package:pos_mobile/models/promotion_model_folder/promotion_model.dart';
import 'package:pos_mobile/constants/enums.dart';
import 'package:pos_mobile/constants/uiConstants.dart';
import 'package:pos_mobile/models/transaction_model_folder/stockout_model_folder/stock_out_item_model.dart';
import 'package:pos_mobile/models/transaction_model_folder/stockout_model_folder/stock_out_model.dart';
import 'package:pos_mobile/models/item_model_folder/uniqueItem_model.dart';
import 'package:pos_mobile/utils/checkout_helpers.dart';
import 'package:pos_mobile/utils/formula.dart';
import 'package:pos_mobile/widgets/btns_folder/leadingBackIconBtn.dart';
import 'package:pos_mobile/widgets/business_type_selector.dart';
import 'package:pos_mobile/widgets/cusTxt_widget.dart';
import 'package:pos_mobile/widgets/dividers/cus_divider_widget.dart';
import 'package:pos_mobile/models/item_model_folder/item_model.dart';
import 'package:pos_mobile/blocs/item_bloc/item_cubit.dart';

class MerchantOrderDetailSheet extends StatelessWidget {
  final StockOutModel stockOutModel;

  const MerchantOrderDetailSheet({
    super.key,
    required this.stockOutModel,
  });

  @override
  Widget build(BuildContext context) {
    final BusinessType businessType =
        context.watch<ShopInfoCubit>().state.businessType;
    final ItemCubit itemCubit = context.read<ItemCubit>();

    final List<StockOutItemModel> selectedStockOutItemList =
        context.read<TransactionsCubit>().getSelectedStockOutItemList(stockOutModel.id);

    final List<UniqueItemModel> soldUnits =
        itemCubit.getSelectedUniqueItemFromStockOutId(stockOutModel.id);

    final List<ItemModel> allItemList = [
      ...context.select((ItemCubit cubit) => cubit.state.activeItemList),
      ...context.select((ItemCubit cubit) => cubit.state.inActiveItemList),
    ];

    final double totalOrgPrice =
        CalculationFormula.getItemTotalOriginalPriceForStockOut(
            selectedStockOutItemList);
    final double totalItemFinalSellPrices =
        CalculationFormula.getItemTotalFinalSellPriceForStockOut(
            selectedStockOutItemList);

    final double finalprice = stockOutModel.finalTotalPrice;
    final double orderTax = CalculationFormula.getPercentageToMMK(
        totalItemFinalSellPrices, stockOutModel.taxPercentage ?? 0);

    final deliveryModel = stockOutModel.deliveryModelId == null
        ? null
        : context
            .read<TransactionsCubit>()
            .getDeliveryModel(stockOutModel.deliveryModelId!);
    final double deliCharges = deliveryModel?.deliveryCharges ?? 0;

    final stockOutPromo = context
        .read<PromotionCubit>()
        .state
        .stockOutPromotionList
        .firstWhereOrNull((e) => e.stockOutId == stockOutModel.id);
    PromotionModel? orderPromotion;
    if (stockOutPromo != null) {
      orderPromotion = context
              .read<PromotionCubit>()
              .state
              .activePromotionList
              .firstWhereOrNull((e) => e.id == stockOutPromo.promotionId) ??
          context
              .read<PromotionCubit>()
              .state
              .inActivePromotionList
              .firstWhereOrNull((e) => e.id == stockOutPromo.promotionId);
    }

    double orderPromoAmount = 0;
    String? orderPromotionValue;
    if (orderPromotion != null) {
      if (orderPromotion.promotionPercentage != null) {
        orderPromotionValue =
            '${orderPromotion.promotionPercentage!.toStringAsFixed(0)}%';
        orderPromoAmount = CalculationFormula.getPercentageToMMK(
            totalItemFinalSellPrices + orderTax,
            orderPromotion.promotionPercentage!);
      } else if (orderPromotion.promotionPrice != null) {
        orderPromotionValue =
            '${orderPromotion.promotionPrice!.toStringAsFixed(0)} MMK';
        orderPromoAmount = orderPromotion.promotionPrice!;
      }
    }

    final double profit = finalprice - deliCharges - orderTax - totalOrgPrice;

    final bool showUnitBreakdown = businessType == BusinessType.clothing ||
        businessType == BusinessType.basicPharmacy ||
        businessType == BusinessType.grocery;

    Widget dataRow(String title, String value,
        {bool isBold = false, Color? titleColor, Color? valueColor}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 5,
              child: CusTxtWidget(
                txt: title,
                txtStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                      color: titleColor ?? Colors.grey.shade600,
                    ),
                textAlign: TextAlign.start,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 5,
              child: CusTxtWidget(
                txt: value,
                txtStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                      color: valueColor,
                    ),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: const CusLeadingBackIconBtn(),
        title: const Text('Order Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(UIConstants.mediumSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CusTxtWidget(
              txt: 'Order Details',
              txtStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: UIConstants.mediumSpace),
            Container(
              padding: const EdgeInsets.all(UIConstants.mediumSpace),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: UIConstants.smallBorderRadius,
                border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  dataRow('Transaction ID', stockOutModel.code),
                  dataRow('Shopping Type',
                      stockOutModel.shoppingType.name.toUpperCase()),
                  dataRow('Payment Method',
                      stockOutModel.paymentMethod.name.toUpperCase()),
                  const SizedBox(height: 8),
                  const CusDividerWidget(clr: Colors.grey),
                  const SizedBox(height: 8),
                  dataRow('Total Original (Cost)', '$totalOrgPrice MMK'),
                  dataRow('Total Sold Value (Items)',
                      '$totalItemFinalSellPrices MMK'),
                  dataRow('Checkout Tax', '$orderTax MMK'),
                  dataRow('Delivery Charges', '$deliCharges MMK'),
                  if (orderPromotion != null) ...[
                    dataRow('Order Promotion', orderPromotion.promotionName),
                    if (orderPromotionValue != null)
                      dataRow('Promotion Value', orderPromotionValue),
                  ],
                  if (orderPromoAmount > 0)
                    dataRow('Order Promotion applied',
                        '-${orderPromoAmount.toStringAsFixed(0)} MMK',
                        valueColor: Colors.red),
                  if (stockOutModel.additionalPromotionAmount != null)
                    dataRow('Checkout Additional Promo',
                        '-${stockOutModel.additionalPromotionAmount} MMK',
                        valueColor: Colors.red),
                  const SizedBox(height: 8),
                  const CusDividerWidget(clr: Colors.grey),
                  const SizedBox(height: 8),
                  dataRow('Total Final Paid', '$finalprice MMK',
                      isBold: true, valueColor: Colors.blue.shade700),
                  dataRow('Total Pure Profit', '$profit MMK',
                      isBold: true,
                      valueColor:
                          profit >= 0 ? Colors.green.shade700 : Colors.red.shade700),
                ],
              ),
            ),
            const SizedBox(height: UIConstants.bigSpace),
            CusTxtWidget(
              txt: 'Item Breakdown',
              txtStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: UIConstants.mediumSpace),
            if (showUnitBreakdown && soldUnits.isNotEmpty) ...[
              ...soldUnits.map((unit) {
                final ItemModel? singleItem =
                    allItemList.firstWhereOrNull((e) => e.id == unit.itemId);
                final detail = itemCubit.getBusinessDetail(unit.itemId);
                final promotion = context
                    .read<PromotionCubit>()
                    .getSinglePromotionFromItemId(unit.itemId);
                final unitSell = CheckoutHelpers.uniqueItemSellPrice(unit);
                final unitFinal = CheckoutHelpers.uniqueItemPriceAfterPromotion(
                  unit,
                  promotion,
                );
                final parts = CheckoutHelpers.unitDetailLines(
                  businessType: businessType,
                  unit: unit,
                  itemDetail: detail,
                );

                return Container(
                  margin:
                      const EdgeInsets.only(bottom: UIConstants.mediumSpace),
                  padding: const EdgeInsets.all(UIConstants.mediumSpace),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: UIConstants.smallBorderRadius,
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CusTxtWidget(
                        txt: singleItem?.name ?? 'Unknown Item',
                        txtStyle:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      BusinessItemDetailChips(
                        businessType: businessType,
                        detail: detail,
                        maxLines: 2,
                      ),
                      if (parts.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          parts.join(' · '),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade700,
                              ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      dataRow('Unit cost',
                          '${unit.originalPrice.toStringAsFixed(0)} MMK'),
                      dataRow('Unit sell', '${unitSell.toStringAsFixed(0)} MMK'),
                      if (unitSell != unitFinal)
                        dataRow('After promo',
                            '${unitFinal.toStringAsFixed(0)} MMK',
                            valueColor: Colors.red),
                      dataRow(
                        'Unit profit',
                        '${(unitFinal - unit.originalPrice).toStringAsFixed(0)} MMK',
                        valueColor: unitFinal >= unit.originalPrice
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                    ],
                  ),
                );
              }),
            ] else ...[
              ...selectedStockOutItemList.map((item) {
                final ItemModel? singleItem =
                    allItemList.firstWhereOrNull((e) => e.id == item.itemId);
                if (singleItem == null) {
                  debugPrint(
                      'MerchantOrderDetailSheet: missing item for itemId=${item.itemId}');
                }

                final itemProfit = item.finalSellPrice - item.originalPrice;

                return Container(
                  margin:
                      const EdgeInsets.only(bottom: UIConstants.mediumSpace),
                  padding: const EdgeInsets.all(UIConstants.mediumSpace),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: UIConstants.smallBorderRadius,
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CusTxtWidget(
                        txt: singleItem?.name ?? 'Unknown Item',
                        txtStyle:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      BusinessItemDetailChips(
                        businessType: businessType,
                        detail: itemCubit.getBusinessDetail(item.itemId),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      dataRow('Qty', '${item.count}'),
                      dataRow('Original Unit Cost',
                          '${item.originalPrice} MMK'),
                      dataRow('Unit Sell Price', '${item.sellPrice} MMK'),
                      if (item.sellPrice != item.finalSellPrice)
                        dataRow('Item Promo Deduced',
                            '-${((item.sellPrice - item.finalSellPrice) * item.count).toStringAsFixed(0)} MMK',
                            valueColor: Colors.red),
                      if (item.sellPrice != item.finalSellPrice)
                        dataRow('Sold Unit Price',
                            '${item.finalSellPrice} MMK',
                            isBold: true),
                      const SizedBox(height: 8),
                      const CusDividerWidget(clr: Colors.grey),
                      const SizedBox(height: 8),
                      dataRow('Total Item Cost',
                          '${item.originalPrice * item.count} MMK'),
                      dataRow('Total Item Sold For',
                          '${item.finalSellPrice * item.count} MMK',
                          isBold: true),
                      dataRow('Item Profit',
                          '${itemProfit * item.count} MMK',
                          isBold: true,
                          valueColor: itemProfit >= 0
                              ? Colors.green.shade700
                              : Colors.red.shade700),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import 'package:pos_mobile/blocs/transactions_bloc/transactions_cubit.dart';
import 'package:pos_mobile/blocs/promotion_bloc/promotion_cubit.dart';
import 'package:pos_mobile/models/promotion_model_folder/promotion_model.dart';
import 'package:pos_mobile/constants/uiConstants.dart';
import 'package:pos_mobile/models/transaction_model_folder/stockout_model_folder/stock_out_item_model.dart';
import 'package:pos_mobile/models/transaction_model_folder/stockout_model_folder/stock_out_model.dart';
import 'package:pos_mobile/utils/formula.dart';
import 'package:pos_mobile/widgets/btns_folder/leadingBackIconBtn.dart';
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
    final List<StockOutItemModel> selectedStockOutItemList =
        context.read<TransactionsCubit>().getSelectedStockOutItemList(stockOutModel.id);
        
    final List<ItemModel> allItemList = [
      ...context.watch<ItemCubit>().state.activeItemList,
      ...context.watch<ItemCubit>().state.inActiveItemList
    ];

    final double totalOrgPrice = CalculationFormula.getItemTotalOriginalPriceForStockOut(selectedStockOutItemList);
    final double totalItemFinalSellPrices = CalculationFormula.getItemTotalFinalSellPriceForStockOut(selectedStockOutItemList);
    
    final double finalprice = stockOutModel.finalTotalPrice;
    final double orderTax = CalculationFormula.getPercentageToMMK(totalItemFinalSellPrices, stockOutModel.taxPercentage ?? 0);
    
    final deliveryModel = stockOutModel.deliveryModelId == null ? null : context.read<TransactionsCubit>().getDeliveryModel(stockOutModel.deliveryModelId!);
    final double deliCharges = deliveryModel?.deliveryCharges ?? 0;
    
    // Fetch Order Promotion
    final stockOutPromo = context.read<PromotionCubit>().state.stockOutPromotionList.firstWhereOrNull((e) => e.stockOutId == stockOutModel.id);
    PromotionModel? orderPromotion;
    if (stockOutPromo != null) {
      orderPromotion = context.read<PromotionCubit>().state.activePromotionList.firstWhereOrNull((e) => e.id == stockOutPromo.promotionId) 
          ?? context.read<PromotionCubit>().state.inActivePromotionList.firstWhereOrNull((e) => e.id == stockOutPromo.promotionId);
    }
    
    double orderPromoAmount = 0;
    if (orderPromotion != null) {
       if (orderPromotion.promotionPercentage != null) {
          orderPromoAmount = CalculationFormula.getPercentageToMMK(totalItemFinalSellPrices + orderTax, orderPromotion.promotionPercentage!);
       } else if (orderPromotion.promotionPrice != null) {
          orderPromoAmount = orderPromotion.promotionPrice!;
       }
    }
    
    final double profit = finalprice - deliCharges - orderTax - totalOrgPrice;

    Widget dataRow(String title, String value, {bool isBold = false, Color? titleColor, Color? valueColor}) {
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
        title: const Text("Order Details (Merchant)"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(UIConstants.mediumSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CusTxtWidget(
              txt: "Order Details",
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
                  dataRow("Transaction ID", stockOutModel.code),
                  dataRow("Shopping Type", stockOutModel.shoppingType.name.toUpperCase()),
                  dataRow("Payment Method", stockOutModel.paymentMethod.name.toUpperCase()),
                  const SizedBox(height: 8),
                  const CusDividerWidget(clr: Colors.grey),
                  const SizedBox(height: 8),
                  dataRow("Total Original (Cost)", "$totalOrgPrice MMK"),
                  dataRow("Total Sold Value (Items)", "$totalItemFinalSellPrices MMK"),
                  dataRow("Checkout Tax", "$orderTax MMK"),
                  dataRow("Delivery Charges", "$deliCharges MMK"),
                  if (orderPromoAmount > 0)
                    dataRow("Order Promotion applied", "-${orderPromoAmount.toStringAsFixed(0)} MMK", valueColor: Colors.red),
                  if (stockOutModel.additionalPromotionAmount != null)
                    dataRow("Checkout Additional Promo", "-${stockOutModel.additionalPromotionAmount} MMK", valueColor: Colors.red),
                  const SizedBox(height: 8),
                  const CusDividerWidget(clr: Colors.grey),
                  const SizedBox(height: 8),
                  dataRow("Total Final Paid", "$finalprice MMK", isBold: true, valueColor: Colors.blue.shade700),
                  dataRow("Total Pure Profit", "$profit MMK", isBold: true, valueColor: profit >= 0 ? Colors.green.shade700 : Colors.red.shade700),
                ],
              ),
            ),
            const SizedBox(height: UIConstants.bigSpace),
            CusTxtWidget(
              txt: "Item Breakdown",
              txtStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: UIConstants.mediumSpace),
            ...selectedStockOutItemList.map((item) {
              ItemModel? singleItem;
              try {
                singleItem = allItemList.firstWhere((element) => element.id == item.itemId);
              } catch (e) {
                singleItem = null;
              }

              final itemProfit = item.finalSellPrice - item.originalPrice; 
              
              return Container(
                margin: const EdgeInsets.only(bottom: UIConstants.mediumSpace),
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
                      txt: singleItem?.name ?? "Unknown Item",
                      txtStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    dataRow("Qty", "${item.count}"),
                    dataRow("Original Unit Cost", "${item.originalPrice} MMK"),
                    dataRow("Unit Sell Price", "${item.sellPrice} MMK"),
                    if (item.sellPrice != item.finalSellPrice)
                      dataRow("Item Promo Deduced", "-${((item.sellPrice - item.finalSellPrice) * item.count).toStringAsFixed(0)} MMK", valueColor: Colors.red),
                    if (item.sellPrice != item.finalSellPrice)
                      dataRow("Sold Unit Price", "${item.finalSellPrice} MMK", isBold: true),
                    const SizedBox(height: 8),
                    const CusDividerWidget(clr: Colors.grey),
                    const SizedBox(height: 8),
                    dataRow("Total Item Cost", "${item.originalPrice * item.count} MMK"),
                    dataRow("Total Item Sold For", "${item.finalSellPrice * item.count} MMK", isBold: true),
                    dataRow("Item Profit", "${itemProfit * item.count} MMK", isBold: true, valueColor: itemProfit >= 0 ? Colors.green.shade700 : Colors.red.shade700),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

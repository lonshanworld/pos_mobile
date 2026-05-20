import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/blocs/item_bloc/item_cubit.dart';
import 'package:pos_mobile/blocs/transactions_bloc/transactions_cubit.dart';
import 'package:pos_mobile/blocs/userData_bloc/user_data_cubit.dart';
import 'package:pos_mobile/constants/uiConstants.dart';
import 'package:pos_mobile/models/transaction_model_folder/stockout_model_folder/stock_out_item_model.dart';
import 'package:pos_mobile/models/transaction_model_folder/stockout_model_folder/stock_out_model.dart';

import '../../features/cus_showmodelbottomsheet.dart';
import '../../models/deliver_model_folder/delivery_model.dart';
import '../../models/item_model_folder/item_model.dart';
import '../../models/user_model_folder/user_model.dart';
import '../../utils/formula.dart';
import '../history/transactions_history/history_voucher_screen.dart';

class DashboardStockOut extends StatelessWidget {
  const DashboardStockOut({super.key});

  @override
  Widget build(BuildContext context) {
    final CusShowSheet showSheet = CusShowSheet();

    Widget dataRow(String title, String txt, {bool isTotal = false}) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 4.0,
          horizontal: UIConstants.smallSpace,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                    color: isTotal ? null : Colors.grey.shade700,
                  ),
            ),
            Text(
              txt,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
                  ),
            ),
          ],
        ),
      );
    }

    return BlocBuilder<TransactionsCubit, TransactionsState>(
      builder: (context, state) {
        final List<StockOutModel> stockOutList =
            context.read<TransactionsCubit>().getTodayStockOut().reversed.toList();
        
        double totalSalePrice = 0;
        for (var element in stockOutList) {
          totalSalePrice += element.finalTotalPrice;
        }

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(UIConstants.mediumRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Colors.grey.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header & Summary
              Container(
                padding: const EdgeInsets.all(UIConstants.mediumSpace),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(UIConstants.mediumRadius),
                    topRight: Radius.circular(UIConstants.mediumRadius),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.point_of_sale,
                          color: Colors.deepPurple.shade700,
                          size: 24,
                        ),
                        const SizedBox(width: UIConstants.smallSpace),
                        Text(
                          "Today's Sales",
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                color: Colors.deepPurple.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "Total Revenue",
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                color: Colors.deepPurple.shade700,
                              ),
                        ),
                        Text(
                          "$totalSalePrice MMK",
                          style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                color: Colors.deepPurple.shade700,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Body
              if (stockOutList.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 48,
                        color: Colors.grey.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: UIConstants.mediumSpace),
                      Text(
                        "No sales records for today",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(UIConstants.smallSpace),
                  itemCount: stockOutList.length,
                  separatorBuilder: (context, index) => const SizedBox(height: UIConstants.smallSpace),
                  itemBuilder: (context, index) {
                    final stockOut = stockOutList[index];
                    final List<StockOutItemModel> stockOutItemList =
                        context.read<TransactionsCubit>().getSelectedStockOutItemList(stockOut.id);
                    final UserModel? userModel =
                        context.read<UserDataCubit>().getSingleUser(stockOut.createPersonId);
                    final DeliveryModel? deliveryModel = stockOut.deliveryModelId == null
                        ? null
                        : context.read<TransactionsCubit>().getDeliveryModel(stockOut.deliveryModelId!);

                    return InkWell(
                      borderRadius: BorderRadius.circular(UIConstants.smallRadius),
                      onTap: () {
                        // Change from long press to tap for better UX
                        showSheet.showCusBottomSheet(
                          HistoryVoucherScreen(stockOutModel: stockOut),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(UIConstants.mediumSpace),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(UIConstants.smallRadius),
                          border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Seller Info Header
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: Colors.deepPurple.shade100,
                                  child: Text(
                                    (index + 1).toString(),
                                    style: TextStyle(
                                      color: Colors.deepPurple.shade700,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: UIConstants.smallSpace),
                                Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    userModel?.userName ?? "Unknown Seller",
                                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                                Icon(Icons.chevron_right, size: 20, color: Colors.grey.shade400),
                              ],
                            ),
                            const SizedBox(height: UIConstants.smallSpace),
                            
                            // Items Table
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Table(
                                columnWidths: const {
                                  0: FlexColumnWidth(6),
                                  1: FlexColumnWidth(1),
                                  2: FlexColumnWidth(2),
                                },
                                children: stockOutItemList.map((stockOutItem) {
                                  final ItemModel? itemModel =
                                      context.read<ItemCubit>().getItem(stockOutItem.itemId);
                                  return TableRow(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                                        child: Text(
                                          itemModel?.name ?? "Unknown Item",
                                          style: Theme.of(context).textTheme.bodySmall,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                                        child: Text(
                                          "x",
                                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                                color: Colors.grey,
                                              ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                                        child: Text(
                                          stockOutItem.count.toString(),
                                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: UIConstants.smallSpace),

                            // Calculations
                            dataRow(
                              "Tax",
                              "${CalculationFormula.getPercentageToMMK(CalculationFormula.getTotalPriceForStockOutHistory(stockOutItemList), stockOut.taxPercentage ?? 0)} MMK",
                            ),
                            if (stockOut.additionalPromotionAmount != null && stockOut.additionalPromotionAmount! > 0)
                              dataRow(
                                "Discount",
                                "-${stockOut.additionalPromotionAmount} MMK",
                              ),
                            if (deliveryModel != null)
                              dataRow(
                                "Delivery",
                                "${deliveryModel.deliveryCharges} MMK",
                              ),
                            const Divider(height: 16),
                            dataRow(
                              "Final Total",
                              "${stockOut.finalTotalPrice} MMK",
                              isTotal: true,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/blocs/item_bloc/item_cubit.dart';
import 'package:pos_mobile/blocs/transactions_bloc/transactions_cubit.dart';
import 'package:pos_mobile/blocs/userData_bloc/user_data_cubit.dart';
import 'package:pos_mobile/constants/uiConstants.dart';
import 'package:pos_mobile/models/transaction_model_folder/stockout_model_folder/stock_out_item_model.dart';
import 'package:pos_mobile/models/transaction_model_folder/stockout_model_folder/stock_out_model.dart';
import 'package:pos_mobile/widgets/cusTxt_widget.dart';
import 'package:pos_mobile/widgets/dividers/cus_divider_widget.dart';

import '../../blocs/theme_bloc/theme_cubit.dart';
import '../../constants/enums.dart';
import '../../controller/ui_controller.dart';
import '../../features/cus_showmodelbottomsheet.dart';
import '../../models/deliver_model_folder/delivery_model.dart';
import '../../models/item_model_folder/item_model.dart';
import '../../models/user_model_folder/user_model.dart';
import '../../utils/formula.dart';
import '../../widgets/index_box_widget.dart';
import '../../widgets/tables_folder/cusTableRow.dart';
import '../history/transactions_history/history_voucher_screen.dart';

class DashboardStockOut extends StatelessWidget {
  const DashboardStockOut({super.key});

  @override
  Widget build(BuildContext context) {
    final UIController uiController = UIController.instance;
    final ThemeModeType themeModeType = context.watch<ThemeCubit>().state.themeModeType;
    final CusShowSheet showSheet = CusShowSheet();

    Widget dataRow(String title, String txt){
      return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: UIConstants.smallSpace,
          horizontal: UIConstants.bigSpace,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            CusTxtWidget(
              txtStyle: Theme.of(context).textTheme.titleSmall!,
              txt: title,
            ),
            CusTxtWidget(
              txtStyle: Theme.of(context).textTheme.bodyMedium!,
              txt: txt,
            ),
          ],
        ),
      );
    }

    return BlocBuilder<TransactionsCubit, TransactionsState>(
      builder: (context, state){
        final List<StockOutModel> stockOutList = context.read<TransactionsCubit>().getTodayStockOut().reversed.toList();
        double totalSalePrice = 0;
        for (var element in stockOutList) {
          totalSalePrice = totalSalePrice + element.finalTotalPrice;
        }

        return Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 0,
                  ),
                  decoration: BoxDecoration(

                    border: Border(
                      bottom: BorderSide(
                        color: uiController.getpureOppositeClr(themeModeType),
                        width: 3,
                      )
                    )
                  ),
                  child: CusTxtWidget(
                    txt: "Stock-Out",
                    txtStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: uiController.getpureOppositeClr(themeModeType),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: UIConstants.mediumSpace,
                    horizontal: UIConstants.bigSpace,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: uiController.getpureOppositeClr(themeModeType),
                    ),
                    borderRadius: UIConstants.mediumBorderRadius,
                  ),
                  child: Column(
                    children: [
                      CusTxtWidget(
                        txt: "Today sales(MMK)",
                        txtStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: uiController.getpureOppositeClr(themeModeType),
                        ),
                      ),
                      CusTxtWidget(
                        txt: totalSalePrice.toString(),
                        txtStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: uiController.getpureOppositeClr(themeModeType),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: stockOutList.isEmpty
                  ?
              Center(
                child: CusTxtWidget(
                  txt: "No sale for today",
                  txtStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Colors.grey.withOpacity(0.7)
                  ),
                ),
              )
                  :
              ListView(
                children: stockOutList.asMap().entries.map((e){
                  List<StockOutItemModel> stockOutItemList = context.read<TransactionsCubit>().getSelectedStockOutItemList(e.value.id);
                  final UserModel? userModel = context.read<UserDataCubit>().getSingleUser(e.value.createPersonId);
                  final DeliveryModel? deliveryModel = e.value.deliveryModelId == null ? null : context.read<TransactionsCubit>().getDeliveryModel(e.value.deliveryModelId!);

                  return InkWell(
                    onLongPress: (){
                      showSheet.showCusBottomSheet(
                          HistoryVoucherScreen(stockOutModel: e.value)
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(UIConstants.smallSpace),
                      margin: const EdgeInsets.all(UIConstants.smallSpace),
                      decoration: BoxDecoration(
                        color: uiController.getpureDirectClr(themeModeType),
                        borderRadius: UIConstants.mediumBorderRadius,
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(UIConstants.mediumSpace),
                            child: Row(
                              children: [
                                IndexBoxWidget(index: (e.key + 1).toString()),
                                uiController.sizedBox(cusHeight: null, cusWidth: UIConstants.bigSpace),
                                CusTxtWidget(
                                  txtStyle: Theme.of(context).textTheme.titleSmall!,
                                  txt: userModel == null ? "Seller not found" : "Seller Name :  ${userModel.userName}",
                                ),
                              ],
                            ),
                          ),
                          Table(
                              columnWidths: const {
                                0 : FlexColumnWidth(10),
                                1 : FlexColumnWidth(2),
                                2 : FlexColumnWidth(5),
                              },
                              children: stockOutItemList.map((stockOutItem){
                                final ItemModel? itemModel = context.read<ItemCubit>().getItem(stockOutItem.itemId);
                                return CusTableRow.tableRowWithThreeStringsForStockOutHistory(
                                  itemModel == null ? "Item not found" : itemModel.name,
                                  "x",
                                  stockOutItem.count.toString(),
                                  context,
                                );
                              }).toList()
                          ),
                          dataRow(
                            "Tax (MMK)",
                            CalculationFormula.getPercentageToMMK(CalculationFormula.getTotalPriceForStockOutHistory(stockOutItemList), e.value.taxPercentage ?? 0).toString(),
                          ),
                          dataRow(
                            "Additional Promotion",
                            e.value.additionalPromotionAmount == null ? "0" : e.value.additionalPromotionAmount.toString(),
                          ),
                          if(deliveryModel != null)dataRow(
                            "Deli-charges",
                            deliveryModel.deliveryCharges.toString(),
                          ),
                          const CusDividerWidget(clr: Colors.grey),
                          dataRow(
                            "Total final sell Price",
                            e.value.finalTotalPrice.toString(),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/blocs/item_bloc/item_cubit.dart';
import 'package:pos_mobile/blocs/loading_bloc/loading_cubit.dart';
import 'package:pos_mobile/blocs/transactions_bloc/transactions_cubit.dart';
import 'package:pos_mobile/blocs/userData_bloc/user_data_cubit.dart';
import 'package:pos_mobile/constants/uiConstants.dart';
import 'package:pos_mobile/features/cus_showmodelbottomsheet.dart';
import 'package:pos_mobile/models/transaction_model_folder/stockout_model_folder/stockout_history_model.dart';
import 'package:pos_mobile/models/user_model_folder/user_model.dart';
import 'package:pos_mobile/screens/confirm_screens_folder/comfirm_screen.dart';
import 'package:pos_mobile/screens/history/transactions_history/history_voucher_screen.dart';
import 'package:pos_mobile/utils/formula.dart';
import 'package:pos_mobile/utils/txt_formatters.dart';
import 'package:pos_mobile/utils/ui_responsive_calculation.dart';
import 'package:pos_mobile/widgets/cusPopMenuItem_widget.dart';
import 'package:pos_mobile/widgets/cusTxt_widget.dart';
import 'package:pos_mobile/widgets/dividers/cus_divider_widget.dart';
import 'package:pos_mobile/widgets/index_box_widget.dart';
import 'package:pos_mobile/widgets/tables_folder/stockout_item_table.dart';

import '../../blocs/theme_bloc/theme_cubit.dart';
import '../../constants/enums.dart';
import '../../controller/ui_controller.dart';
import '../../models/deliver_model_folder/delivery_model.dart';
import '../../models/item_model_folder/item_model.dart';
import '../../models/transaction_model_folder/stockout_model_folder/stock_out_item_model.dart';

class StockOutHistoryWidget extends StatelessWidget {

  final StockOutHistoryModel historyModel;
  final double totalProfit;
  // final List<StockOutModel> selectedStockOutList;
  // final List<StockOutItemModel> selectStockOutItemModelList;

  const StockOutHistoryWidget({
    super.key,
    required this.historyModel,
    required this.totalProfit,
    // required this.selectedStockOutList,
    // required this.selectStockOutItemModelList,

  });


  @override
  Widget build(BuildContext context) {
    final UIController uiController = UIController.instance;
    final ThemeModeType themeModeType = context.watch<ThemeCubit>().state.themeModeType;
    final UserModel? userModel = context.watch<UserDataCubit>().state.userModel;
    final UIutils uIutils = UIutils();
    final CusShowSheet showSheet = CusShowSheet();
    final List<ItemModel> activeItemModelList = context.watch<ItemCubit>().state.activeItemList;
    final List<ItemModel> inActiveItemModelList = context.watch<ItemCubit>().state.inActiveItemList;
    final List<ItemModel> allItemModelList = [...activeItemModelList, ...inActiveItemModelList];

    double oneStockOutProfit(double totalOrigin, double finalSellPrice, double delicharges){
      return finalSellPrice - totalOrigin - delicharges;
    }


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

    // double getTotalOriginalPrice(List<StockOutItemModel> dataList){
    //   double value = 0;
    //   for(int i = 0; i < dataList.length; i++){
    //     value = value + (dataList[i].count * dataList[i].originalPrice);
    //   }
    //   return value;
    // }



    return Container(
      width: uIutils.stockOutHistoryWidgetWidth(),
      decoration: BoxDecoration(
        borderRadius: UIConstants.bigBorderRadius,
        border: Border.all(
          color: Colors.grey,
        ),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: UIConstants.mediumSpace,
        horizontal: UIConstants.mediumSpace,
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: CusTxtWidget(
              txt: historyModel.dateTimeTxt,
              txtStyle: Theme.of(context).textTheme.bodyLarge!,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.max,
            children: [
              CusTxtWidget(
                txtStyle: Theme.of(context).textTheme.bodyLarge!,
                txt: "Total Profit",
              ),
              CusTxtWidget(
                txtStyle: Theme.of(context).textTheme.titleMedium!,
                txt: totalProfit.toString(),
              ),
            ],
          ),
          const CusDividerWidget(clr: Colors.grey),
          ...historyModel.stockOutList.reversed.toList().asMap().entries.map((e){
            final UserModel? seller = context.read<UserDataCubit>().getSingleUser(e.value.createPersonId);
            final List<StockOutItemModel> selectedStockOutItemList = context.read<TransactionsCubit>().getSelectedStockOutItemList(e.value.id);
            // final CustomerModel? customerModel = e.customerId == null ? null : context.read<TransactionsCubit>().getCustomerModel(e.customerId!);
            final DeliveryModel? deliveryModel = e.value.deliveryModelId == null ? null : context.read<TransactionsCubit>().getDeliveryModel(e.value.deliveryModelId!);
            // final DeliveryPersonModel? deliveryPersonModel = e.deliveryPersonId == null ? null : context.read<TransactionsCubit>().getDeliveryPerson(e.deliveryPersonId!);
            final double totalOrgPrice = CalculationFormula.getItemTotalOriginalPriceForStockOut(selectedStockOutItemList);
            final List<ItemModel> selectedItemModelList = [];
            for(int a = 0 ; a < selectedStockOutItemList.length; a++){
              ItemModel singleItem = allItemModelList.firstWhere((element) => element.id == selectedStockOutItemList[a].itemId);
              selectedItemModelList.add(singleItem);
            }

            return PopupMenuButton(
              tooltip: "Created at : ${TextFormatters.getDateTime(e.value.createTime)}",
              itemBuilder: (BuildContext ctx){
                return [
                  cusPopUpMenuItem(
                    func: (){
                      showSheet.showCusDialogScreen(ConfirmScreen(
                        txt: '" Order Cancel " :  If you confirmed to order cancel, all of these items will be back to Storage(Stock-in). ',
                        title: "Order Cancel confirm ?",
                        acceptBtnTxt: "Yes, cancel the order",
                        cancelBtnTxt: "No",
                        acceptFunc: ()async{
                          context.read<LoadingCubit>().setLoading("Order Cancel ...");
                          await context.read<TransactionsCubit>().stockOutOrderCancel(
                            stockOutId: e.value.id,
                            userModel: userModel!,
                            itemModelList: selectedItemModelList,
                          ).then((value)async{

                            if(value){
                              await context.read<ItemCubit>().reloadAllItem().then((_){
                                Navigator.of(context).pop();
                                context.read<LoadingCubit>().setSuccess("Success !");
                              });

                            }else{
                              Navigator.of(context).pop();
                              context.read<LoadingCubit>().setFail("Fail !");
                            }
                          });
                        },
                        cancelFunc: (){
                          Navigator.of(context).pop();
                        },
                      ));
                    },
                    txt: "Order cancel",
                    isImportant: false,
                    context: ctx,
                  ),
                  cusPopUpMenuItem(
                    func: (){
                      showSheet.showCusDialogScreen(ConfirmScreen(
                        txt: '" Delete stock-out " :  If you confirmed to delete this stock-out, all of these items will be disappeard without returning to Storage(Stock-in). ',
                        title: "Delete stock-out confirm ?",
                        acceptBtnTxt: "Yes, delete",
                        cancelBtnTxt: "No",
                        acceptFunc: ()async{
                          context.read<LoadingCubit>().setLoading("Deleting ...");
                          await context.read<TransactionsCubit>().stockOutDelete(
                            stockOutId: e.value.id,
                            userModel: userModel!,
                          ).then((value) {
                            if(value){
                              Navigator.of(context).pop();
                              context.read<LoadingCubit>().setSuccess("Success !");
                            }else{
                              Navigator.of(context).pop();
                              context.read<LoadingCubit>().setFail("Fail !");
                            }
                          });
                        },
                        cancelFunc: (){
                          Navigator.of(context).pop();
                        },
                      ));
                    },
                    txt: "Delete stock-out",
                    isImportant: true,
                    context: ctx,
                  ),
                  cusPopUpMenuItem(
                    func: (){
                      showSheet.showCusBottomSheet(
                          HistoryVoucherScreen(stockOutModel: e.value)
                      );
                    },
                    txt: "Get voucher",
                    isImportant: false,
                    context: ctx,
                  ),
                ];
              },
              child: Container(
                padding: EdgeInsets.all(UIConstants.smallSpace),
                margin: EdgeInsets.all(UIConstants.smallSpace),
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
                            txt: seller == null ? "Seller not found" : "Seller Name :  ${seller.userName}",
                          ),
                        ],
                      ),
                    ),
                    ...selectedStockOutItemList.map((e){
                      final ItemModel? itemModel = context.read<ItemCubit>().getItem(e.itemId);
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 3,
                        ),
                        child: StockOutItemTable(
                          name: itemModel == null ? "Item not found" : itemModel.name,
                          count: e.count.toString(),
                          originalPrice: e.originalPrice.toString(),
                          finalSellPrice: e.finalSellPrice.toString(),
                          profit: (e.finalSellPrice - e.originalPrice).toString(),
                          totalProfit: ((e.finalSellPrice - e.originalPrice) * e.count).toString(),
                        ),
                      );
                    }),
                    dataRow(
                      "Tax (MMK)",
                      CalculationFormula.getPercentageToMMK(CalculationFormula.getTotalPriceForStockOutHistory(selectedStockOutItemList), e.value.taxPercentage ?? 0).toString(),
                    ),
                    dataRow(
                      "Additional Promotion",
                      e.value.additionalPromotionAmount == null ? "0" : e.value.additionalPromotionAmount.toString(),
                    ),

                    dataRow(
                      "Total final sell Price",
                      e.value.finalTotalPrice.toString(),
                    ),
                    if(deliveryModel != null)dataRow(
                      "Deli-charges",
                      deliveryModel.deliveryCharges.toString(),
                    ),
                    dataRow(
                      "Total original price",
                      totalOrgPrice.toString(),
                    ),
                    const CusDividerWidget(clr: Colors.grey),
                    dataRow(
                      "Profit",
                      oneStockOutProfit(totalOrgPrice, e.value.finalTotalPrice, deliveryModel == null ? 0 : deliveryModel.deliveryCharges ?? 0).toString(),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

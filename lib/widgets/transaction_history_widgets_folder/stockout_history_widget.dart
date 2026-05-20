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
import 'package:pos_mobile/utils/txt_formatters.dart';
import 'package:pos_mobile/widgets/cusPopMenuItem_widget.dart';
import 'package:pos_mobile/widgets/cusTxt_widget.dart';

import '../../blocs/theme_bloc/theme_cubit.dart';
import '../../constants/enums.dart';
import '../../controller/ui_controller.dart';
import '../../models/item_model_folder/item_model.dart';
import '../../models/transaction_model_folder/stockout_model_folder/stock_out_item_model.dart';

class StockOutHistoryWidget extends StatefulWidget {

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
  State<StockOutHistoryWidget> createState() => _StockOutHistoryWidgetState();
}

class _StockOutHistoryWidgetState extends State<StockOutHistoryWidget> {
  @override
  Widget build(BuildContext context) {
    final UIController uiController = UIController.instance;
    final ThemeModeType themeModeType = context.watch<ThemeCubit>().state.themeModeType;
    final UserModel? userModel = context.watch<UserDataCubit>().state.userModel;
    final CusShowSheet showSheet = CusShowSheet();
    final List<ItemModel> allItemModelList = [
      ...context.watch<ItemCubit>().state.activeItemList,
      ...context.watch<ItemCubit>().state.inActiveItemList
    ];

    Future<void> orderCancelFunc(int id, List<ItemModel> itemModelList) async {
      context.read<LoadingCubit>().setLoading("Order Cancel ...");
      final value = await context.read<TransactionsCubit>().stockOutOrderCancel(
        stockOutId: id,
        userModel: userModel!,
        itemModelList: itemModelList,
      );

      if (!mounted) return;
      Navigator.of(context).pop();
      if (value) {
        context.read<LoadingCubit>().setSuccess("Success !");
      } else {
        context.read<LoadingCubit>().setFail("Fail !");
      }
    }

    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: UIConstants.bigBorderRadius),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Elegant Header
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: UIConstants.mediumSpace,
              horizontal: UIConstants.bigSpace,
            ),
            decoration: BoxDecoration(
              color: uiController.getpureOppositeClr(themeModeType),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CusTxtWidget(
                  txt: widget.historyModel.dateTimeTxt,
                  txtStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: uiController.getpureDirectClr(themeModeType),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CusTxtWidget(
                      txt: "Total Profit",
                      txtStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: uiController.getpureDirectClr(themeModeType).withValues(alpha: 0.7),
                      ),
                    ),
                    CusTxtWidget(
                      txt: "${widget.totalProfit} MMK",
                      txtStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: uiController.getpureDirectClr(themeModeType),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // List of Transactions for the Day
          Container(
            color: uiController.getpureDirectClr(themeModeType),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.historyModel.stockOutList.length,
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (context, index) {
                // We show newest first within the day
                final reversedIndex = widget.historyModel.stockOutList.length - 1 - index;
                final transaction = widget.historyModel.stockOutList[reversedIndex];
                
                final UserModel? seller = context.read<UserDataCubit>().getSingleUser(transaction.createPersonId);
                final List<StockOutItemModel> selectedStockOutItemList = context.read<TransactionsCubit>().getSelectedStockOutItemList(transaction.id);
                
                int totalItemsCount = 0;
                for(var item in selectedStockOutItemList) {
                  totalItemsCount += item.count;
                }

                final List<ItemModel> selectedItemModelList = [];
                for(int a = 0 ; a < selectedStockOutItemList.length; a++){
                  try {
                    ItemModel singleItem = allItemModelList.firstWhere((element) => element.id == selectedStockOutItemList[a].itemId);
                    selectedItemModelList.add(singleItem);
                  } catch (e) {
                    // Ignore if item not found
                  }
                }

                return PopupMenuButton(
                  tooltip: "Options",
                  itemBuilder: (BuildContext ctx) => [
                    cusPopUpMenuItem(
                      func: () {
                        showSheet.showCusBottomSheet(
                          HistoryVoucherScreen(stockOutModel: transaction)
                        );
                      },
                      txt: "View Receipt / Voucher",
                      isImportant: false,
                      context: ctx,
                    ),
                    cusPopUpMenuItem(
                      func: () {
                        showSheet.showCusDialogScreen(ConfirmScreen(
                          txt: '" Order Cancel " :  If you confirmed to order cancel, all of these items will be back to Storage(Stock-in). ',
                          title: "Order Cancel confirm ?",
                          acceptBtnTxt: "Yes, cancel the order",
                          cancelBtnTxt: "No",
                          acceptFunc: () async {
                            await orderCancelFunc(transaction.id, selectedItemModelList);
                            if (!mounted) return;
                            await context.read<ItemCubit>().reloadAllItem();
                          },
                          cancelFunc: () => Navigator.of(ctx).pop(),
                        ));
                      },
                      txt: "Cancel Order (Refund)",
                      isImportant: false,
                      context: ctx,
                    ),
                    cusPopUpMenuItem(
                      func: () {
                        showSheet.showCusDialogScreen(ConfirmScreen(
                          txt: '" Delete stock-out " :  If you confirmed to delete this stock-out, all of these items will be disappeared without returning to Storage(Stock-in). ',
                          title: "Delete stock-out confirm ?",
                          acceptBtnTxt: "Yes, delete permanently",
                          cancelBtnTxt: "No",
                          acceptFunc: () async {
                            context.read<LoadingCubit>().setLoading("Deleting ...");
                            final value = await context.read<TransactionsCubit>().stockOutDelete(
                              stockOutId: transaction.id,
                              userModel: userModel!,
                            );

                            if (!mounted) return;
                            Navigator.of(context).pop();
                            if (value) {
                              context.read<LoadingCubit>().setSuccess("Success !");
                            } else {
                              context.read<LoadingCubit>().setFail("Fail !");
                            }
                          },
                          cancelFunc: () => Navigator.of(context).pop(),
                        ));
                      },
                      txt: "Delete completely",
                      isImportant: true,
                      context: ctx,
                    ),
                  ],
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: UIConstants.bigSpace, vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey.withValues(alpha: 0.1),
                      child: Icon(Icons.receipt_long, color: uiController.getpureOppositeClr(themeModeType)),
                    ),
                    title: CusTxtWidget(
                      txt: seller?.userName ?? "Unknown Seller",
                      txtStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600),
                    ),
                    subtitle: CusTxtWidget(
                      txt: "${TextFormatters.getDateTime(transaction.createTime).split(' ')[1]} • $totalItemsCount items",
                      txtStyle: Theme.of(context).textTheme.bodySmall!,
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        CusTxtWidget(
                          txt: "${transaction.finalTotalPrice} MMK",
                          txtStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (transaction.paymentMethod == PaymentMethod.onlineCash)
                          CusTxtWidget(
                            txt: transaction.paymentMethod.name.toUpperCase(),
                            txtStyle: Theme.of(context).textTheme.labelSmall!.copyWith(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
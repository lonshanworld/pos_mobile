import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/models/transaction_model_folder/stockin_model_folder/stockin_history_model.dart';

import '../../blocs/item_bloc/item_cubit.dart';
import '../../blocs/theme_bloc/theme_cubit.dart';
import '../../blocs/userData_bloc/user_data_cubit.dart';
import '../../constants/enums.dart';
import '../../constants/uiConstants.dart';
import '../../controller/ui_controller.dart';
import '../../models/item_model_folder/item_model.dart';
import '../../models/item_model_folder/uniqueItem_model.dart';
import '../../models/user_model_folder/user_model.dart';
import '../../utils/ui_responsive_calculation.dart';
import '../cusTxt_widget.dart';
import '../index_box_widget.dart';
import '../tables_folder/cusTableRow.dart';

class StockInHistoryWidget extends StatelessWidget {

  final StockInHistoryModel stockInHistoryModel;
  final bool showDate;
  // final List<ItemModel> itemList;
  // final List<UniqueItemModel> uniqueItemList;
  const StockInHistoryWidget({
    super.key,
    required this.stockInHistoryModel,
    required this.showDate,
    // required this.itemList,
    // required this.uniqueItemList,
  });

  @override
  Widget build(BuildContext context) {
    final UIController uiController = UIController.instance;
    final ThemeModeType themeModeType = context.watch<ThemeCubit>().state.themeModeType;
    final UIutils uIutils = UIutils();

    return Container(
      width: showDate ? uIutils.stockInHistoryWidgetWidth() : double.maxFinite,
      decoration: BoxDecoration(
        borderRadius: UIConstants.bigBorderRadius,
        border: Border.all(
          color: showDate ? Colors.grey : Colors.transparent,
        ),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: UIConstants.mediumSpace,
        horizontal: UIConstants.mediumSpace,
      ),
      child: Column(
        children: [
          if(showDate)Align(
            alignment: Alignment.centerLeft,
            child: CusTxtWidget(
              txt: stockInHistoryModel.dateTxt,
              txtStyle: Theme.of(context).textTheme.bodyLarge!,
            ),
          ),
          ...stockInHistoryModel.stockInList.reversed.toList().asMap().entries.map((e){
            // cusDebugPrint(e.value.id);
            final UserModel? stockInPerson = context.read<UserDataCubit>().getSingleUser(e.value.createPersonId);
            final List<UniqueItemModel> activeUniqueItemList = context.watch<ItemCubit>().state.activeUniqueItemList;
            final List<UniqueItemModel> filteredInActiveUniqueItemList = context.read<ItemCubit>().filterInActiveUniqueItemList();
            final List<UniqueItemModel> combineUniqueItemList = [...activeUniqueItemList, ...filteredInActiveUniqueItemList];
            final List<UniqueItemModel> selectedUniqueItemList = [];
            // cusDebugPrint("---------start--------------");
            for(int a = 0; a< combineUniqueItemList.length; a++){
              if(combineUniqueItemList[a].stockInId == e.value.id ){
                selectedUniqueItemList.add(combineUniqueItemList[a]);
              }

              // cusDebugPrint(combineUniqueItemList[a].itemId);

            }
            // selectedUniqueItemList.forEach((element) {
            //   cusDebugPrint(element.itemId);
            // });
            // cusDebugPrint("---------end--------------");
            // cusDebugPrint(activeUniqueItemList.length);
            // cusDebugPrint(filteredInActiveUniqueItemList.length);
            // cusDebugPrint(combineUniqueItemList.length);
            // cusDebugPrint(selectedUniqueItemList.length);
            final List<int> itemIdList = [];
            for(int b = 0; b < selectedUniqueItemList.length; b++){
              if(!itemIdList.contains(selectedUniqueItemList[b].itemId)){
                itemIdList.add(selectedUniqueItemList[b].itemId);
              }
            }

            return Container(

              decoration: BoxDecoration(
                borderRadius: UIConstants.mediumBorderRadius,
                color: uiController.getpureDirectClr(themeModeType),
              ),
              padding: const EdgeInsets.all(UIConstants.smallSpace),
              margin: const EdgeInsets.all(UIConstants.smallSpace),
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
                          txt: stockInPerson == null ? "Person not found" : "Name :  ${stockInPerson.userName}",
                        ),
                      ],
                    ),
                  ),
                  Table(
                    columnWidths: const {
                      0 : FlexColumnWidth(8),
                      1 : FlexColumnWidth(1),
                      2 : FlexColumnWidth(3),
                    },
                    children: itemIdList.map((id){
                      ItemModel? item = context.read<ItemCubit>().getItem(id);
                      List<UniqueItemModel> selectedList = [];
                      for(int a = 0; a < selectedUniqueItemList.length; a++){
                        if(selectedUniqueItemList[a].itemId == id){
                          selectedList.add(selectedUniqueItemList[a]);
                        }
                      }
                      return CusTableRow.tableRowWithThreeStringsForStockOutHistory(
                          item == null ? "Item not found" : item.name,
                          "x",
                          selectedList.length.toString(),
                          context
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

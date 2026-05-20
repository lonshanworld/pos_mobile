import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/models/transaction_model_folder/stockin_model_folder/stockin_history_model.dart';

import '../../blocs/item_bloc/item_cubit.dart';
import '../../blocs/theme_bloc/theme_cubit.dart';
import '../../blocs/userData_bloc/user_data_cubit.dart';
import '../../constants/enums.dart';
import '../../constants/uiConstants.dart';
import '../../controller/ui_controller.dart';

import '../../models/item_model_folder/uniqueItem_model.dart';
import '../../models/user_model_folder/user_model.dart';

import '../cusTxt_widget.dart';



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

    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: UIConstants.bigBorderRadius),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showDate)
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: UIConstants.mediumSpace,
                horizontal: UIConstants.bigSpace,
              ),
              decoration: BoxDecoration(
                color: uiController.getpureOppositeClr(themeModeType),
              ),
              child: CusTxtWidget(
                txt: stockInHistoryModel.dateTxt,
                txtStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: uiController.getpureDirectClr(themeModeType),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          
          Container(
            color: uiController.getpureDirectClr(themeModeType),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: stockInHistoryModel.stockInList.length,
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (context, index) {
                final reversedIndex = stockInHistoryModel.stockInList.length - 1 - index;
                final e = stockInHistoryModel.stockInList[reversedIndex];

                final UserModel? stockInPerson = context.read<UserDataCubit>().getSingleUser(e.createPersonId);
                final List<UniqueItemModel> activeUniqueItemList = context.watch<ItemCubit>().state.activeUniqueItemList;
                final List<UniqueItemModel> filteredInActiveUniqueItemList = context.read<ItemCubit>().filterInActiveUniqueItemList();
                final List<UniqueItemModel> combineUniqueItemList = [...activeUniqueItemList, ...filteredInActiveUniqueItemList];
                final List<UniqueItemModel> selectedUniqueItemList = [];
                
                for(int a = 0; a < combineUniqueItemList.length; a++){
                  if(combineUniqueItemList[a].stockInId == e.id ){
                    selectedUniqueItemList.add(combineUniqueItemList[a]);
                  }
                }

                // Group by Item ID to show clean subtitle
                Map<int, int> itemCounts = {};
                for(var unique in selectedUniqueItemList) {
                  itemCounts[unique.itemId] = (itemCounts[unique.itemId] ?? 0) + 1;
                }

                int totalItems = selectedUniqueItemList.length;
                int uniqueTypes = itemCounts.keys.length;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: UIConstants.bigSpace, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.withValues(alpha: 0.1),
                    child: Icon(Icons.add_box, color: uiController.getpureOppositeClr(themeModeType)),
                  ),
                  title: CusTxtWidget(
                    txt: stockInPerson?.userName ?? "Unknown User",
                    txtStyle: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600),
                  ),
                  subtitle: CusTxtWidget(
                    txt: "Added $totalItems items across $uniqueTypes types",
                    txtStyle: Theme.of(context).textTheme.bodySmall!,
                  ),
                  trailing: CusTxtWidget(
                    txt: "+$totalItems",
                    txtStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
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

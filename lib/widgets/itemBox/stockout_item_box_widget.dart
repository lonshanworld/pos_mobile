import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/blocs/item_bloc/item_cubit.dart';
import 'package:pos_mobile/blocs/promotion_bloc/promotion_cubit.dart';
import 'package:pos_mobile/constants/uiConstants.dart';
import 'package:pos_mobile/models/groupingItem_models_folders/category_model.dart';
import 'package:pos_mobile/models/item_model_folder/item_model.dart';
import 'package:pos_mobile/models/item_model_folder/uniqueItem_model.dart';
import 'package:pos_mobile/utils/formula.dart';





import '../../blocs/theme_bloc/theme_cubit.dart';
import '../../constants/enums.dart';
import '../../controller/ui_controller.dart';
import '../../models/groupingItem_models_folders/group_model.dart';
import '../../models/groupingItem_models_folders/type_model.dart';
import '../../models/promotion_model_folder/promotion_model.dart';

class StockOutItemBoxWidget extends StatefulWidget {

  final ItemModel itemModel;
  final Function(ItemModel itemModel)reduceFunc;
  final Function(UniqueItemModel uniqueItemModel) addFunc;
  final List<UniqueItemModel> selectedUniqueItemList;
  final int startIndex;
  const StockOutItemBoxWidget({
    super.key,
    required this.itemModel,
    required this.reduceFunc,
    required this.addFunc,
    required this.selectedUniqueItemList,
    required this.startIndex,
  });

  @override
  State<StockOutItemBoxWidget> createState() => _StockOutItemBoxWidgetState();
}

class _StockOutItemBoxWidgetState extends State<StockOutItemBoxWidget> {
  // int moreItem = 0;
  //
  //
  // @override
  // void initState() {
  //   super.initState();
  //   if(mounted){
  //     setState(() {
  //       moreItem = widget.startIndex;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final List<UniqueItemModel> uniqueItemList = context.read<ItemCubit>().getSelectedUniqueItemList(widget.itemModel.id);
    final UIController uiController = UIController.instance;
    final ThemeModeType themeModeType = context.watch<ThemeCubit>().state.themeModeType;
    final TypeModel? typeModel = context.read<ItemCubit>().getType(widget.itemModel.typeId);
    final GroupModel? groupModel = typeModel == null ? null : context.read<ItemCubit>().getGroup(typeModel.groupId);
    final CategoryModel? categoryModel = groupModel == null ? null : context.read<ItemCubit>().getCategory(groupModel.categoryId);
    final PromotionModel? promotion = context.read<PromotionCubit>().getSinglePromotionFromItemId(widget.itemModel.id);
    int moreItem = widget.startIndex;
    int availableStock = uniqueItemList.length - moreItem;
    bool outOfStock = availableStock <= 0;

    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: UIConstants.mediumBorderRadius),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          color: uiController.getpureDirectClr(themeModeType),
          border: moreItem > 0 ? Border.all(color: Colors.amber, width: 2) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image / Header area
            Expanded(
              flex: 4,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: Colors.grey.withValues(alpha: 0.05),
                    child: Center(
                      child: Icon(
                        Icons.inventory_2,
                        size: 48,
                        color: Colors.grey.withValues(alpha: 0.25),
                      ),
                    ),
                  ),
                  // Category Badge
                  if (categoryModel != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: uiController.getpureOppositeClr(themeModeType),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          categoryModel.name,
                          style: TextStyle(color: uiController.getpureDirectClr(themeModeType), fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  // Stock Badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: outOfStock ? UIConstants.redVioletClr : Colors.grey[700],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        outOfStock ? "Out of Stock" : "$availableStock left",
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  if (promotion != null)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        color: Colors.amber.withValues(alpha: 0.9),
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: const Text(
                          "PROMO",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Details Area
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item Name
                    Text(
                      widget.itemModel.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    
                    // Price
                    Text(
                      "${CalculationFormula.getItemSellPrice(originalPrice: widget.itemModel.originalPrice, profitPrice: widget.itemModel.profitPrice, taxPercentage: widget.itemModel.taxPercentage ?? 0).toInt()} MMK",
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    
                    // Controls
                    Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.remove, color: moreItem > 0 ? uiController.getpureOppositeClr(themeModeType) : Colors.grey),
                            onPressed: () {
                              if (moreItem > 0) {
                                widget.reduceFunc(widget.itemModel);
                                setState(() => moreItem--);
                              }
                            },
                          ),
                          Text(
                            moreItem.toString(),
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.add, color: outOfStock ? Colors.grey : uiController.getpureOppositeClr(themeModeType)),
                            onPressed: () {
                              if (!outOfStock) {
                                widget.addFunc(uniqueItemList[moreItem]);
                                setState(() => moreItem++);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

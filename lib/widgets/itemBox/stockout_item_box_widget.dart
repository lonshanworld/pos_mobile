import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/blocs/item_bloc/item_cubit.dart';
import 'package:pos_mobile/blocs/promotion_bloc/promotion_cubit.dart';
import 'package:pos_mobile/constants/uiConstants.dart';
import 'package:pos_mobile/models/groupingItem_models_folders/category_model.dart';
import 'package:pos_mobile/models/item_model_folder/item_model.dart';
import 'package:pos_mobile/models/item_model_folder/uniqueItem_model.dart';
import 'package:pos_mobile/utils/formula.dart';
import 'package:pos_mobile/widgets/btns_folder/cusIconBtn_widget.dart';
import 'package:pos_mobile/widgets/cusTxt_widget.dart';
import 'package:pos_mobile/widgets/dividers/cus_verticaldivider.dart';
import 'package:pos_mobile/widgets/promotion/promotion_with_item_widget.dart';

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

    Widget groupingNameBox(String txt){
      return Expanded(
        child: Align(
          alignment: Alignment.center,
          child: CusTxtWidget(
            txtStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
              fontWeight: FontWeight.bold,
            ),
            txt: txt,
          ),
        ),
      );
    }


    return SizedBox(
      width: UIConstants.stockoutBoxWidth,
      child: Column(
        children: [
          Container(
            height: 30,
            margin: const EdgeInsets.symmetric(
              horizontal: UIConstants.bigSpace,
            ),
            decoration: BoxDecoration(
              color: uiController.getpureDirectClr(themeModeType),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(UIConstants.smallRadius),
                topRight: Radius.circular(UIConstants.smallRadius),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset( 0, 0),
                  blurRadius: 2,
                  spreadRadius: 0.5,
                ),
              ],
            ),
            child: Row(
              children: [
                groupingNameBox(categoryModel == null ? "" : categoryModel.name ),
                const CusVerticalDivider(),
                groupingNameBox(groupModel == null ? "" : groupModel.name),
                const CusVerticalDivider(),
                groupingNameBox(typeModel == null ? "" : typeModel.name),
              ],
            ),
          ),
          Material(
            color: uiController.getpureDirectClr(themeModeType),
            borderRadius: UIConstants.bigBorderRadius,
            elevation: 5,
            child: ClipRRect(
              borderRadius: UIConstants.bigBorderRadius,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Column(
                    children: [
                      Container(
                        height: 40,
                        width: 80,
                        color: Colors.amber,
                        alignment: Alignment.center,
                        child: CusTxtWidget(
                          txt : "${uniqueItemList.length - moreItem}",
                          txtStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage(
                                  "assets/images/icon_min.png"
                              ),
                              fit: BoxFit.contain
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left : UIConstants.mediumSpace,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          CusTxtWidget(
                            txtStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: Colors.grey
                            ),
                            txt: widget.itemModel.name,
                          ),
                          CusTxtWidget(
                            txtStyle: Theme.of(context).textTheme.titleMedium!,
                            txt: "${CalculationFormula.getItemSellPrice(originalPrice: widget.itemModel.originalPrice, profitPrice: widget.itemModel.profitPrice, taxPercentage: widget.itemModel.taxPercentage ?? 0).toInt()} ကျပ်",
                          ),
                          // CusTxtWidget(
                          //   txtStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          //     color: Colors.blue,
                          //   ),
                          //   txt: "Restriction : --",
                          // ),
                          if(promotion != null)PromotionWithItemWidget(promotion: promotion),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CusIconBtn(
                        size: UIConstants.normalNormalIconSize,
                        func: (){
                          // for(int i = 0; i < uniqueItemList.length; i ++){
                          //   cusDebugPrint(uniqueItemList[i].id);
                          // }
                          // cusDebugPrint(moreItem);

                          if((uniqueItemList.length - moreItem) > 0){
                            widget.addFunc(uniqueItemList[moreItem]);
                            setState(() {
                              moreItem ++;
                            });

                          }
                        },
                        clr: Colors.green,
                        icon: Icons.add_circle,
                      ),
                      CusTxtWidget(
                        txtStyle: Theme.of(context).textTheme.titleSmall!,
                        txt: moreItem.toString(),
                      ),
                      CusIconBtn(
                        size: UIConstants.normalNormalIconSize,
                        func: (){

                          if((moreItem > 0)){
                            widget.reduceFunc(widget.itemModel);
                            setState(() {
                              moreItem --;
                            });
                          }
                        },
                        clr: Colors.red,
                        icon: Icons.remove_circle,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

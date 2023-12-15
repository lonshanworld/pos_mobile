import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:pos_mobile/blocs/item_bloc/item_cubit.dart";
import "package:pos_mobile/blocs/theme_bloc/theme_cubit.dart";
import "package:pos_mobile/constants/enums.dart";
import "package:pos_mobile/constants/uiConstants.dart";
import "package:pos_mobile/controller/ui_controller.dart";
import "package:pos_mobile/error_handlers/item_folder/no_selected_id_error_widget.dart";
import "package:pos_mobile/features/cus_showmodelbottomsheet.dart";
import "package:pos_mobile/models/groupingItem_models_folders/group_model.dart";
import "package:pos_mobile/models/groupingItem_models_folders/type_model.dart";
import "package:pos_mobile/models/item_model_folder/item_model.dart";
import "package:pos_mobile/screens/transaction/stockIn/item/create_item_screen.dart";
import "package:pos_mobile/screens/transaction/stockIn/type/create_type_screen.dart";
import 'package:pos_mobile/widgets/itemBox/cusSelectTypeBtn_widget.dart';
import "package:pos_mobile/widgets/btns_folder/cusTxtIconBtn_widget.dart";
import "package:pos_mobile/widgets/itemBox/item_box_widget.dart";
import "package:pos_mobile/widgets/itemBox/stockin_item_appbar_widget.dart";

import "../../../../widgets/itemBox/create_item_btn_widget.dart";


class TypeScreen extends StatefulWidget {

  final int? selectedGroupId;
  final VoidCallback goBackFunc;
  final bool isStorage;

  const TypeScreen({
    super.key,
    required this.selectedGroupId,
    required this.goBackFunc,
    required this.isStorage,
  });

  @override
  State<TypeScreen> createState() => _TypeScreenState();
}

class _TypeScreenState extends State<TypeScreen> {
  int selectedIndex = 0;


  @override
  Widget build(BuildContext context) {
    final UIController uiController = UIController.instance;
    final ThemeModeType themeModeType = context.watch<ThemeCubit>().state.themeModeType;
    final CusShowSheet showSheet = CusShowSheet();

    void startSelectedAgain(){
      if(mounted){
        setState(() {
          selectedIndex= 0;
        });
      }
    }

    return Scaffold(
      body: widget.selectedGroupId == null
        ?
      NoSelectedIdErrorWidget(
        txt: "This group has some error",
        func: widget.goBackFunc,
      )
        :
      BlocBuilder<ItemCubit, ItemState>(
        builder: (context, state) {
          final GroupModel groupModel = context.read<ItemCubit>().getGroup(widget.selectedGroupId!);
          final List<TypeModel> typeList = context.read<ItemCubit>().getSelectedTypeList(widget.selectedGroupId!);
          final TypeModel? typeModel = typeList.isEmpty ? null : context.read<ItemCubit>().getType(typeList[selectedIndex].id);
          final List<ItemModel> itemList = typeList.isEmpty ? [] : context.read<ItemCubit>().getSelectedItemList(typeList[selectedIndex].id);

          return Column(
              children: [
                StockInItemAppBar(
                  txt: "From  ${context.read<ItemCubit>().getGroup(widget.selectedGroupId!).name}",
                  func: widget.goBackFunc,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: UIConstants.smallSpace,
                        ),
                        child: Material(
                          elevation: 5,
                          color: uiController.getpureDirectClr(themeModeType),
                          borderRadius:UIConstants.smallBorderRadius,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              if(widget.isStorage)Padding(
                                padding: const EdgeInsets.only(
                                  left: UIConstants.mediumSpace,
                                ),
                                child: CusTxtIconElevatedBtn(
                                  txt: "Add type",
                                  verticalpadding: 5,
                                  horizontalpadding: 5,
                                  bdrRadius: UIConstants.smallRadius,
                                  bgClr: Colors.grey,
                                  txtStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  txtClr: uiController.getpureOppositeClr(themeModeType),
                                  func: (){
                                    showSheet.showCusBottomSheet(CreateTypeScreen(selectedGroupModel: groupModel,));
                                  },
                                  icon: Icons.add,
                                  iconSize: UIConstants.normalsmallIconSize,
                                ),
                              ),

                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      for(int i = 0; i < typeList.length; i++)Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 3.5
                                        ),
                                        child: CusSelectTypeBtnWidget(
                                          isSelected: i == selectedIndex,
                                          typeModel: typeList[i],
                                          func: (){
                                            setState(() {
                                              selectedIndex = i;
                                            });
                                          },
                                          isStorage : widget.isStorage,
                                          afterDeleteFunc: startSelectedAgain,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              uiController.sizedBox(cusHeight: null, cusWidth: UIConstants.mediumSpace),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          children: [
                            // Positioned(
                            //   top: 0,
                            //   bottom: 0,
                            //   left: 0,
                            //   right: 0,
                            //   child: GridView.builder(
                            //     padding: const EdgeInsets.all(UIConstants.bigSpace),
                            //     itemCount: itemList.length,
                            //     gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            //       maxCrossAxisExtent: 350,
                            //       mainAxisExtent: 120,
                            //       mainAxisSpacing: UIConstants.bigSpace,
                            //       crossAxisSpacing: UIConstants.bigSpace,
                            //     ),
                            //     itemBuilder: (ctx, index){
                            //       return ItemBoxWidget(
                            //         index: index + 1,
                            //         itemModel: itemList[index],
                            //         isStorage: widget.isStorage,
                            //       );
                            //     },
                            //   ),
                            // ),
                            Positioned(
                              top: UIConstants.bigSpace,
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Wrap(
                                spacing: UIConstants.bigSpace,
                                runSpacing: UIConstants.bigSpace,
                                alignment: WrapAlignment.center,
                                children: itemList.map((e) => ItemBoxWidget(
                                    index: itemList.indexOf(e) + 1,
                                    itemModel: e,
                                    isStorage: widget.isStorage
                                )).toList(),
                              ),
                            ),
                            if(typeModel != null && widget.isStorage)CreateItemBtnWidget(
                              txt: "Create Item",
                              widget: CreateItemScreen(typeModel: typeModel),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
        },
      )
      ,
    );
  }
}

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "package:pos_mobile/blocs/item_bloc/item_cubit.dart";
import "package:pos_mobile/error_handlers/item_folder/no_selected_id_error_widget.dart";
import "package:pos_mobile/models/groupingItem_models_folders/category_model.dart";

import "package:pos_mobile/models/groupingItem_models_folders/group_model.dart";

import "package:pos_mobile/screens/transaction/stockIn/group/create_group_screen.dart";
import "package:pos_mobile/widgets/itemBox/create_item_btn_widget.dart";
import "package:pos_mobile/widgets/itemBox/group_box_widget.dart";
import "package:pos_mobile/widgets/itemBox/stockin_item_appbar_widget.dart";
import "package:pos_mobile/widgets/noitem_widget.dart";

import "../../../../constants/uiConstants.dart";




class GroupScreen extends StatelessWidget {

  final int? selectedCategoryId;
  final VoidCallback goBackFunc;
  final Function(int value)setSelectedGroupId;
  final bool isStorage;
  const GroupScreen({
    super.key,
    required this.selectedCategoryId,
    required this.goBackFunc,
    required this.setSelectedGroupId,
    required this.isStorage,
  });

  @override
  Widget build(BuildContext context) {
    // final List<GroupModel> groupList = context.read<ItemCubit>().state.groupList;
    // final List<TypeModel> typeList = context.read<ItemCubit>().state.typeList;



    return Scaffold(
      body: selectedCategoryId == null
          ?
      NoSelectedIdErrorWidget(
        txt: "This category has some error",
        func: goBackFunc,
      )
          :
      BlocBuilder<ItemCubit, ItemState>(
        builder: (context, state) {
          final List<GroupModel> groupList = context.read<ItemCubit>().getSelectedGroupList(selectedCategoryId);
          final CategoryModel categoryModel = context.read<ItemCubit>().getCategory(selectedCategoryId!);

          return Column(
              children: [
                StockInItemAppBar(
                  txt: "Total Group ( ${groupList.length} ) From ${categoryModel.name}",
                  func: goBackFunc,
                ),
                Expanded(
                  child: Stack(
                    children: [
                      if(groupList.isEmpty)const Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: NoItemWidget(
                            noItemTxt: "No group found"
                        ),
                      ),
                      if(groupList.isNotEmpty)Positioned(
                        top: 0,
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: GridView.builder(
                          padding: const EdgeInsets.all(UIConstants.bigSpace),
                          itemCount: groupList.length,
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200,
                            childAspectRatio: 2/1,
                            mainAxisSpacing: UIConstants.bigSpace,
                            crossAxisSpacing: UIConstants.bigSpace,
                          ),
                          itemBuilder: (ctx, index){
                            return GroupBoxWidget(
                              groupModel: groupList[index],
                              typeCount: context.read<ItemCubit>().getSelectedTypeList(groupList[index].id).length,
                              func: (){
                                setSelectedGroupId(groupList[index].id);
                              },
                              isStorage: isStorage,
                            );
                          },
                        ),
                      ),
                      if(isStorage)CreateItemBtnWidget(
                        txt: "Create group",
                        widget: CreateGroupScreen(
                          selectedCategoryModel: categoryModel,
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

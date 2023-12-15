
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:pos_mobile/blocs/item_bloc/item_cubit.dart";
import "package:pos_mobile/constants/uiConstants.dart";
import "package:pos_mobile/models/groupingItem_models_folders/category_model.dart";
import "package:pos_mobile/screens/transaction/stockIn/category/create_category_screen.dart";
import "package:pos_mobile/widgets/cusTxt_widget.dart";
import "package:pos_mobile/widgets/itemBox/category_box_widget.dart";
import "package:pos_mobile/widgets/itemBox/create_item_btn_widget.dart";
import "package:pos_mobile/widgets/noitem_widget.dart";


class CategoryScreen extends StatelessWidget {

  final Function(int value) setSelectedCategoryId;
  final bool isStorage;
  const CategoryScreen({
    super.key,
    required this.setSelectedCategoryId,
    required this.isStorage,
  });

  @override
  Widget build(BuildContext context) {
    final List<CategoryModel> categoryList = context.watch<ItemCubit>().state.activeCategoryList;

    // List<GroupModel> getSelectedGroupList(int? id){
    //   List<GroupModel> newList = [];
    //   for(int a = 0 ; a < groupList.length; a++){
    //     if(id == groupList[a].categoryId){
    //       newList.add(groupList[a]);
    //     }
    //   }
    //   return newList;
    // }
    
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 30,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: UIConstants.bigSpace
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: CusTxtWidget(
                  txtStyle: Theme.of(context).textTheme.titleSmall!,
                  txt: "Total Category ( ${categoryList.length.toString()} )",
                ),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                if(categoryList.isEmpty)const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: NoItemWidget(
                    noItemTxt: "No category found",
                  ),
                ),
                if(categoryList.isNotEmpty)Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(UIConstants.bigSpace),
                    itemCount: categoryList.length,
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 100,
                      childAspectRatio: 1,
                      mainAxisSpacing:0,
                      crossAxisSpacing: 0,
                    ),
                    itemBuilder: (ctx, index){
                      return CategoryBoxWidget(
                        categoryModel: categoryList[index],
                        groupCount: context.read<ItemCubit>().getSelectedGroupList(categoryList[index].id).length,
                        func: (){
                          setSelectedCategoryId(categoryList[index].id);
                        },
                        isStorage : isStorage,
                      );
                    },
                  ),
                ),
                if(isStorage)const CreateItemBtnWidget(
                  txt: "Create category",
                  widget: CreateCategoryScreen(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

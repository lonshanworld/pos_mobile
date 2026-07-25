import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:pos_mobile/blocs/item_bloc/item_cubit.dart";
import "package:pos_mobile/constants/uiConstants.dart";
import "package:pos_mobile/screens/transaction/stockIn/category/create_category_screen.dart";
import "package:pos_mobile/widgets/cusTxt_widget.dart";
import "package:pos_mobile/widgets/itemBox/category_box_widget.dart";
import "package:pos_mobile/widgets/itemBox/create_item_btn_widget.dart";
import "package:pos_mobile/widgets/noitem_widget.dart";
import "package:pos_mobile/constants/business_hierarchy_config.dart";
import "package:pos_mobile/controller/ui_controller.dart";

class CategoryScreen extends StatefulWidget {
  final bool isStorage;
  const CategoryScreen({super.key, required this.isStorage});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      context.read<ItemCubit>().loadMoreCategories();
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryList = context.select(
      (ItemCubit cubit) => cubit.state.activeCategoryList,
    );
    final isLoadingMore = context.select(
      (ItemCubit cubit) => cubit.state.isLoadingMoreCategory,
    );
    final totalCategoryCount = context.select(
      (ItemCubit cubit) => cubit.state.totalCategoryCount,
    );

    final businessType = UIController.instance.businessType;
    final categoryLabel = BusinessHierarchyConfig.getLabel(
      businessType,
      HierarchyLevel.category,
    );
    final categoryPluralLabel = BusinessHierarchyConfig.getPluralLabel(
      businessType,
      HierarchyLevel.category,
    );

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              UIConstants.bigSpace,
              UIConstants.mediumSpace,
              UIConstants.bigSpace,
              UIConstants.smallSpace,
            ),
            child: Row(
              children: [
                const Icon(Icons.grid_view_rounded, color: Colors.grey),
                const SizedBox(width: UIConstants.smallSpace),
                CusTxtWidget(
                  txtStyle: Theme.of(
                    context,
                  ).textTheme.titleSmall!.copyWith(color: Colors.grey),
                  txt:
                      "$totalCategoryCount ${totalCategoryCount == 1 ? categoryLabel : categoryPluralLabel}",
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                if (categoryList.isEmpty)
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: NoItemWidget(noItemTxt: "No item found"),
                  ),
                if (categoryList.isNotEmpty)
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: UIConstants.bigSpace,
                        vertical: UIConstants.smallSpace,
                      ),
                      itemCount: categoryList.length + (isLoadingMore ? 1 : 0),
                      separatorBuilder: (_, index) => const Divider(height: 1),
                      itemBuilder: (ctx, index) {
                        if (index == categoryList.length) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return CategoryBoxWidget(
                          categoryModel: categoryList[index],
                          itemCount: context
                              .read<ItemCubit>()
                              .getItemCountForCategory(categoryList[index].id),
                          func: () {},
                          isStorage: widget.isStorage,
                        );
                      },
                    ),
                  ),
                if (widget.isStorage)
                  CreateItemBtnWidget(
                    txt: "Create $categoryLabel",
                    widget: const CreateCategoryScreen(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

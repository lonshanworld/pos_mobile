import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "package:pos_mobile/blocs/item_bloc/item_cubit.dart";
import "package:pos_mobile/controller/DB_helper.dart";
import "package:pos_mobile/error_handlers/item_folder/no_selected_id_error_widget.dart";
import "package:pos_mobile/models/groupingItem_models_folders/category_model.dart";

import "package:pos_mobile/models/groupingItem_models_folders/group_model.dart";

import "package:pos_mobile/screens/transaction/stockIn/group/create_group_screen.dart";
import "package:pos_mobile/widgets/itemBox/create_item_btn_widget.dart";
import "package:pos_mobile/widgets/itemBox/group_box_widget.dart";
import "package:pos_mobile/widgets/itemBox/stockin_item_appbar_widget.dart";
import "package:pos_mobile/widgets/noitem_widget.dart";

import "../../../../constants/uiConstants.dart";




class GroupScreen extends StatefulWidget {
  final int? selectedCategoryId;
  final VoidCallback goBackFunc;
  final Function(int value) setSelectedGroupId;
  final bool isStorage;
  const GroupScreen({
    super.key,
    required this.selectedCategoryId,
    required this.goBackFunc,
    required this.setSelectedGroupId,
    required this.isStorage,
  });

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  final ScrollController _scrollController = ScrollController();
  late final Future<CategoryModel?> _selectedCategoryFuture;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _selectedCategoryFuture = _loadSelectedCategory();
  }

  Future<CategoryModel?> _loadSelectedCategory() async {
    final int? selectedCategoryId = widget.selectedCategoryId;
    if (selectedCategoryId == null) {
      return null;
    }
    return await DBHelper.getCategoryById(selectedCategoryId);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 500) {
      context.read<ItemCubit>().loadMoreGroups();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.selectedCategoryId == null
          ? NoSelectedIdErrorWidget(
              txt: "This category has some error",
              func: widget.goBackFunc,
            )
          : FutureBuilder<CategoryModel?>(
              future: _selectedCategoryFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                final CategoryModel? categoryModel = snapshot.data;
                if (categoryModel == null) {
                  return NoSelectedIdErrorWidget(
                    txt: "This category has some error",
                    func: widget.goBackFunc,
                  );
                }

                return BlocBuilder<ItemCubit, ItemState>(
                  builder: (context, state) {
                    final List<GroupModel> groupList = context.read<ItemCubit>().getSelectedGroupList(widget.selectedCategoryId);
                    final isLoadingMore = state.isLoadingMoreGroup;
                    final int totalGroupCount = context.read<ItemCubit>().getGroupCountForCategory(widget.selectedCategoryId!);

                    return Column(
                      children: [
                        StockInItemAppBar(
                          txt: "Total Group ( $totalGroupCount ) From ${categoryModel.name}",
                          func: widget.goBackFunc,
                        ),
                        Expanded(
                          child: Stack(
                            children: [
                              if (groupList.isEmpty)
                                const Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: NoItemWidget(noItemTxt: "No group found"),
                                ),
                              if (groupList.isNotEmpty)
                                Positioned(
                                  top: 0,
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: GridView.builder(
                                    controller: _scrollController,
                                    padding: const EdgeInsets.all(UIConstants.bigSpace),
                                    itemCount: groupList.length + (isLoadingMore ? 1 : 0),
                                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 240,
                                      mainAxisExtent: 120,
                                      mainAxisSpacing: UIConstants.mediumSpace,
                                      crossAxisSpacing: UIConstants.mediumSpace,
                                    ),
                                    itemBuilder: (ctx, index) {
                                      if (index == groupList.length) {
                                        return const Center(child: CircularProgressIndicator());
                                      }
                                      return GroupBoxWidget(
                                        groupModel: groupList[index],
                                        typeCount: context.read<ItemCubit>().getTypeCountForGroup(groupList[index].id),
                                        func: () {
                                          widget.setSelectedGroupId(groupList[index].id);
                                        },
                                        isStorage: widget.isStorage,
                                      );
                                    },
                                  ),
                                ),
                              if (widget.isStorage)
                                CreateItemBtnWidget(
                                  txt: "Create group",
                                  widget: CreateGroupScreen(selectedCategoryModel: categoryModel),
                                ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
    );
  }
}
                

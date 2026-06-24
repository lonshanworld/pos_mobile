import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "package:pos_mobile/blocs/item_bloc/item_cubit.dart";
import "package:pos_mobile/models/groupingItem_models_folders/group_model.dart";
import "package:pos_mobile/screens/transaction/stockIn/group/create_group_screen.dart";
import "package:pos_mobile/widgets/itemBox/create_item_btn_widget.dart";
import "package:pos_mobile/widgets/itemBox/group_box_widget.dart";
import "package:pos_mobile/widgets/noitem_widget.dart";
import "package:pos_mobile/constants/business_hierarchy_config.dart";
import "package:pos_mobile/controller/ui_controller.dart";

import "../../../../constants/uiConstants.dart";




class GroupScreen extends StatefulWidget {
  final bool isStorage;
  const GroupScreen({
    super.key,
    required this.isStorage,
  });

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
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
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 500) {
      context.read<ItemCubit>().loadMoreGroups();
    }
  }

  @override
  Widget build(BuildContext context) {
    final businessType = UIController.instance.businessType;
    final groupLabel = BusinessHierarchyConfig.getLabel(businessType, HierarchyLevel.group);

    return Scaffold(
      body: BlocBuilder<ItemCubit, ItemState>(
        builder: (context, state) {
          final List<GroupModel> groupList = state.activeGroupList;
          final isLoadingMore = state.isLoadingMoreGroup;

          return Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    if (groupList.isEmpty)
                      Positioned.fill(
                        child: NoItemWidget(
                          noItemTxt: "No ${groupLabel.toLowerCase()} found",
                        ),
                      ),
                    if (groupList.isNotEmpty)
                      Positioned.fill(
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
                              itemCount: context.read<ItemCubit>().getItemCountForGroup(groupList[index].id),
                              func: () {},
                              isStorage: widget.isStorage,
                            );
                          },
                        ),
                      ),
                    if (widget.isStorage)
                      CreateItemBtnWidget(
                        txt: "Create $groupLabel",
                        widget: const CreateGroupScreen(),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
                

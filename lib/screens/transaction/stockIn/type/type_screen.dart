import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:collection/collection.dart";
import "package:pos_mobile/blocs/item_bloc/item_cubit.dart";
import "package:pos_mobile/blocs/theme_bloc/theme_cubit.dart";
import "package:pos_mobile/constants/enums.dart";
import "package:pos_mobile/constants/uiConstants.dart";
import "package:pos_mobile/controller/DB_helper.dart";
import "package:pos_mobile/controller/ui_controller.dart";
import "package:pos_mobile/error_handlers/item_folder/no_selected_id_error_widget.dart";
import "package:pos_mobile/features/cus_showmodelbottomsheet.dart";
import "package:pos_mobile/models/groupingItem_models_folders/group_model.dart";
import "package:pos_mobile/models/groupingItem_models_folders/type_model.dart";
import "package:pos_mobile/models/item_model_folder/item_model.dart";
import "package:pos_mobile/screens/transaction/stockIn/item/create_item_screen.dart";
import "package:pos_mobile/screens/transaction/stockIn/type/create_type_screen.dart";
import "package:pos_mobile/widgets/btns_folder/cusTxtIconBtn_widget.dart";
import "package:pos_mobile/widgets/itemBox/create_item_btn_widget.dart";
import "package:pos_mobile/widgets/itemBox/cusSelectTypeBtn_widget.dart";
import "package:pos_mobile/widgets/itemBox/item_box_widget.dart";
import "package:pos_mobile/widgets/itemBox/stockin_item_appbar_widget.dart";

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
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  late final Future<GroupModel?> _groupFuture;

  @override
  void initState() {
    super.initState();
    _groupFuture = _loadGroup();
  }

  Future<GroupModel?> _loadGroup() async {
    final int? selectedGroupId = widget.selectedGroupId;
    if (selectedGroupId == null) {
      return null;
    }

    try {
      final GroupModel? groupModel = await DBHelper.getGroupById(selectedGroupId);
      if (groupModel == null) {
        debugPrint('TypeScreen: missing group for groupId=$selectedGroupId');
      }
      return groupModel;
    } catch (err, st) {
      debugPrint('TypeScreen: failed to load group for groupId=$selectedGroupId');
      debugPrint(err.toString());
      debugPrint(st.toString());
      return null;
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UIController uiController = UIController.instance;
    final ThemeModeType themeModeType = context.watch<ThemeCubit>().state.themeModeType;
    final CusShowSheet showSheet = CusShowSheet();

    void startSelectedAgain() {
      if (!mounted) return;
      setState(() {
        selectedIndex = 0;
        searchController.clear();
        searchQuery = "";
      });
    }

    if (widget.selectedGroupId == null) {
      return Scaffold(
        body: NoSelectedIdErrorWidget(
          txt: "This group has some error",
          func: widget.goBackFunc,
        ),
      );
    }

    return FutureBuilder<GroupModel?>(
      future: _groupFuture,
      builder: (context, groupSnapshot) {
        if (groupSnapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final GroupModel? groupModel = groupSnapshot.data;
        if (groupModel == null) {
          return Scaffold(
            body: NoSelectedIdErrorWidget(
              txt: "This group has some error",
              func: widget.goBackFunc,
            ),
          );
        }

        return BlocBuilder<ItemCubit, ItemState>(
          builder: (context, state) {
            final itemCubit = context.read<ItemCubit>();
            final List<TypeModel> typeList = itemCubit.getSelectedTypeList(widget.selectedGroupId!);
            final TypeModel? typeModel = typeList.isEmpty
                ? null
                : itemCubit.state.activeTypeList.firstWhereOrNull((element) => element.id == typeList[selectedIndex].id);
            final List<ItemModel> rawItemList = typeList.isEmpty
                ? []
                : itemCubit.getSelectedItemList(typeList[selectedIndex].id);

            final List<ItemModel> itemList = searchQuery.isEmpty
                ? rawItemList
                : rawItemList
                    .where((item) => item.name.toLowerCase().contains(searchQuery.toLowerCase()))
                    .toList();

            final OutlineInputBorder outlineInputBorder = OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey, width: 1),
              borderRadius: BorderRadius.circular(50),
            );

            return Column(
              children: [
                StockInItemAppBar(
                  txt: "From  ${groupModel.name}",
                  func: widget.goBackFunc,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: UIConstants.bigSpace,
                    vertical: UIConstants.mediumSpace,
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: (val) {
                      setState(() {
                        searchQuery = val.trim();
                      });
                    },
                    decoration: InputDecoration(
                      labelText: "Search Inventory...",
                      labelStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: outlineInputBorder,
                      focusedBorder: outlineInputBorder,
                      enabledBorder: outlineInputBorder,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: UIConstants.bigSpace,
                        vertical: UIConstants.smallSpace,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: UIConstants.smallSpace),
                        child: Container(
                          decoration: BoxDecoration(
                            color: uiController.getpureDirectClr(themeModeType),
                            borderRadius: UIConstants.smallBorderRadius,
                            border: Border.all(
                              color: uiController.getpureOppositeClr(themeModeType).withValues(alpha: 0.1),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              if (widget.isStorage)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: UIConstants.mediumSpace,
                                    vertical: UIConstants.smallSpace,
                                  ),
                                  child: CusTxtIconElevatedBtn(
                                    txt: "Add type",
                                    verticalpadding: 5,
                                    horizontalpadding: UIConstants.mediumSpace,
                                    bdrRadius: UIConstants.mediumRadius,
                                    bgClr: Colors.blueAccent,
                                    txtStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                    txtClr: Colors.white,
                                    func: () {
                                      showSheet.showCusBottomSheet(CreateTypeScreen(selectedGroupModel: groupModel));
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
                                      for (int i = 0; i < typeList.length; i++)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 3.5),
                                          child: CusSelectTypeBtnWidget(
                                            isSelected: i == selectedIndex,
                                            typeModel: typeList[i],
                                            func: () {
                                              setState(() {
                                                selectedIndex = i;
                                              });
                                            },
                                            isStorage: widget.isStorage,
                                            afterDeleteFunc: startSelectedAgain,
                                          ),
                                        ),
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
                          clipBehavior: Clip.none,
                          children: [
                            Positioned.fill(
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final bool isWide = constraints.maxWidth >= 900;
                                  final double bottomReservedSpace = (widget.isStorage && typeModel != null) ? 120 : UIConstants.bigSpace * 2;

                                  return GridView.builder(
                                    padding: EdgeInsets.only(
                                      left: UIConstants.bigSpace,
                                      right: UIConstants.bigSpace,
                                      top: UIConstants.bigSpace,
                                      bottom: bottomReservedSpace,
                                    ),
                                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                                    itemCount: itemList.length,
                                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: isWide ? 360 : 400,
                                      mainAxisExtent: isWide ? 160 : 140,
                                      mainAxisSpacing: UIConstants.bigSpace,
                                      crossAxisSpacing: UIConstants.bigSpace,
                                    ),
                                    itemBuilder: (ctx, index) {
                                      return ItemBoxWidget(
                                        index: index + 1,
                                        itemModel: itemList[index],
                                        isStorage: widget.isStorage,
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            if (typeModel != null && widget.isStorage)
                              CreateItemBtnWidget(
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
        );
      },
    );
  }
}

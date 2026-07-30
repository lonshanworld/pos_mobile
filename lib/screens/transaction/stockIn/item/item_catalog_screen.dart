import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:pos_mobile/blocs/item_bloc/item_cubit.dart";
import "package:pos_mobile/constants/business_hierarchy_config.dart";
import "package:pos_mobile/constants/uiConstants.dart";
import "package:pos_mobile/controller/ui_controller.dart";
import "package:pos_mobile/models/groupingItem_models_folders/category_model.dart";
import "package:pos_mobile/models/groupingItem_models_folders/group_model.dart";
import "package:pos_mobile/models/groupingItem_models_folders/type_model.dart";
import "package:pos_mobile/models/item_model_folder/item_model.dart";
import "package:pos_mobile/screens/transaction/stockIn/item/create_item_screen.dart";
import "package:pos_mobile/widgets/itemBox/create_item_btn_widget.dart";
import "package:pos_mobile/widgets/itemBox/item_box_widget.dart";
import "package:pos_mobile/widgets/noitem_widget.dart";

class ItemCatalogScreen extends StatefulWidget {
  final bool isStorage;

  const ItemCatalogScreen({super.key, required this.isStorage});

  @override
  State<ItemCatalogScreen> createState() => _ItemCatalogScreenState();
}

class _ItemCatalogScreenState extends State<ItemCatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  int? _selectedCategoryId;
  int? _selectedGroupId;
  int? _selectedTypeId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ItemModel> _buildFilteredItems(List<ItemModel> items) {
    final query = _searchController.text.trim().toLowerCase();
    return items.where((item) {
      if (query.isNotEmpty && !item.name.toLowerCase().contains(query)) {
        return false;
      }
      if (_selectedCategoryId != null &&
          item.categoryId != _selectedCategoryId) {
        return false;
      }
      if (_selectedGroupId != null && item.groupId != _selectedGroupId) {
        return false;
      }
      if (_selectedTypeId != null && item.typeId != _selectedTypeId) {
        return false;
      }
      return true;
    }).toList();
  }

  Widget _buildFilterDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T?>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T?>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemState = context.watch<ItemCubit>().state;
    final businessType = UIController.instance.businessType;
    final categoryLabel = BusinessHierarchyConfig.getLabel(
      businessType,
      HierarchyLevel.category,
    );
    final categoryPluralLabel = BusinessHierarchyConfig.getPluralLabel(
      businessType,
      HierarchyLevel.category,
    );
    final groupLabel = BusinessHierarchyConfig.getLabel(
      businessType,
      HierarchyLevel.group,
    );
    final groupPluralLabel = BusinessHierarchyConfig.getPluralLabel(
      businessType,
      HierarchyLevel.group,
    );
    final typeLabel = BusinessHierarchyConfig.getLabel(
      businessType,
      HierarchyLevel.type,
    );
    final typePluralLabel = BusinessHierarchyConfig.getPluralLabel(
      businessType,
      HierarchyLevel.type,
    );
    final itemLabel = BusinessHierarchyConfig.getLabel(
      businessType,
      HierarchyLevel.item,
    );

    final List<CategoryModel> categoryOptions = itemState.allActiveCategoryList;
    final List<GroupModel> groupOptions = itemState.allActiveGroupList;
    final List<TypeModel> typeOptions = itemState.allActiveTypeList;
    final List<ItemModel> filteredItems = _buildFilteredItems(
      itemState.activeItemList,
    );

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(UIConstants.bigSpace),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: "Search $itemLabel",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                  const SizedBox(height: UIConstants.mediumSpace),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFilterDropdown<int>(
                          label: categoryLabel,
                          value: _selectedCategoryId,
                          items: [
                            DropdownMenuItem<int?>(
                              value: null,
                              child: Text("All $categoryPluralLabel"),
                            ),
                            ...categoryOptions.map(
                              (category) => DropdownMenuItem<int?>(
                                value: category.id,
                                child: Text(category.name),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedCategoryId = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: UIConstants.smallSpace),
                      Expanded(
                        child: _buildFilterDropdown<int>(
                          label: groupLabel,
                          value: _selectedGroupId,
                          items: [
                            DropdownMenuItem<int?>(
                              value: null,
                              child: Text("All $groupPluralLabel"),
                            ),
                            ...groupOptions.map(
                              (group) => DropdownMenuItem<int?>(
                                value: group.id,
                                child: Text(group.name),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedGroupId = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: UIConstants.smallSpace),
                      Expanded(
                        child: _buildFilterDropdown<int>(
                          label: typeLabel,
                          value: _selectedTypeId,
                          items: [
                            DropdownMenuItem<int?>(
                              value: null,
                              child: Text("All $typePluralLabel"),
                            ),
                            ...typeOptions.map(
                              (type) => DropdownMenuItem<int?>(
                                value: type.id,
                                child: Text(type.name),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedTypeId = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedCategoryId = null;
                          _selectedGroupId = null;
                          _selectedTypeId = null;
                          _searchController.clear();
                        });
                      },
                      icon: const Icon(Icons.filter_alt_off),
                      label: const Text("Clear"),
                    ),
                  ),
                  Expanded(
                    child: filteredItems.isEmpty
                        ? NoItemWidget(
                            noItemTxt: "No ${itemLabel.toLowerCase()} found",
                          )
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              const cardMaxWidth = 280.0;
                              const spacing = UIConstants.mediumSpace;
                              // Match SliverGridDelegateWithMaxCrossAxisExtent:
                              // only the height is content-driven; card widths
                              // remain the same as the previous grid.
                              final columnCount =
                                  (constraints.maxWidth /
                                          (cardMaxWidth + spacing))
                                      .ceil()
                                      .clamp(1, 4);
                              final cardWidth =
                                  (constraints.maxWidth -
                                      (columnCount - 1) * spacing) /
                                  columnCount;

                              return SingleChildScrollView(
                                padding: const EdgeInsets.only(
                                  bottom: 90,
                                  top: UIConstants.smallSpace,
                                ),
                                child: Wrap(
                                  spacing: spacing,
                                  runSpacing: spacing,
                                  children: [
                                    for (
                                      var index = 0;
                                      index < filteredItems.length;
                                      index++
                                    )
                                      SizedBox(
                                        width: cardWidth,
                                        child: ItemBoxWidget(
                                          index: index,
                                          itemModel: filteredItems[index],
                                          isStorage: widget.isStorage,
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
          if (widget.isStorage)
            CreateItemBtnWidget(
              txt: "Create $itemLabel",
              widget: const CreateItemScreen(),
            ),
        ],
      ),
    );
  }
}

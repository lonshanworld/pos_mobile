import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/blocs/item_bloc/item_cubit.dart';
import 'package:pos_mobile/blocs/shop_info_bloc/shop_info_cubit.dart';
import 'package:pos_mobile/constants/business_hierarchy_config.dart';
import 'package:pos_mobile/constants/uiConstants.dart';
import 'package:pos_mobile/controller/ui_controller.dart';
import 'package:pos_mobile/models/groupingItem_models_folders/category_model.dart';
import 'package:pos_mobile/models/groupingItem_models_folders/group_model.dart';
import 'package:pos_mobile/models/groupingItem_models_folders/type_model.dart';
import 'package:pos_mobile/models/item_model_folder/item_model.dart';
import 'package:pos_mobile/models/item_model_folder/uniqueItem_model.dart';
import 'package:pos_mobile/utils/txt_formatters.dart';

class ItemExpiryScreen extends StatefulWidget {
  const ItemExpiryScreen({super.key});

  @override
  State<ItemExpiryScreen> createState() => _ItemExpiryScreenState();
}

class _ItemExpiryScreenState extends State<ItemExpiryScreen> {
  final ScrollController _scrollController = ScrollController();

  // Filters
  int? selectedCategoryId;
  int? selectedGroupId;
  int? selectedTypeId;

  // Sorting
  bool sortByExpire = true; // true = expire date, false = manufacture date
  bool sortAscending = true;

  // Pagination
  int loadedItemCount = 20;

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
        _scrollController.position.maxScrollExtent - 200) {
      setState(() {
        loadedItemCount += 20;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final uiController = UIController.instance;
    final businessType = context.watch<ShopInfoCubit>().state.businessType;
    final itemState = context.watch<ItemCubit>().state;
    final String catLabel = BusinessHierarchyConfig.getLabel(businessType, HierarchyLevel.category);
    final String grpLabel = BusinessHierarchyConfig.getLabel(businessType, HierarchyLevel.group);
    final String typLabel = BusinessHierarchyConfig.getLabel(businessType, HierarchyLevel.type);

    // 1. Process filters
    List<UniqueItemModel> filteredUnits = itemState.activeUniqueItemList.where((u) {
      if (sortByExpire && u.itemExpireDate == null) return false;
      if (!sortByExpire && u.itemManufactureDate == null) return false;

      // Find item
      final ItemModel item = itemState.activeItemList.firstWhere(
        (i) => i.id == u.itemId,
        orElse: () => itemState.inActiveItemList.firstWhere(
          (i) => i.id == u.itemId,
          orElse: () => itemState.activeItemList.first, // fallback
        ),
      );

      final TypeModel type = itemState.activeTypeList.firstWhere(
        (t) => t.id == item.typeId,
        orElse: () => itemState.inActiveTypeList.firstWhere(
          (t) => t.id == item.typeId,
          orElse: () => itemState.activeTypeList.first,
        ),
      );

      final GroupModel group = itemState.activeGroupList.firstWhere(
        (g) => g.id == type.groupId,
        orElse: () => itemState.inActiveGroupList.firstWhere(
          (g) => g.id == type.groupId,
          orElse: () => itemState.activeGroupList.first,
        ),
      );

      if (selectedCategoryId != null && group.categoryId != selectedCategoryId) return false;
      if (selectedGroupId != null && type.groupId != selectedGroupId) return false;
      if (selectedTypeId != null && item.typeId != selectedTypeId) return false;

      return true;
    }).toList();

    // 2. Sort
    filteredUnits.sort((a, b) {
      final dateA = sortByExpire ? a.itemExpireDate! : a.itemManufactureDate!;
      final dateB = sortByExpire ? b.itemExpireDate! : b.itemManufactureDate!;
      return sortAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
    });

    // 3. Group
    final Map<String, List<UniqueItemModel>> grouped = {};
    for (var u in filteredUnits) {
      final date = sortByExpire ? u.itemExpireDate! : u.itemManufactureDate!;
      final dateStr = TextFormatters.getDate(date);
      grouped.putIfAbsent(dateStr, () => []).add(u);
    }

    // 4. Flatten for pagination
    final List<dynamic> flattened = [];
    for (var entry in grouped.entries) {
      flattened.add(entry.key); // Header string
      flattened.addAll(entry.value); // Items
    }

    final itemsToShow = flattened.take(loadedItemCount).toList();

    // Build filter lists
    List<CategoryModel> categoryList = itemState.activeCategoryList;
    List<GroupModel> groupList = itemState.activeGroupList;
    if (selectedCategoryId != null) {
      groupList = groupList.where((g) => g.categoryId == selectedCategoryId).toList();
    }
    List<TypeModel> typeList = itemState.activeTypeList;
    if (selectedGroupId != null) {
      typeList = typeList.where((t) => t.groupId == selectedGroupId).toList();
    }

    Widget filterDropdown({
      required String hint,
      required int? value,
      required List<dynamic> items,
      required Function(int?) onChanged,
    }) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: DropdownButtonFormField<int>(
            initialValue: value,
            isExpanded: true,
            iconSize: 18,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11.0),
            decoration: InputDecoration(
              labelText: "$hint Filter",
              labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11.0, color: Colors.grey),
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            ),
            items: [
              const DropdownMenuItem<int>(
                value: null,
                child: Text('All'),
              ),
              ...items.map((e) => DropdownMenuItem<int>(
                    value: e.id,
                    child: Text(e.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ))
            ],
            onChanged: onChanged,
          ),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          // Filter section
          Container(
            padding: const EdgeInsets.all(UIConstants.smallSpace),
            color: Theme.of(context).cardTheme.color,
            child: Column(
              children: [
                Row(
                  children: [
                    filterDropdown(
                      hint: catLabel, // Category
                      value: selectedCategoryId,
                      items: categoryList,
                      onChanged: (val) {
                        setState(() {
                          selectedCategoryId = val;
                          selectedGroupId = null;
                          selectedTypeId = null;
                          loadedItemCount = 20;
                        });
                      },
                    ),
                    filterDropdown(
                      hint: grpLabel, // Group
                      value: selectedGroupId,
                      items: groupList,
                      onChanged: (val) {
                        setState(() {
                          selectedGroupId = val;
                          selectedTypeId = null;
                          loadedItemCount = 20;
                        });
                      },
                    ),
                    filterDropdown(
                      hint: typLabel, // Type
                      value: selectedTypeId,
                      items: typeList,
                      onChanged: (val) {
                        setState(() {
                          selectedTypeId = val;
                          loadedItemCount = 20;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<bool>(
                        style: SegmentedButton.styleFrom(
                          textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        ),
                        segments: const [
                          ButtonSegment(value: true, label: Text('Expire Date')),
                          ButtonSegment(value: false, label: Text('Manufacture Date')),
                        ],
                        selected: {sortByExpire},
                        onSelectionChanged: (set) {
                          setState(() {
                            sortByExpire = set.first;
                            loadedItemCount = 20;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
                      onPressed: () {
                        setState(() {
                          sortAscending = !sortAscending;
                          loadedItemCount = 20;
                        });
                      },
                      tooltip: sortAscending ? 'Ascending' : 'Descending',
                    ),
                  ],
                )
              ],
            ),
          ),

          // List section
          Expanded(
            child: itemsToShow.isEmpty
                ? const Center(child: Text("No items found."))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(UIConstants.smallSpace),
                    itemCount: itemsToShow.length,
                    itemBuilder: (context, index) {
                      final item = itemsToShow[index];

                      if (item is String) {
                        // Header
                        return Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 8, left: 8),
                          child: Text(
                            item,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: uiController.accentColor(),
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        );
                      }

                      // Unique Item row
                      final UniqueItemModel uItem = item as UniqueItemModel;
                      final baseItem = itemState.activeItemList.firstWhere(
                        (i) => i.id == uItem.itemId,
                        orElse: () => itemState.inActiveItemList.firstWhere(
                          (i) => i.id == uItem.itemId,
                        ),
                      );

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: UIConstants.smallBorderRadius,
                          side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                        ),
                        child: ListTile(
                          title: Text(baseItem.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("ID: ${uItem.id}  •  Code: ${uItem.code ?? 'None'}"),
                              if (uItem.itemManufactureDate != null)
                                Text("Mfg: ${TextFormatters.getDate(uItem.itemManufactureDate!)}"),
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: uItem.activeStatus ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              uItem.activeStatus ? 'Active' : 'Inactive',
                              style: TextStyle(
                                color: uItem.activeStatus ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

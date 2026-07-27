import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/blocs/item_bloc/item_cubit.dart';
import 'package:pos_mobile/blocs/shop_info_bloc/shop_info_cubit.dart';
import 'package:pos_mobile/constants/business_hierarchy_config.dart';
import 'package:pos_mobile/constants/business_type_utils.dart';
import 'package:pos_mobile/constants/uiConstants.dart';
import 'package:pos_mobile/controller/ui_controller.dart';
import 'package:pos_mobile/models/groupingItem_models_folders/category_model.dart';
import 'package:pos_mobile/models/groupingItem_models_folders/group_model.dart';
import 'package:pos_mobile/models/item_model_folder/item_model.dart';
import 'package:pos_mobile/models/item_model_folder/uniqueItem_model.dart';
import 'package:pos_mobile/utils/txt_formatters.dart';
import 'package:pos_mobile/screens/screen_data_loader.dart';

class ItemExpiryScreen extends StatefulWidget {
  const ItemExpiryScreen({super.key});

  @override
  State<ItemExpiryScreen> createState() => _ItemExpiryScreenState();
}

class _ItemExpiryScreenState extends State<ItemExpiryScreen> {
  final ScrollController _scrollController = ScrollController();

  int? selectedCategoryId;
  int? selectedGroupId;
  int? selectedTypeId;

  bool sortByExpire = true;
  bool sortAscending = true;

  int loadedItemCount = 20;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    unawaited(loadData());
  }

  Future<void> loadData() async {
    await Future.wait([
      ScreenDataLoader.items(context),
      ScreenDataLoader.shopInfo(context),
    ]);
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

    if (!businessType.allowsExpiryTracking) {
      return const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(UIConstants.bigSpace),
            child: Text(
              'Expiry tracking is not available for Clothing & Fashion.',
            ),
          ),
        ),
      );
    }

    final itemState = context.watch<ItemCubit>().state;
    final String catLabel = BusinessHierarchyConfig.getLabel(
      businessType,
      HierarchyLevel.category,
    );
    final String grpLabel = BusinessHierarchyConfig.getLabel(
      businessType,
      HierarchyLevel.group,
    );
    final String typLabel = BusinessHierarchyConfig.getLabel(
      businessType,
      HierarchyLevel.type,
    );

    final List<UniqueItemModel> filteredUnits = itemState.activeUniqueItemList
        .where((u) {
          if (sortByExpire && u.itemExpireDate == null) return false;
          if (!sortByExpire && u.itemManufactureDate == null) return false;

          final ItemModel item = itemState.activeItemList.firstWhere(
            (i) => i.id == u.itemId,
            orElse: () => itemState.inActiveItemList.firstWhere(
              (i) => i.id == u.itemId,
              orElse: () => itemState.activeItemList.first,
            ),
          );

          if (selectedCategoryId != null &&
              item.categoryId != selectedCategoryId) {
            return false;
          }
          if (selectedGroupId != null && item.groupId != selectedGroupId) {
            return false;
          }
          if (selectedTypeId != null && item.typeId != selectedTypeId) {
            return false;
          }

          return true;
        })
        .toList();

    filteredUnits.sort((a, b) {
      final dateA = sortByExpire ? a.itemExpireDate! : a.itemManufactureDate!;
      final dateB = sortByExpire ? b.itemExpireDate! : b.itemManufactureDate!;
      return sortAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
    });

    final Map<String, List<_GroupedExpiryEntry>> grouped = {};
    for (final u in filteredUnits) {
      final date = sortByExpire ? u.itemExpireDate! : u.itemManufactureDate!;
      final dateStr = TextFormatters.getDate(date);
      final ItemModel item = itemState.activeItemList.firstWhere(
        (i) => i.id == u.itemId,
        orElse: () =>
            itemState.inActiveItemList.firstWhere((i) => i.id == u.itemId),
      );

      final entries = grouped.putIfAbsent(dateStr, () => []);
      final existingIndex = entries.indexWhere(
        (entry) =>
            entry.item.id == item.id &&
            entry.manufactureDate == u.itemManufactureDate &&
            entry.expireDate == u.itemExpireDate,
      );

      if (existingIndex >= 0) {
        final current = entries[existingIndex];
        entries[existingIndex] = current.copyWith(
          count: current.count + 1,
          sampleUnit: u,
        );
      } else {
        entries.add(
          _GroupedExpiryEntry(
            item: item,
            sampleUnit: u,
            count: 1,
            manufactureDate: u.itemManufactureDate,
            expireDate: u.itemExpireDate,
          ),
        );
      }
    }

    final List<dynamic> flattened = [];
    for (final entry in grouped.entries) {
      flattened.add(entry.key);
      flattened.addAll(entry.value);
    }

    final itemsToShow = flattened.take(loadedItemCount).toList();

    final List<CategoryModel> categoryList = itemState.activeCategoryList;
    final List<GroupModel> groupList = itemState.activeGroupList;
    final typeList = itemState.activeTypeList;

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
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontSize: 11.0),
            decoration: InputDecoration(
              labelText: "$hint Filter",
              labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 11.0,
                color: Colors.grey,
              ),
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
            ),
            items: [
              const DropdownMenuItem<int>(value: null, child: Text('All')),
              ...items.map(
                (e) => DropdownMenuItem<int>(
                  value: e.id,
                  child: Text(
                    e.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
            onChanged: onChanged,
          ),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(UIConstants.smallSpace),
            color: Theme.of(context).cardTheme.color,
            child: Column(
              children: [
                Row(
                  children: [
                    filterDropdown(
                      hint: catLabel,
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
                      hint: grpLabel,
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
                      hint: typLabel,
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
                          textStyle: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(fontSize: 11),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 0,
                          ),
                        ),
                        segments: const [
                          ButtonSegment(
                            value: true,
                            label: Text('Expire Date'),
                          ),
                          ButtonSegment(
                            value: false,
                            label: Text('Manufacture Date'),
                          ),
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
                      icon: Icon(
                        sortAscending
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                      ),
                      onPressed: () {
                        setState(() {
                          sortAscending = !sortAscending;
                          loadedItemCount = 20;
                        });
                      },
                      tooltip: sortAscending ? 'Ascending' : 'Descending',
                    ),
                  ],
                ),
              ],
            ),
          ),
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
                        return Padding(
                          padding: const EdgeInsets.only(
                            top: 16,
                            bottom: 8,
                            left: 8,
                          ),
                          child: Text(
                            item,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: uiController.accentColor(),
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        );
                      }

                      final groupedItem = item as _GroupedExpiryEntry;
                      final DateTime today = DateTime.now();
                      final DateTime todayDateOnly = DateTime(
                        today.year,
                        today.month,
                        today.day,
                      );
                      final bool isExpired =
                          groupedItem.expireDate != null &&
                          DateTime(
                            groupedItem.expireDate!.year,
                            groupedItem.expireDate!.month,
                            groupedItem.expireDate!.day,
                          ).isBefore(todayDateOnly);

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: isExpired
                            ? Colors.red.withValues(alpha: 0.08)
                            : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: UIConstants.smallBorderRadius,
                          side: BorderSide(
                            color: isExpired
                                ? Colors.red.withValues(alpha: 0.5)
                                : Colors.grey.withValues(alpha: 0.2),
                            width: isExpired ? 1.4 : 1,
                          ),
                        ),
                        child: ListTile(
                          title: Text(
                            groupedItem.item.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (groupedItem.manufactureDate != null)
                                Text(
                                  "Mfg: ${TextFormatters.getDate(groupedItem.manufactureDate!)}",
                                ),
                              if (groupedItem.expireDate != null)
                                Text(
                                  "Exp: ${TextFormatters.getDate(groupedItem.expireDate!)}",
                                ),
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: groupedItem.sampleUnit.activeStatus
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Count: ${groupedItem.count}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  groupedItem.sampleUnit.activeStatus
                                      ? 'Active'
                                      : 'Inactive',
                                  style: TextStyle(
                                    color: groupedItem.sampleUnit.activeStatus
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
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

class _GroupedExpiryEntry {
  final ItemModel item;
  final UniqueItemModel sampleUnit;
  final int count;
  final DateTime? manufactureDate;
  final DateTime? expireDate;

  const _GroupedExpiryEntry({
    required this.item,
    required this.sampleUnit,
    required this.count,
    required this.manufactureDate,
    required this.expireDate,
  });

  _GroupedExpiryEntry copyWith({UniqueItemModel? sampleUnit, int? count}) {
    return _GroupedExpiryEntry(
      item: item,
      sampleUnit: sampleUnit ?? this.sampleUnit,
      count: count ?? this.count,
      manufactureDate: manufactureDate,
      expireDate: expireDate,
    );
  }
}

part of 'item_cubit.dart';

@immutable
abstract class ItemState {
  final List<CategoryModel> activeCategoryList;
  final List<GroupModel> activeGroupList;
  final List<TypeModel> activeTypeList;
  final List<CategoryModel> allActiveCategoryList;
  final List<GroupModel> allActiveGroupList;
  final List<TypeModel> allActiveTypeList;
  final List<ItemModel> activeItemList;
  final List<UniqueItemModel> activeUniqueItemList;
  final List<CategoryModel> inActiveCategoryList;
  final List<GroupModel> inActiveGroupList;
  final List<TypeModel> inActiveTypeList;
  final List<ItemModel> inActiveItemList;
  final List<UniqueItemModel> inActiveUniqueItemList;
  final Map<int, int> categoryGroupCountMap;
  final Map<int, int> groupTypeCountMap;
  final int totalCategoryCount;
  final int categoryOffset;
  final bool hasMoreCategory;
  final bool isLoadingMoreCategory;
  final int groupOffset;
  final bool hasMoreGroup;
  final bool isLoadingMoreGroup;

  const ItemState({
    required this.activeCategoryList,
    required this.activeGroupList,
    required this.activeTypeList,
    required this.allActiveCategoryList,
    required this.allActiveGroupList,
    required this.allActiveTypeList,
    required this.activeItemList,
    required this.activeUniqueItemList,
    required this.inActiveCategoryList,
    required this.inActiveGroupList,
    required this.inActiveTypeList,
    required this.inActiveItemList,
    required this.inActiveUniqueItemList,
    required this.categoryGroupCountMap,
    required this.groupTypeCountMap,
    required this.totalCategoryCount,
    required this.categoryOffset,
    required this.hasMoreCategory,
    required this.isLoadingMoreCategory,
    required this.groupOffset,
    required this.hasMoreGroup,
    required this.isLoadingMoreGroup,
  });
}

class ItemData extends ItemState {
  const ItemData({
    required super.activeCategoryList,
    required super.activeGroupList,
    required super.activeTypeList,
    required super.allActiveCategoryList,
    required super.allActiveGroupList,
    required super.allActiveTypeList,
    required super.activeItemList,
    required super.activeUniqueItemList,
    required super.inActiveCategoryList,
    required super.inActiveGroupList,
    required super.inActiveTypeList,
    required super.inActiveItemList,
    required super.inActiveUniqueItemList,
    required super.categoryGroupCountMap,
    required super.groupTypeCountMap,
    required super.totalCategoryCount,
    required super.categoryOffset,
    required super.hasMoreCategory,
    required super.isLoadingMoreCategory,
    required super.groupOffset,
    required super.hasMoreGroup,
    required super.isLoadingMoreGroup,
  });

  ItemData copyWith({
    List<CategoryModel>? activeCategoryList,
    List<GroupModel>? activeGroupList,
    List<TypeModel>? activeTypeList,
    List<CategoryModel>? allActiveCategoryList,
    List<GroupModel>? allActiveGroupList,
    List<TypeModel>? allActiveTypeList,
    List<ItemModel>? activeItemList,
    List<UniqueItemModel>? activeUniqueItemList,
    List<CategoryModel>? inActiveCategoryList,
    List<GroupModel>? inActiveGroupList,
    List<TypeModel>? inActiveTypeList,
    List<ItemModel>? inActiveItemList,
    List<UniqueItemModel>? inActiveUniqueItemList,
    Map<int, int>? categoryGroupCountMap,
    Map<int, int>? groupTypeCountMap,
    int? totalCategoryCount,
    int? categoryOffset,
    bool? hasMoreCategory,
    bool? isLoadingMoreCategory,
    int? groupOffset,
    bool? hasMoreGroup,
    bool? isLoadingMoreGroup,
  }) {
    return ItemData(
      activeCategoryList: activeCategoryList ?? this.activeCategoryList,
      activeGroupList: activeGroupList ?? this.activeGroupList,
      activeTypeList: activeTypeList ?? this.activeTypeList,
      allActiveCategoryList: allActiveCategoryList ?? this.allActiveCategoryList,
      allActiveGroupList: allActiveGroupList ?? this.allActiveGroupList,
      allActiveTypeList: allActiveTypeList ?? this.allActiveTypeList,
      activeItemList: activeItemList ?? this.activeItemList,
      activeUniqueItemList: activeUniqueItemList ?? this.activeUniqueItemList,
      inActiveCategoryList: inActiveCategoryList ?? this.inActiveCategoryList,
      inActiveGroupList: inActiveGroupList ?? this.inActiveGroupList,
      inActiveTypeList: inActiveTypeList ?? this.inActiveTypeList,
      inActiveItemList: inActiveItemList ?? this.inActiveItemList,
      inActiveUniqueItemList: inActiveUniqueItemList ?? this.inActiveUniqueItemList,
      categoryGroupCountMap: categoryGroupCountMap ?? this.categoryGroupCountMap,
      groupTypeCountMap: groupTypeCountMap ?? this.groupTypeCountMap,
      totalCategoryCount: totalCategoryCount ?? this.totalCategoryCount,
      categoryOffset: categoryOffset ?? this.categoryOffset,
      hasMoreCategory: hasMoreCategory ?? this.hasMoreCategory,
      isLoadingMoreCategory: isLoadingMoreCategory ?? this.isLoadingMoreCategory,
      groupOffset: groupOffset ?? this.groupOffset,
      hasMoreGroup: hasMoreGroup ?? this.hasMoreGroup,
      isLoadingMoreGroup: isLoadingMoreGroup ?? this.isLoadingMoreGroup,
    );
  }
}

part of 'item_cubit.dart';

@immutable
abstract class ItemState {
  final List<CategoryModel> activeCategoryList;
  final List<GroupModel> activeGroupList;
  final List<TypeModel> activeTypeList;
  final List<ItemModel> activeItemList;
  final List<UniqueItemModel> activeUniqueItemList;
  final List<CategoryModel> inActiveCategoryList;
  final List<GroupModel> inActiveGroupList;
  final List<TypeModel> inActiveTypeList;
  final List<ItemModel> inActiveItemList;
  final List<UniqueItemModel> inActiveUniqueItemList;

  const ItemState({
    required this.activeCategoryList,
    required this.activeGroupList,
    required this.activeTypeList,
    required this.activeItemList,
    required this.activeUniqueItemList,
    required this.inActiveCategoryList,
    required this.inActiveGroupList,
    required this.inActiveTypeList,
    required this.inActiveItemList,
    required this.inActiveUniqueItemList,
  });
}

class ItemData extends ItemState {
  const ItemData({required super.activeCategoryList, required super.activeGroupList, required super.activeTypeList, required super.activeItemList, required super.activeUniqueItemList, required super.inActiveCategoryList, required super.inActiveGroupList, required super.inActiveTypeList, required super.inActiveItemList, required super.inActiveUniqueItemList});
}

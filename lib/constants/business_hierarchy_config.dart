import 'package:pos_mobile/constants/enums.dart';

enum HierarchyLevel {
  category,
  group,
  type,
  item,
}

class BusinessHierarchyConfig {
  static const Map<BusinessType, Map<HierarchyLevel, String>> _config = {
    BusinessType.general: {
      HierarchyLevel.category: 'Category',
      HierarchyLevel.group: 'Group',
      HierarchyLevel.type: 'Type',
      HierarchyLevel.item: 'Item',
    },
    BusinessType.clothing: {
      HierarchyLevel.category: 'Category',
      HierarchyLevel.group: 'Brand',
      HierarchyLevel.type: 'Design',
      HierarchyLevel.item: 'Item',
    },
    BusinessType.electronics: {
      HierarchyLevel.category: 'Device Type',
      HierarchyLevel.group: 'Brand',
      HierarchyLevel.type: 'Model',
      HierarchyLevel.item: 'Item',
    },
    BusinessType.grocery: {
      HierarchyLevel.category: 'Category',
      HierarchyLevel.group: 'Sub-Category',
      HierarchyLevel.type: 'Brand',
      HierarchyLevel.item: 'Item',
    },
    BusinessType.convenience: {
      HierarchyLevel.category: 'Category',
      HierarchyLevel.group: 'Sub-Category',
      HierarchyLevel.type: 'Brand',
      HierarchyLevel.item: 'Item',
    },
    BusinessType.basicPharmacy: {
      HierarchyLevel.category: 'Category',
      HierarchyLevel.group: 'Brand',
      HierarchyLevel.type: 'Sub-Category',
      HierarchyLevel.item: 'Item',
    },
    BusinessType.phoneLaptopTablets: {
      HierarchyLevel.category: 'Brand',
      HierarchyLevel.group: 'Type',
      HierarchyLevel.type: 'Series',
      HierarchyLevel.item: 'Item',
    },
    BusinessType.food: {
      HierarchyLevel.category: 'Category',
      HierarchyLevel.group: 'Sub-Category',
      HierarchyLevel.type: 'Menu',
      HierarchyLevel.item: 'Item',
    },
  };

  static String getLabel(BusinessType businessType, HierarchyLevel level) {
    return _config[businessType]?[level] ?? _config[BusinessType.general]![level]!;
  }

  static String getPluralLabel(BusinessType businessType, HierarchyLevel level) {
    final singular = getLabel(businessType, level);
    switch (singular) {
      case 'Category':
        return 'Categories';
      case 'Sub-Category':
        return 'Sub-Categories';
      case 'Brand':
        return 'Brands';
      case 'Device Type':
        return 'Device Types';
      case 'Design':
        return 'Designs';
      case 'Condition':
        return 'Conditions';
      case 'Type':
        return 'Types';
      case 'Model':
        return 'Models';
      case 'Series':
        return 'Series';
      case 'Menu':
        return 'Menus';
      case 'Group':
        return 'Groups';
      case 'Item':
        return 'Items';
      default:
        return '${singular}s';
    }
  }
}

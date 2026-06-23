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
      HierarchyLevel.category: 'Category',
      HierarchyLevel.group: 'Sub-Category',
      HierarchyLevel.type: 'Brand',
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
      HierarchyLevel.group: 'Condition',
      HierarchyLevel.type: 'Type',
      HierarchyLevel.item: 'Item',
    },
    BusinessType.phoneLaptopTablets: {
      HierarchyLevel.category: 'Category',
      HierarchyLevel.group: 'Brand',
      HierarchyLevel.type: 'Model',
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
}

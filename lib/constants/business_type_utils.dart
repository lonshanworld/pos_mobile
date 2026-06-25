import 'package:flutter/material.dart';
import 'package:pos_mobile/constants/enums.dart';

BusinessType businessTypeFromStorage(String? value) {
  if (value == null || value.isEmpty) return BusinessType.general;
  try {
    return BusinessType.values.byName(value);
  } catch (_) {
    return BusinessType.general;
  }
}

extension BusinessTypeExtension on BusinessType {
  bool get allowsThemeToggle => this == BusinessType.general;

  bool get allowsExpiryTracking =>
      this != BusinessType.clothing &&
      this != BusinessType.electronics &&
      this != BusinessType.phoneLaptopTablets;

  String get displayName {
    switch (this) {
      case BusinessType.general:
        return 'General Retail';
      case BusinessType.clothing:
        return 'Clothing & Fashion';
      case BusinessType.electronics:
        return 'Electronics';
      case BusinessType.grocery:
        return 'Grocery';
      case BusinessType.convenience:
        return 'Convenience Store';
      case BusinessType.basicPharmacy:
        return 'Pharmacy';
      case BusinessType.phoneLaptopTablets:
        return 'Mobile Phones / Laptops / Tablets';
      case BusinessType.food:
        return 'Food & Beverage';
    }
  }

  String get shortDescription {
    switch (this) {
      case BusinessType.general:
        return 'Standard inventory POS flow';
      case BusinessType.clothing:
        return 'Colors, sizes & measurement-based pricing';
      case BusinessType.electronics:
        return 'Brand, specs & device details';
      case BusinessType.grocery:
        return 'Weight, expiry & fresh produce tracking';
      case BusinessType.convenience:
        return 'Barcode, pack size & quick checkout';
      case BusinessType.basicPharmacy:
        return 'Dosage, batch & expiry compliance';
      case BusinessType.phoneLaptopTablets:
        return 'Mobile Phones / Laptops / Tablets';
      case BusinessType.food:
        return 'Menu items, made-to-order & pre-stocked food';
    }
  }

  IconData get icon {
    switch (this) {
      case BusinessType.general:
        return Icons.storefront_outlined;
      case BusinessType.clothing:
        return Icons.checkroom_outlined;
      case BusinessType.electronics:
        return Icons.devices_outlined;
      case BusinessType.grocery:
        return Icons.local_grocery_store_outlined;
      case BusinessType.convenience:
        return Icons.local_convenience_store_outlined;
      case BusinessType.basicPharmacy:
        return Icons.medical_services_outlined;
      case BusinessType.phoneLaptopTablets:
        return Icons.phone_android_outlined;
      case BusinessType.food:
        return Icons.restaurant_outlined;
    }
  }
}

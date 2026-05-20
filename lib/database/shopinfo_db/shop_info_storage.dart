import 'package:get_storage/get_storage.dart';

import '../../constants/txtconstants.dart';

class ShopInfoStorage {
  ShopInfoStorage._();

  static const String _shopNameKey = 'shopInfo_shopName';
  static const String _shopAddressKey = 'shopInfo_shopAddress';
  static const String _phNumKey = 'shopInfo_phNum';
  static const String _noReturnNoteKey = 'shopInfo_noReturnNote';
  static const String _logoPathKey = 'shopInfo_logoPath';
  static const String _logoSizeRatioKey = 'shopInfo_logoSizeRatio';

  final GetStorage _box = GetStorage();

  static final ShopInfoStorage instance = ShopInfoStorage._();

  String getShopName() => _box.read(_shopNameKey) ?? TxtConstants.shopName;
  String getShopAddress() => _box.read(_shopAddressKey) ?? TxtConstants.shopAddress;
  String getPhNum() => _box.read(_phNumKey) ?? TxtConstants.phNum;
  String getNoReturnNote() => _box.read(_noReturnNoteKey) ?? TxtConstants.noReturnNote;
  String? getLogoPath() => _box.read(_logoPathKey);
  double getLogoSizeRatio() => (_box.read(_logoSizeRatioKey) as double?) ?? 1.0;

  Future<void> saveShopName(String value) => _box.write(_shopNameKey, value);
  Future<void> saveShopAddress(String value) => _box.write(_shopAddressKey, value);
  Future<void> savePhNum(String value) => _box.write(_phNumKey, value);
  Future<void> saveNoReturnNote(String value) => _box.write(_noReturnNoteKey, value);
  Future<void> saveLogoPath(String? value) => _box.write(_logoPathKey, value);
  Future<void> saveLogoSizeRatio(double value) => _box.write(_logoSizeRatioKey, value);
}

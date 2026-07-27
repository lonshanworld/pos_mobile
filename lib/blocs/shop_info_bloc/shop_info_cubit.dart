import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';

import '../../constants/enums.dart';
import '../../database/shopinfo_db/shop_info_storage.dart';
import '../../controller/ui_controller.dart';
import '../../services/network_environment.dart';
import '../../services/pos_repository.dart';

part 'shop_info_state.dart';

class ShopInfoCubit extends Cubit<ShopInfoState> {
  final ShopInfoStorage _storage = ShopInfoStorage.instance;

  ShopInfoCubit()
    : super(
        ShopInfoState(
          shopName: ShopInfoStorage.instance.getShopName(),
          shopAddress: ShopInfoStorage.instance.getShopAddress(),
          phNum: ShopInfoStorage.instance.getPhNum(),
          noReturnNote: ShopInfoStorage.instance.getNoReturnNote(),
          logoPath: ShopInfoStorage.instance.getLogoPath(),
          logoSizeRatio: ShopInfoStorage.instance.getLogoSizeRatio(),
          businessType: ShopInfoStorage.instance.getBusinessType(),
          includeQrCode: ShopInfoStorage.instance.getIncludeQrCode(),
          includeLogo: ShopInfoStorage.instance.getIncludeLogo(),
          taxEnabled: ShopInfoStorage.instance.getTaxEnabled(),
          itemTaxEnabled: ShopInfoStorage.instance.getItemTaxEnabled(),
          checkoutTaxEnabled: ShopInfoStorage.instance.getCheckoutTaxEnabled(),
          checkoutTaxPercentage: ShopInfoStorage.instance
              .getCheckoutTaxPercentage(),
        ),
      ) {
    UIController.instance.businessType = state.businessType;
  }

  Future<void> reloadRemoteSettings() => _refreshRemoteSettings();

  Future<void> _refreshRemoteSettings() async {
    if (!NetworkConfiguration.usesBackend) return;
    try {
      final settings = await PosRepository.instance.fetchSettings();
      final values = <String, String?>{
        for (final setting in settings)
          setting['key'] as String: setting['value']?.toString(),
      };
      final logoSetting = settings.firstWhereOrNull(
        (setting) => setting['key'] == 'shopInfo_logoPath',
      );
      final logoPath = logoSetting == null
          ? null
          : (logoSetting['image_url'] ?? logoSetting['value'])?.toString();
      final businessType = values['businessType'];
      if (values['shopInfo_shopName'] != null) {
        await _storage.saveShopName(values['shopInfo_shopName']!);
      }
      if (values['shopInfo_shopAddress'] != null) {
        await _storage.saveShopAddress(values['shopInfo_shopAddress']!);
      }
      if (values['shopInfo_phNum'] != null) {
        await _storage.savePhNum(values['shopInfo_phNum']!);
      }
      if (values['shopInfo_noReturnNote'] != null) {
        await _storage.saveNoReturnNote(values['shopInfo_noReturnNote']!);
      }
      if (values['shopInfo_taxEnabled'] != null) {
        await _storage.saveTaxEnabled(values['shopInfo_taxEnabled'] == 'true');
      }
      if (values['shopInfo_itemTaxEnabled'] != null) {
        await _storage.saveItemTaxEnabled(
          values['shopInfo_itemTaxEnabled'] == 'true',
        );
      }
      if (values['shopInfo_checkoutTaxEnabled'] != null) {
        await _storage.saveCheckoutTaxEnabled(
          values['shopInfo_checkoutTaxEnabled'] == 'true',
        );
      }
      if (values['shopInfo_checkoutTaxPercentage'] != null) {
        final tax = double.tryParse(values['shopInfo_checkoutTaxPercentage']!);
        if (tax != null) await _storage.saveCheckoutTaxPercentage(tax);
      }
      if (values.containsKey('shopInfo_logoPath')) {
        await _storage.saveLogoPath(logoPath);
      }
      if (values['shopInfo_logoSizeRatio'] != null) {
        final ratio = double.tryParse(values['shopInfo_logoSizeRatio']!);
        if (ratio != null) await _storage.saveLogoSizeRatio(ratio);
      }
      if (values['shopInfo_includeQrCode'] != null) {
        await _storage.saveIncludeQrCode(
          values['shopInfo_includeQrCode'] == 'true',
        );
      }
      if (values['shopInfo_includeLogo'] != null) {
        await _storage.saveIncludeLogo(
          values['shopInfo_includeLogo'] != 'false',
        );
      }
      if (businessType != null) {
        final parsed = BusinessType.values
            .where((item) => item.name == businessType)
            .firstOrNull;
        if (parsed != null) await _storage.saveBusinessType(parsed);
      }
      emit(
        state.copyWith(
          shopName: _storage.getShopName(),
          shopAddress: _storage.getShopAddress(),
          phNum: _storage.getPhNum(),
          noReturnNote: _storage.getNoReturnNote(),
          taxEnabled: _storage.getTaxEnabled(),
          itemTaxEnabled: _storage.getItemTaxEnabled(),
          checkoutTaxEnabled: _storage.getCheckoutTaxEnabled(),
          checkoutTaxPercentage: _storage.getCheckoutTaxPercentage(),
          businessType: _storage.getBusinessType(),
          logoPath: _storage.getLogoPath(),
        ),
      );
      UIController.instance.businessType = state.businessType;
    } catch (_) {
      // Cached settings remain authoritative until the next connectivity retry.
    }
  }

  Future<void> updateShopName(String value) async {
    await _persist(
      'shopInfo_shopName',
      value,
      () => _storage.saveShopName(value),
    );
    emit(state.copyWith(shopName: value));
  }

  Future<void> updateShopAddress(String value) async {
    await _persist(
      'shopInfo_shopAddress',
      value,
      () => _storage.saveShopAddress(value),
    );
    emit(state.copyWith(shopAddress: value));
  }

  Future<void> updatePhNum(String value) async {
    await _persist('shopInfo_phNum', value, () => _storage.savePhNum(value));
    emit(state.copyWith(phNum: value));
  }

  Future<void> updateNoReturnNote(String value) async {
    await _persist(
      'shopInfo_noReturnNote',
      value,
      () => _storage.saveNoReturnNote(value),
    );
    emit(state.copyWith(noReturnNote: value));
  }

  Future<void> updateLogoPath(String? path) async {
    await _persist(
      'shopInfo_logoPath',
      path,
      () => _storage.saveLogoPath(path),
    );
    if (path == null) {
      emit(state.copyWith(clearLogoPath: true));
    } else {
      emit(state.copyWith(logoPath: path));
    }
  }

  /// Updates only the local cache for a hybrid upload that is waiting in the
  /// outbox. The device path/data URL must never be sent as a server setting.
  Future<void> setLocalLogoPath(String path) async {
    await _storage.saveLogoPath(path);
    emit(state.copyWith(logoPath: path));
  }

  Future<void> updateLogoSizeRatio(double ratio) async {
    await _persist(
      'shopInfo_logoSizeRatio',
      ratio,
      () => _storage.saveLogoSizeRatio(ratio),
    );
    emit(state.copyWith(logoSizeRatio: ratio));
  }

  Future<void> updateBusinessType(BusinessType value) async {
    await _persist(
      'businessType',
      value.name,
      () => _storage.saveBusinessType(value),
    );
    UIController.instance.businessType = value;
    emit(state.copyWith(businessType: value));
  }

  Future<void> updateIncludeQrCode(bool value) async {
    await _persist(
      'shopInfo_includeQrCode',
      value,
      () => _storage.saveIncludeQrCode(value),
    );
    emit(state.copyWith(includeQrCode: value));
  }

  Future<void> updateIncludeLogo(bool value) async {
    await _persist(
      'shopInfo_includeLogo',
      value,
      () => _storage.saveIncludeLogo(value),
    );
    emit(state.copyWith(includeLogo: value));
  }

  Future<void> updateTaxEnabled(bool value) async {
    await _persist(
      'shopInfo_taxEnabled',
      value,
      () => _storage.saveTaxEnabled(value),
    );
    emit(state.copyWith(taxEnabled: value));
  }

  Future<void> updateItemTaxEnabled(bool value) async {
    await _persist(
      'shopInfo_itemTaxEnabled',
      value,
      () => _storage.saveItemTaxEnabled(value),
    );
    emit(state.copyWith(itemTaxEnabled: value));
  }

  Future<void> updateCheckoutTaxEnabled(bool value) async {
    await _persist(
      'shopInfo_checkoutTaxEnabled',
      value,
      () => _storage.saveCheckoutTaxEnabled(value),
    );
    emit(state.copyWith(checkoutTaxEnabled: value));
  }

  Future<void> updateCheckoutTaxPercentage(double value) async {
    await _persist(
      'shopInfo_checkoutTaxPercentage',
      value,
      () => _storage.saveCheckoutTaxPercentage(value),
    );
    emit(state.copyWith(checkoutTaxPercentage: value));
  }

  Future<void> _persist(
    String key,
    Object? value,
    Future<void> Function() localWrite,
  ) async {
    await PosRepository.instance.writeWithMode(
      local: () async {},
      remote: () => PosRepository.instance.saveSetting(key, value?.toString()),
    );
    await localWrite();
  }
}

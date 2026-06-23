import 'package:flutter_bloc/flutter_bloc.dart';

import '../../constants/enums.dart';
import '../../database/shopinfo_db/shop_info_storage.dart';
import '../../controller/ui_controller.dart';

part 'shop_info_state.dart';

class ShopInfoCubit extends Cubit<ShopInfoState> {
  final ShopInfoStorage _storage = ShopInfoStorage.instance;

  ShopInfoCubit()
      : super(ShopInfoState(
          shopName: ShopInfoStorage.instance.getShopName(),
          shopAddress: ShopInfoStorage.instance.getShopAddress(),
          phNum: ShopInfoStorage.instance.getPhNum(),
          noReturnNote: ShopInfoStorage.instance.getNoReturnNote(),
          logoPath: ShopInfoStorage.instance.getLogoPath(),
          logoSizeRatio: ShopInfoStorage.instance.getLogoSizeRatio(),
          businessType: ShopInfoStorage.instance.getBusinessType(),
          includeQrCode: ShopInfoStorage.instance.getIncludeQrCode(),
          includeLogo: ShopInfoStorage.instance.getIncludeLogo(),
        )) {
    UIController.instance.businessType = state.businessType;
  }

  Future<void> updateShopName(String value) async {
    await _storage.saveShopName(value);
    emit(state.copyWith(shopName: value));
  }

  Future<void> updateShopAddress(String value) async {
    await _storage.saveShopAddress(value);
    emit(state.copyWith(shopAddress: value));
  }

  Future<void> updatePhNum(String value) async {
    await _storage.savePhNum(value);
    emit(state.copyWith(phNum: value));
  }

  Future<void> updateNoReturnNote(String value) async {
    await _storage.saveNoReturnNote(value);
    emit(state.copyWith(noReturnNote: value));
  }

  Future<void> updateLogoPath(String? path) async {
    await _storage.saveLogoPath(path);
    if (path == null) {
      emit(state.copyWith(clearLogoPath: true));
    } else {
      emit(state.copyWith(logoPath: path));
    }
  }

  Future<void> updateLogoSizeRatio(double ratio) async {
    await _storage.saveLogoSizeRatio(ratio);
    emit(state.copyWith(logoSizeRatio: ratio));
  }

  Future<void> updateBusinessType(BusinessType value) async {
    await _storage.saveBusinessType(value);
    UIController.instance.businessType = value;
    emit(state.copyWith(businessType: value));
  }

  Future<void> updateIncludeQrCode(bool value) async {
    await _storage.saveIncludeQrCode(value);
    emit(state.copyWith(includeQrCode: value));
  }

  Future<void> updateIncludeLogo(bool value) async {
    await _storage.saveIncludeLogo(value);
    emit(state.copyWith(includeLogo: value));
  }
}

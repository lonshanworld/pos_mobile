import 'package:flutter_bloc/flutter_bloc.dart';

import '../../database/shopinfo_db/shop_info_storage.dart';

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
        ));

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
}

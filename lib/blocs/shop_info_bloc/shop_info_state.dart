part of 'shop_info_cubit.dart';

class ShopInfoState {
  final String shopName;
  final String shopAddress;
  final String phNum;
  final String noReturnNote;
  final String? logoPath;
  final double logoSizeRatio;

  const ShopInfoState({
    required this.shopName,
    required this.shopAddress,
    required this.phNum,
    required this.noReturnNote,
    required this.logoPath,
    required this.logoSizeRatio,
  });

  ShopInfoState copyWith({
    String? shopName,
    String? shopAddress,
    String? phNum,
    String? noReturnNote,
    String? logoPath,
    bool clearLogoPath = false,
    double? logoSizeRatio,
  }) {
    return ShopInfoState(
      shopName: shopName ?? this.shopName,
      shopAddress: shopAddress ?? this.shopAddress,
      phNum: phNum ?? this.phNum,
      noReturnNote: noReturnNote ?? this.noReturnNote,
      logoPath: clearLogoPath ? null : (logoPath ?? this.logoPath),
      logoSizeRatio: logoSizeRatio ?? this.logoSizeRatio,
    );
  }
}

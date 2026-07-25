part of 'shop_info_cubit.dart';

class ShopInfoState {
  final String shopName;
  final String shopAddress;
  final String phNum;
  final String noReturnNote;
  final String? logoPath;
  final double logoSizeRatio;
  final BusinessType businessType;
  final bool includeQrCode;
  final bool includeLogo;
  final bool taxEnabled;
  final bool itemTaxEnabled;
  final bool checkoutTaxEnabled;
  final double checkoutTaxPercentage;

  const ShopInfoState({
    required this.shopName,
    required this.shopAddress,
    required this.phNum,
    required this.noReturnNote,
    required this.logoPath,
    required this.logoSizeRatio,
    required this.businessType,
    this.includeQrCode = false,
    this.includeLogo = true,
    this.taxEnabled = true,
    this.itemTaxEnabled = true,
    this.checkoutTaxEnabled = true,
    this.checkoutTaxPercentage = 0,
  });

  ShopInfoState copyWith({
    String? shopName,
    String? shopAddress,
    String? phNum,
    String? noReturnNote,
    String? logoPath,
    bool clearLogoPath = false,
    double? logoSizeRatio,
    BusinessType? businessType,
    bool? includeQrCode,
    bool? includeLogo,
    bool? taxEnabled,
    bool? itemTaxEnabled,
    bool? checkoutTaxEnabled,
    double? checkoutTaxPercentage,
  }) {
    return ShopInfoState(
      shopName: shopName ?? this.shopName,
      shopAddress: shopAddress ?? this.shopAddress,
      phNum: phNum ?? this.phNum,
      noReturnNote: noReturnNote ?? this.noReturnNote,
      logoPath: clearLogoPath ? null : (logoPath ?? this.logoPath),
      logoSizeRatio: logoSizeRatio ?? this.logoSizeRatio,
      businessType: businessType ?? this.businessType,
      includeQrCode: includeQrCode ?? this.includeQrCode,
      includeLogo: includeLogo ?? this.includeLogo,
      taxEnabled: taxEnabled ?? this.taxEnabled,
      itemTaxEnabled: itemTaxEnabled ?? this.itemTaxEnabled,
      checkoutTaxEnabled: checkoutTaxEnabled ?? this.checkoutTaxEnabled,
      checkoutTaxPercentage:
          checkoutTaxPercentage ?? this.checkoutTaxPercentage,
    );
  }
}

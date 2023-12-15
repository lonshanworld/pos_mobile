import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:pos_mobile/models/papersize_model.dart';

enum UserLevel{
  staff,
  admin,
  superAdmin,
}

enum ThemeModeType{
  dark,
  light,
}

enum ShoppingType{
  shop,
  online,
  delivery,
}

enum PaymentMethod{
  cash,
  onlineCash,
}

enum ModelType{
  category,
  group,
  type,
  item,
  uniqueItem,
  promotion,
  restriction,
  stockIn,
  stockOut,
  userModel,
  report,
  alert,
}

enum TargetProductType{
  category,
  group,
  type,
  item,
}

enum UpdateType{
  create,
  update,
  delete,
  orderCancel,
}

enum LoadingStatus{
  loading,
  success,
  fail,
}


enum TargetAudienceType{
  allStaffs,
  allAdmins,
  everyone,
  specific,
}

enum ImportanceLevel{
  urgent,
  high,
  moderate,
  low,
}


enum BluetoothConnection{
  disconnected,
  connected,
  connecting
}

List<PaperSizeModel> paperSizeList = [
  PaperSizeModel(paperSize: PaperSize.mm58, sizeName: "Small"),
  PaperSizeModel(paperSize: PaperSize.mm72, sizeName: "Medium"),
  PaperSizeModel(paperSize: PaperSize.mm80, sizeName: "Large"),
];


enum SetPromotion{
  percentage,
  mmk,
}
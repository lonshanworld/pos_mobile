import '../models/user_model_folder/user_model.dart';
import 'enums.dart';

class TxtConstants{

  static final UserModel superAdminModelData = UserModel(
    id: -1,
    userName: "superAdmin",
    password: "superAdmin123",
    userLevel: UserLevel.superAdmin,
    userCreatedTime: DateTime.now(),
    activeStatus: true,
    imageId: null,
    userLoginTime: DateTime.now(),
    userLogoutTime: null,
  );

  static const String themeDbKey = "THEME_DB";



  // TODO : plase change name for each store
  static const String databaseKey = "MEPOSMOBILEDB";



  //tableName
  static const String userTableName = "userTable";

  static const String categoryTableName = "categoryTable";
  static const String groupTableName = "groupTable";
  static const String typeTableName = "typeTable";
  static const String itemTableName = "itemTable";
  static const String uniqueItemTableName = "uniqueItemTable";
  static const String moduleComponentItemTableName = "moduleComponentItemTable";

  static const String restrictionTableName = "restrictionTable";

  static const String imageTableName = "imageTable";

  static const String promotionTableName = "promotionTable";

  static const String stockOutTableName = "stockOutTable";
  static const String stockOutItemTableName = "stockOutItemTable";
  static const String stockInTableName = "stockInTable";

  static const String historyTableName = "historyTable";

  static const String alertTableName ="alertTable";
  static const String reportTableName = "reportTable";

  static const String customerTableName = "customerTable";
  static const String deliveryPersonTableName = "deliveryPersonTable";
  static const String deliveryModelTableName = "deliveryModelTable";




  //junction tableName
  static const String itemPromotionTableName = "itemPromotionTable";
  static const String stockOutPromotionTableName = "stockOutPromotionTable";
  static const String typePromotionTableName = "typePromotionTable";

  static const String reportImageTableName = "reportImageTable";
  static const String reportTargetPersonTableName = "reportTargetPersonTable";
  static const String reportTargetProductTableName = "reportTargetProductTable";

  static const String alertKnownPersonTableName = "alertKnowPersonTable";
  static const String alertTargetPersonTableName = "alertTargetPersonTable";
  static const String alertTargetProductTableName ="alertTargetProductTable";

  static const String shopAddress = "အမှတ်(007)၊ ဘုရင့်နောင်တာဝါ 2(A)၊ ဘုရင်နောင်လမ်း၊ သင်္ဘောကျင်းမှတ်တိုင်၊ ကမာရွတ်မြို့နယ်";
  static const String phNum = "09-768 032 076";
  static const String noReturnNote = "ဝယ်ပြီးပစ္စည်း ပြန်မလဲပေးပါ";

  static const String printerFontSizeKey = "PrinterFontSize";
}
import 'package:flutter/widgets.dart';
import 'app_language.dart';

class AppStrings {
  final AppLanguage locale;
  const AppStrings(this.locale);

  static AppStrings of(BuildContext context) =>
      AppStrings(LanguageCubit.of(context));

  String get settings => _t('Settings', 'ဆက်တင်များ', 'การตั้งค่า');
  String get managePreferences => _t(
        'Manage your preferences and configuration',
        'သင့်နှစ်သက်မှုများနှင့် ပြင်ဆင်ချက်များကို စီမံရန်',
        'จัดการการตั้งค่าและการกำหนดค่าของคุณ',
      );
  String get printerSettings => _t('Printer Settings', 'ပရင်တာ ဆက်တင်များ', 'การตั้งค่าเครื่องพิมพ์');
  String get generalSettings => _t('General Settings', 'အထွေထွေ ဆက်တင်များ', 'การตั้งค่าทั่วไป');
  String get language => _t('Language', 'ဘာသာစကား', 'ภาษา');
  String get languageDescription => _t(
        'Choose the language used throughout the app',
        'အက်ပ်တွင် အသုံးပြုမည့် ဘာသာစကားကို ရွေးချယ်ပါ',
        'เลือกภาษาที่ใช้ในแอป',
      );
  String get connected => _t('Connected', 'ချိတ်ဆက်ထားသည်', 'เชื่อมต่อแล้ว');
  String get noPrinterConnected => _t('No printer connected', 'ပရင်တာ ချိတ်ဆက်ထားခြင်းမရှိပါ', 'ยังไม่ได้เชื่อมต่อเครื่องพิมพ์');
  String get shopInfoBusinessTypeLogoSecurity => _t(
        'Shop info, business type, logo & security',
        'ဆိုင်အချက်အလက်၊ လုပ်ငန်းအမျိုးအစား၊ လိုဂိုနှင့် လုံခြုံရေး',
        'ข้อมูลร้านค้า ประเภทธุรกิจ โลโก้ และความปลอดภัย',
      );
  String get viewShopInformation => _t('View shop information', 'ဆိုင်အချက်အလက်ကို ကြည့်ရန်', 'ดูข้อมูลร้านค้า');

  String pageTitle(String title) => switch (title) {
        'Dashboard' => _t('Dashboard', 'ဒက်ရှ်ဘုတ်', 'แดชบอร์ด'),
        'Check out' => _t('Check out', 'ငွေရှင်းရန်', 'ชำระเงิน'),
        'Stock in' => _t('Stock in', 'ကုန်ပစ္စည်းသွင်းရန်', 'รับสินค้าเข้า'),
        'Storage' => _t('Storage', 'သိုလှောင်ရုံ', 'คลังสินค้า'),
        'Print Barcode' => _t('Print Barcode', 'ဘားကုဒ် ပရင့်ထုတ်ရန်', 'พิมพ์บาร์โค้ด'),
        'Catalogs' => _t('Catalogs', 'ကတ်တလောက်များ', 'แคตตาล็อก'),
        'Transaction history' => _t('Transaction history', 'အရောင်းမှတ်တမ်း', 'ประวัติรายการ'),
        'Reports' => _t('Reports', 'အစီရင်ခံစာများ', 'รายงาน'),
        'Item Expiry Tracker' => _t('Item Expiry Tracker', 'ကုန်ပစ္စည်းသက်တမ်း စောင့်ကြည့်ရန်', 'ติดตามวันหมดอายุสินค้า'),
        'Promotions' => _t('Promotions', 'ပရိုမိုးရှင်းများ', 'โปรโมชั่น'),
        'Settings' => settings,
        'Accounts' => _t('Accounts', 'အကောင့်များ', 'บัญชีผู้ใช้'),
        _ => title,
      };

  String _t(String english, String myanmar, String thai) => switch (locale) {
        AppLanguage.english => english,
        AppLanguage.myanmar => myanmar,
        AppLanguage.thai => thai,
      };
}

import 'package:pos_mobile/controller/ui_controller.dart';
import 'package:pos_mobile/constants/business_type_utils.dart';
import '../constants/enums.dart';
import '../screens/accounts/account_screen.dart';
import '../screens/catalogs_screen.dart';
import '../screens/promotion/main_promotion_screen.dart';

import '../models/page_model.dart';

import '../screens/dashboard/dashboardfortoday_screen.dart';
import '../screens/history/transactions_history/transaction_history_tabbar.dart';
import '../screens/settings_screen.dart';
import '../screens/storage_screen.dart';
import '../screens/tables_charts/tableandchart_screen.dart';
import '../screens/transaction/stockIn/stockin_screen.dart';
import '../screens/transaction/stockOut/stockout_screen.dart';
import '../screens/reportAndAlerts/item_expiry_screen.dart';
import '../screens/reportAndAlerts/alert_screen.dart';
import '../screens/print_barcode_screen.dart';

//  NOTE ::  Please do in order to change the page using index
class PageList {
  // Keep the Alerts page registered, but hide it from navigation for now.
  static const bool showAlerts = false;

  static const List<PageModel> pages = [
    PageModel(screen: DashBoardForTodayScreen(), title: "Dashboard"), // 0
    PageModel(screen: StockOutScreen(), title: "Check out"), // 1
    PageModel(screen: StockInScreen(isStorage: true), title: "Storage"), // 2
    PageModel(screen: StorageScreen(), title: "Stock in"), // 3
    PageModel(screen: PrintBarcodeScreen(), title: "Barcode"), // 4
    PageModel(screen: CatalogsScreen(), title: "Catalogs"), // 4
    PageModel(
      screen: TransactionHistoryScreen(),
      title: "Transaction history",
    ), // 5
    // PageModel(screen: MyActivityScreen(), title: "My activity"),
    // PageModel(screen: HistoryScreen(), title: "History"),
    PageModel(screen: TableAndChartScreen(), title: "Reports"), // 6
    PageModel(screen: AlertScreen(), title: "Alerts"), // 7
    PageModel(screen: ItemExpiryScreen(), title: "Item Expiry Tracker"), // 7
    PageModel(screen: MainPromotionScreen(), title: "Promotions"), // 8
    // PageModel(screen: ReportAndAlertTabScreen(), title: "Reports and Alerts"),
    PageModel(screen: SettingScreen(), title: "Settings"), // 9
    // NOTE :: Please do not change this page position and index
    PageModel(screen: AccountScreen(), title: "Accounts"), // 10
  ];

  static List<PageModel> getPages(UserLevel userLevel) {
    final businessType = UIController.instance.businessType;

    List<PageModel> visiblePages = switch (userLevel) {
      UserLevel.staff => [
        pages.firstWhere((page) => page.screen is DashBoardForTodayScreen),
        pages.firstWhere((page) => page.screen is StockOutScreen),
        pages.firstWhere((page) => page.screen is StockInScreen),
        pages.firstWhere((page) => page.screen is CatalogsScreen),
        pages.firstWhere((page) => page.screen is PrintBarcodeScreen),
        pages.firstWhere((page) => page.screen is MainPromotionScreen),
        pages.firstWhere((page) => page.screen is ItemExpiryScreen),
        pages.firstWhere((page) => page.screen is SettingScreen),
      ],
      UserLevel.merchant => pages,
      UserLevel.superAdmin => [pages.last],
    };

    if (!businessType.allowsExpiryTracking) {
      visiblePages = visiblePages
          .where((page) => page.screen is! ItemExpiryScreen)
          .toList();
    }

    if (!showAlerts) {
      visiblePages = visiblePages
          .where((page) => page.screen is! AlertScreen)
          .toList();
    }

    return visiblePages;
  }
}

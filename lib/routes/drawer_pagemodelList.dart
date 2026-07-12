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

//  NOTE ::  Please do in order to change the page using index
class PageList {
  static const List<PageModel> pages = [
    PageModel(screen: DashBoardForTodayScreen(), title: "Dashboard"), // 0
    PageModel(screen: StockOutScreen(), title: "Check out"), // 1
    PageModel(screen: StockInScreen(isStorage: true), title: "Stock in"), // 2
    PageModel(screen: StorageScreen(), title: "Storage"), // 3
    PageModel(screen: CatalogsScreen(), title: "Catalogs"), // 4
    PageModel(screen: TransactionHistoryScreen(), title: "Transaction history"), // 5

    // PageModel(screen: MyActivityScreen(), title: "My activity"),
    // PageModel(screen: HistoryScreen(), title: "History"),
    PageModel(screen: TableAndChartScreen(), title: "Reports"), // 6
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
      UserLevel.staff => [pages[0], pages[1], pages[3], pages[7], pages[8],pages[9]],
      UserLevel.merchant => pages,
      UserLevel.superAdmin => [pages.last],
    };

    if (!businessType.allowsExpiryTracking) {
      visiblePages = visiblePages
          .where((page) => page.screen is! ItemExpiryScreen)
          .toList();
    }

    return visiblePages;
  }
}

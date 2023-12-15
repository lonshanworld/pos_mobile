import '../constants/enums.dart';
import '../screens/accounts/account_screen.dart';
import '../screens/promotion/main_promotion_screen.dart';


import '../models/page_model.dart';

import '../screens/dashboard/dashboardfortoday_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/history/transactions_history/transaction_history_tabbar.dart';
import '../screens/settings_screen.dart';
import '../screens/storage_screen.dart';
import '../screens/tables_charts/tableandchart_screen.dart';
import '../screens/transaction/stockIn/stockin_screen.dart';
import '../screens/transaction/stockOut/stockout_screen.dart';

//  NOTE ::  Please do in order to change the page using index
class PageList{
  static const List<PageModel> pages = [
    PageModel(screen: DashBoardForTodayScreen(), title: "Dashboard"),
    PageModel(screen: StockOutScreen(), title: "Stock out"),
    PageModel(screen: StockInScreen(isStorage: false,), title: "Stock in"),
    PageModel(screen: StorageScreen(), title: "Storage"),
    PageModel(screen: TransactionHistoryScreen(), title: "Transaction history"),
    // PageModel(screen: MyActivityScreen(), title: "My activity"),
    PageModel(screen: HistoryScreen(), title: "History"),

    PageModel(screen: TableAndChartScreen(), title: "Tables and Charts"),
    PageModel(screen: MainPromotionScreen(), title: "Promotions"),
    // PageModel(screen: ReportAndAlertTabScreen(), title: "Reports and Alerts"),
    PageModel(screen: SettingScreen(), title: "Settings"),

    // NOTE :: Please do not change this page position and index
    PageModel(screen: AccountScreen(), title: "Accounts"),
  ];


  static List<PageModel> getPages(UserLevel userLevel){
    switch(userLevel){
      case UserLevel.staff :
        return [
          pages[0],
          pages[1],
          pages[2],
          pages[7],
          pages[8],
        ];
      case UserLevel.admin:
        return pages;

      case UserLevel.superAdmin :
        return [
          pages.last,
        ];

      default :
        return pages;
    }
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/blocs/transactions_bloc/transactions_cubit.dart';
import 'package:pos_mobile/constants/uiConstants.dart';
import 'package:pos_mobile/models/transaction_model_folder/stockout_model_folder/stock_out_model.dart';
import 'package:pos_mobile/screens/tables_charts/daily_sales.dart';
import 'package:pos_mobile/screens/tables_charts/monthly_sales.dart';
import 'package:pos_mobile/screens/tables_charts/weekly_sales.dart';


import '../../blocs/theme_bloc/theme_cubit.dart';
import '../../constants/enums.dart';
import '../../controller/ui_controller.dart';

class TableAndChartScreen extends StatefulWidget {
  static const String routeName = "/tableandchartscreen";

  const TableAndChartScreen({super.key});

  @override
  State<TableAndChartScreen> createState() => _TableAndChartScreenState();
}

class _TableAndChartScreenState extends State<TableAndChartScreen> with TickerProviderStateMixin{
  late TabController tabController ;
  bool showMore = false;
  bool showWithChart = true;


  @override
  void initState() {
    super.initState();
    tabController = TabController(initialIndex: 0,length: 3, vsync: this,);
  }


  @override
  Widget build(BuildContext context) {
    final UIController uiController = UIController.instance;
    final ThemeModeType themeModeType = context.watch<ThemeCubit>().state.themeModeType;
    final List<StockOutModel> stockOutList = context.watch<TransactionsCubit>().state.activeStockOutList;

    void showMoreFunc(){
      if(mounted){
        setState(() {
          showMore = !showMore;
        });
      }
    }

    void showWithChartFunc(bool? value){
      if(mounted){
        setState(() {
          showWithChart = value!;
        });
      }
    }



    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: UIConstants.bigSpace,
              right: UIConstants.bigSpace,
              bottom: UIConstants.bigSpace,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TabBar(
                    controller: tabController,
                    indicator: BoxDecoration(
                      color: UIConstants.redVioletClr.withOpacity(0.6),
                      borderRadius: UIConstants.mediumBorderRadius,
                    ),
                    labelColor: uiController.getpureDirectClr(themeModeType),
                    unselectedLabelColor: uiController.getpureOppositeClr(themeModeType),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    overlayColor: MaterialStateProperty.all(UIConstants.redVioletClr.withOpacity(0.1)),
                    tabs: [
                      Tab(
                        text: "Daily sales",
                      ),
                      Tab(
                        text: "Weekly sales",
                      ),
                      Tab(
                        text: "Monthly sales",
                      ),
                    ],
                  ),
                ),
                // Padding(
                //   padding: EdgeInsets.only(
                //     right: UIConstants.mediumSpace
                //   ),
                //   child: Column(
                //     children: [
                //       RotatedBox(
                //         quarterTurns: showMore ? 0 : 1,
                //         child: CusIconBtn(
                //           size: UIConstants.normalNormalIconSize,
                //           // func: showMoreFunc,
                //           func : (){
                //             HistoryFilter.filterWeeklyStockOut(stockOutList);
                //           },
                //           clr: UIConstants.redVioletClr,
                //           icon: Icons.arrow_drop_down_circle_rounded,
                //         ),
                //       ),
                //       CusTxtWidget(
                //         txtStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                //           color: Colors.grey,
                //         ),
                //         txt: "Check more",
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
          // if(showMore)Align(
          //   alignment: Alignment.centerLeft,
          //   child: Container(
          //     width: UIConstants.checkMoreTableAndChartsWidth,
          //     decoration: BoxDecoration(
          //       color: uiController.getpureDirectClr(themeModeType),
          //       borderRadius: BorderRadius.all(Radius.circular(UIConstants.mediumSpace)),
          //       border: Border.all(
          //         color: UIConstants.redVioletClr,
          //         width: 1,
          //       ),
          //     ),
          //     margin: EdgeInsets.only(
          //       left: UIConstants.bigSpace * 2
          //     ),
          //     padding: EdgeInsets.only(
          //       left: UIConstants.mediumSpace
          //     ),
          //     child: Column(
          //       mainAxisSize: MainAxisSize.max,
          //       children: [
          //         Row(
          //           children: [
          //             CusTxtWidget(
          //               txtStyle: Theme.of(context).textTheme.bodyMedium!,
          //               txt: "View with Charts",
          //             ),
          //             Radio(
          //               value: true,
          //               groupValue: showWithChart,
          //               onChanged: showWithChartFunc,
          //               activeColor: UIConstants.redVioletClr,
          //             ),
          //           ],
          //         ),
          //         Row(
          //           children: [
          //             CusTxtWidget(
          //               txtStyle: Theme.of(context).textTheme.bodyMedium!,
          //               txt: "View with Tables",
          //             ),
          //             Radio(
          //               value: false,
          //               groupValue: showWithChart,
          //               onChanged: showWithChartFunc,
          //               activeColor: UIConstants.redVioletClr,
          //             ),
          //           ],
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                DailySales(showChart: true),
                WeeklySales(showCharts: true),
                MonthlySales(showCharts: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

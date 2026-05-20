import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/constants/uiConstants.dart';
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

class _TableAndChartScreenState extends State<TableAndChartScreen>
    with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(initialIndex: 0, length: 3, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UIController uiController = UIController.instance;
    final ThemeModeType themeModeType =
        context.watch<ThemeCubit>().state.themeModeType;

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              UIConstants.bigSpace,
              UIConstants.smallSpace,
              UIConstants.bigSpace,
              UIConstants.bigSpace,
            ),
            child: TabBar(
              controller: tabController,
              indicator: BoxDecoration(
                color: UIConstants.redVioletClr.withValues(alpha: 0.6),
                borderRadius: UIConstants.mediumBorderRadius,
              ),
              labelColor: uiController.getpureDirectClr(themeModeType),
              unselectedLabelColor:
                  uiController.getpureOppositeClr(themeModeType),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              overlayColor: WidgetStateProperty.all(
                  UIConstants.redVioletClr.withValues(alpha: 0.1)),
              tabs: const [
                Tab(text: "Daily"),
                Tab(text: "Weekly"),
                Tab(text: "Monthly"),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                DailySales(),
                WeeklySales(),
                MonthlySales(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
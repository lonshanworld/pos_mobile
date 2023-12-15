import "package:flutter/material.dart";
import "package:pos_mobile/screens/history/transactions_history/stockin_history_screen.dart";
import "package:pos_mobile/screens/history/transactions_history/stockout_history_screen.dart";

class TransactionHistoryScreen extends StatefulWidget {
  static const String routeName = "/transactionhistoryscreen";

  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> with TickerProviderStateMixin{
  late TabController tabController ;


  @override
  void initState() {
    super.initState();
    tabController = TabController(initialIndex: 0,length: 2, vsync: this,);
  }


  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            width: double.maxFinite,
            child: TabBar(
              controller: tabController,
              tabs: const[
                Tab(
                  text: "Stock-In History",
                ),
                Tab(
                  text: "Stock-Out History",
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: const[
                StockInHistoryScreen(),
                StockOutHistoryScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

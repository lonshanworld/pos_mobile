import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/blocs/transactions_bloc/transactions_cubit.dart';
import 'package:pos_mobile/models/transaction_model_folder/stockin_model_folder/stockin_history_model.dart';
import 'package:pos_mobile/widgets/transaction_history_widgets_folder/stockin_history_widget.dart';

import '../../blocs/theme_bloc/theme_cubit.dart';
import '../../constants/enums.dart';
import '../../controller/ui_controller.dart';
import '../../widgets/cusTxt_widget.dart';

class DashboardStockIn extends StatelessWidget {
  const DashboardStockIn({super.key});

  @override
  Widget build(BuildContext context) {
    final UIController uiController = UIController.instance;
    final ThemeModeType themeModeType = context.watch<ThemeCubit>().state.themeModeType;

    return BlocBuilder<TransactionsCubit, TransactionsState>(
      builder: (context, state){
        final StockInHistoryModel? stockInHistoryModel = context.read<TransactionsCubit>().getTodayStockInHistory();

        return Column(
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 0,
                ),
                decoration: BoxDecoration(

                    border: Border(
                        bottom: BorderSide(
                          color: uiController.getpureOppositeClr(themeModeType),
                          width: 3,
                        )
                    )
                ),
                child: CusTxtWidget(
                  txt: "Today Stock-In",
                  txtStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: uiController.getpureOppositeClr(themeModeType),
                  ),
                ),
              ),
            ),
            Expanded(
              child: stockInHistoryModel == null
                  ?
              Center(
                child: CusTxtWidget(
                  txt: "No stock-in for today",
                  txtStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Colors.grey.withOpacity(0.7)
                  ),
                ),
              )
                  :
              SingleChildScrollView(
                child: StockInHistoryWidget(
                  stockInHistoryModel: stockInHistoryModel,
                  showDate: false,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

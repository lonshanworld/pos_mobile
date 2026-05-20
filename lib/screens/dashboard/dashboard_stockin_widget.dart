import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/blocs/transactions_bloc/transactions_cubit.dart';
import 'package:pos_mobile/models/transaction_model_folder/stockin_model_folder/stockin_history_model.dart';
import 'package:pos_mobile/widgets/transaction_history_widgets_folder/stockin_history_widget.dart';

import '../../constants/uiConstants.dart';

class DashboardStockIn extends StatelessWidget {
  const DashboardStockIn({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionsCubit, TransactionsState>(
      builder: (context, state) {
        final StockInHistoryModel? stockInHistoryModel =
            context.read<TransactionsCubit>().getTodayStockInHistory();

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(UIConstants.mediumRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Colors.grey.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(UIConstants.mediumSpace),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(UIConstants.mediumRadius),
                    topRight: Radius.circular(UIConstants.mediumRadius),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_downward_rounded,
                      color: Colors.blueAccent.shade700,
                      size: 24,
                    ),
                    const SizedBox(width: UIConstants.smallSpace),
                    Text(
                      "Today's Stock-In",
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: Colors.blueAccent.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              
              // Body
              stockInHistoryModel == null
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 48,
                            color: Colors.grey.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: UIConstants.mediumSpace),
                          Text(
                            "No stock-in records for today",
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(UIConstants.smallSpace),
                      child: StockInHistoryWidget(
                        stockInHistoryModel: stockInHistoryModel,
                        showDate: false,
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }
}

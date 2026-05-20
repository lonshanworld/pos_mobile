import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/screens/dashboard/dashboard_stockOut_widget.dart';
import 'package:pos_mobile/screens/dashboard/dashboard_stockin_widget.dart';

import '../../blocs/userData_bloc/user_data_cubit.dart';
import '../../constants/uiConstants.dart';
import '../../models/user_model_folder/user_model.dart';
import '../../widgets/loading_widget.dart';

class DashBoardForTodayScreen extends StatelessWidget {
  static const String routeName = "/dashboard";

  const DashBoardForTodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserModel? userModel = context.watch<UserDataCubit>().state.userModel;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: userModel == null
            ? const Center(child: LoadingWidget())
            : LayoutBuilder(
                builder: (BuildContext ctx, BoxConstraints constraints) {
                  final bool isWide = constraints.maxWidth > UIConstants.screenBreakPoint - 150;
                  
                  return Padding(
                    padding: const EdgeInsets.all(UIConstants.mediumSpace),
                    child: isWide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Expanded(
                                child: DashboardStockIn(),
                              ),
                              const SizedBox(width: UIConstants.mediumSpace),
                              Expanded(
                                child: Container(
                                  width: 1,
                                  color: Colors.grey.withValues(alpha: 0.2),
                                ),
                              ),
                              const SizedBox(width: UIConstants.mediumSpace),
                              const Expanded(
                                child: DashboardStockOut(),
                              ),
                            ],
                          )
                        : const SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                DashboardStockIn(),
                                SizedBox(height: UIConstants.bigSpace),
                                DashboardStockOut(),
                              ],
                            ),
                          ),
                  );
                },
              ),
      ),
    );
  }
}

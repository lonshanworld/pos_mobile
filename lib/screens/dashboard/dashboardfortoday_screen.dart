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
    final UserModel? userModel = context
        .watch<UserDataCubit>()
        .state
        .userModel;
    
    Widget dashboardVerticalDivider(){
      return Divider(
        color: Colors.grey.withOpacity(0.5),
        thickness: 1,
        height: UIConstants.smallSpace,
      );
    }

    Widget dashboardHorizontalDivider(){
      return VerticalDivider(
        color: Colors.grey.withOpacity(0.5),
        thickness: 1,
        width: UIConstants.smallSpace,
      );
    }

    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext ctx, BoxConstraints constraints) {
          if (userModel == null) {
            return const Center(
              child: LoadingWidget(),
            );
          } else {
            if(constraints.maxWidth > UIConstants.screenBreakPoint - 220){
              return Row(
                children: [
                  const Expanded(
                    child: DashboardStockIn(),
                  ),
                  dashboardHorizontalDivider(),
                  const Expanded(
                    child: DashboardStockOut(),
                  ),
                ],
              );
            }else{
              return Column(
                children: [


                  const Expanded(
                    child: DashboardStockIn(),
                  ),
                  dashboardVerticalDivider(),
                  const Expanded(
                    child: DashboardStockOut(),
                  ),
                ],
              );
            }
          }
        },
      ),
    );
  }
}

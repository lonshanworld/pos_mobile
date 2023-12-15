
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/blocs/history_bloc/history_cubit.dart';
import 'package:pos_mobile/models/user_model_folder/user_model.dart';
import 'package:pos_mobile/widgets/cusTxt_widget.dart';
import 'package:pos_mobile/widgets/tables_folder/user_table_folder/userModelTable.dart';

import '../../constants/uiConstants.dart';
import '../../controller/ui_controller.dart';

class HistoryScreen extends StatelessWidget {
  static const String routeName = "/historyscreen";

  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final List<UserModel> userHistoryModelList = context.read<HistoryCubit>().getUserModelHistoryList();
    final UIController uiController = UIController.instance;


    return Scaffold(
      body: Center(
        child: Column(
          children: [
            CusTxtWidget(
              txtStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Colors.grey
              ),
              txt: "Login - logout History",
            ),
            uiController.sizedBox(cusHeight: UIConstants.mediumSpace, cusWidth: null),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: UserTable(userList: userHistoryModelList, showPassword: false),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

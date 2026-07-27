import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/blocs/history_bloc/history_cubit.dart';
import 'package:pos_mobile/models/user_model_folder/user_model.dart';
import 'package:pos_mobile/widgets/cusTxt_widget.dart';
import 'package:pos_mobile/widgets/tables_folder/user_table_folder/userModelTable.dart';
import 'package:pos_mobile/screens/screen_data_loader.dart';

import '../../constants/uiConstants.dart';
import '../../controller/ui_controller.dart';

class HistoryScreen extends StatefulWidget {
  static const String routeName = "/historyscreen";

  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(loadData());
  }

  Future<void> loadData() => ScreenDataLoader.history(context);

  @override
  Widget build(BuildContext context) {
    final List<UserModel> userHistoryModelList = context
        .watch<HistoryCubit>()
        .getUserModelHistoryList();
    final UIController uiController = UIController.instance;

    return Scaffold(
      body: Center(
        child: Column(
          children: [
            CusTxtWidget(
              txtStyle: Theme.of(
                context,
              ).textTheme.titleMedium!.copyWith(color: Colors.grey),
              txt: "Login - logout History",
            ),
            uiController.sizedBox(
              cusHeight: UIConstants.mediumSpace,
              cusWidth: null,
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: UserTable(
                  userList: userHistoryModelList,
                  showPassword: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

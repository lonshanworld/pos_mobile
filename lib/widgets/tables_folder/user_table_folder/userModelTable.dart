import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:pos_mobile/blocs/userData_bloc/user_data_cubit.dart";
import "package:pos_mobile/constants/enums.dart";
import "package:pos_mobile/widgets/tables_folder/tables_charts_widget.dart";


import "../../../models/user_model_folder/user_model.dart";
import "../../../utils/txt_formatters.dart";
import "../../cusTxt_widget.dart";


class UserTable extends StatelessWidget {

  final List<UserModel>userList;
  final bool showPassword;
  const UserTable({
    super.key,
    required this.userList,
    required this.showPassword,
  });

  @override
  Widget build(BuildContext context) {
    final UserModel? userModel = context.watch<UserDataCubit>().state.userModel;
    final TablesAndCharts tablesAndCharts = TablesAndCharts(context: context);

    DataColumn dataColumn(String txt){
      return DataColumn(
        label: CusTxtWidget(
          txt: txt,
          txtStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    DataRow dataRow({
      required int id,
      required String name,
      required String password,
      required String level,
      required String loginTime,
      required String logoutTime,
    }){
      return DataRow(
        cells: [
          tablesAndCharts.normalDataCell(id.toString()),
          tablesAndCharts.normalDataCell(name),
          if(userModel?.userLevel == UserLevel.superAdmin && showPassword)tablesAndCharts.normalDataCell(password),
          tablesAndCharts.normalDataCell(level),
          tablesAndCharts.normalDataCell(loginTime),
          tablesAndCharts.normalDataCell(logoutTime),
        ],
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        dataRowMinHeight: 40,
        dataRowMaxHeight: 40,
        headingRowColor: MaterialStateProperty.resolveWith((states) {
          return Colors.teal.withOpacity(0.4);
        }),
        columns: [
          dataColumn("No."),
          dataColumn("Name"),
          if(userModel?.userLevel == UserLevel.superAdmin && showPassword)dataColumn("password"),
          dataColumn("Level"),
          dataColumn("Last Login Time"),
          dataColumn("Last Logout Time"),
        ],
        rows: userList.reversed.map((e) => dataRow(
          id: userList.indexOf(e) + 1,
          name: e.userName,
          password: e.password,
          level: e.userLevel.name,
          loginTime: TextFormatters.getDateTime(e.userLoginTime),
          logoutTime: TextFormatters.getDateTime(e.userLogoutTime),
        )
        ).toList(),
      ),
    );
  }
}

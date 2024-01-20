import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:pos_mobile/blocs/userData_bloc/user_data_cubit.dart";
import "package:pos_mobile/constants/uiConstants.dart";
import "package:pos_mobile/controller/ui_controller.dart";
import "package:pos_mobile/features/accounts/domain/entities/user_entity.dart";



import "package:pos_mobile/widgets/btns_folder/cusTxtIconBtn_widget.dart";
import "package:pos_mobile/widgets/cusTxt_widget.dart";
import "package:pos_mobile/widgets/tables_folder/user_table_folder/userModelTable.dart";

class CheckAllAccountScreen extends StatelessWidget {

  final VoidCallback goToCreateScreen;
  const CheckAllAccountScreen({
    super.key,
    required this.goToCreateScreen,
  });

  @override
  Widget build(BuildContext context) {
    final List<UserEntity> userList = context.watch<UserDataCubit>().state.allUserModelList;
    final UIController uiController = UIController.instance;

    // DataColumn dataColumn(String txt){
    //   return DataColumn(
    //     label: CusTxtWidget(
    //       txt: txt,
    //       txtStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
    //         fontWeight: FontWeight.bold,
    //       ),
    //     ),
    //   );
    // }
    //
    // DataCell dataCell(String txt){
    //   return DataCell(
    //     CusTxtWidget(
    //       txtStyle:Theme.of(context).textTheme.bodyMedium!,
    //       txt: txt == "null" ? "- -" : txt,
    //     ),
    //     placeholder: true,
    //   );
    // }
    //
    // DataRow dataRow({
    //   required int id,
    //   required String name,
    //   required String level,
    //   required String loginTime,
    //   required String logoutTime,
    // }){
    //   return DataRow(
    //     cells: [
    //       dataCell(id.toString()),
    //       dataCell(name),
    //       dataCell(level),
    //       dataCell(loginTime),
    //       dataCell(logoutTime),
    //     ],
    //   );
    // }

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            left: 0,
            child:  Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: UIConstants.bigSpace,
                  ),
                  child: Row(
                    children: [
                      CusTxtWidget(
                        txtStyle: Theme.of(context).textTheme.titleSmall!,
                        txt: "Total Accounts ( ${userList.length} )",
                      ),
                    ],
                  ),
                ),
                uiController.sizedBox(cusHeight: UIConstants.mediumSpace, cusWidth: null),
                Expanded(
                  child: Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: UserTable(userList: userList, showPassword: true,),
                      ),
                      uiController.sizedBox(cusHeight: UIConstants.bigSpace * 6, cusWidth: null),
                    ],
                  ),
                ),

              ],
            ),
          ),
          Positioned(
            bottom: 30,
            right: 30,
            child: CusTxtIconElevatedBtn(
              txt: "Create new account",
              verticalpadding: UIConstants.mediumSpace,
              horizontalpadding: UIConstants.bigSpace,
              bdrRadius: UIConstants.mediumRadius,
              bgClr: Colors.teal,
              func: ()async{
                goToCreateScreen();
                // context.read<UserDataCubit>().initData();
              },
              txtStyle: Theme.of(context).textTheme.titleSmall!,
              txtClr: Colors.white,
              icon: Icons.add,
              iconSize: UIConstants.normalNormalIconSize,
            ),
          ),
        ],
      ),
    );
  }
}

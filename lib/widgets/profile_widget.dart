import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:pos_mobile/blocs/loading_bloc/loading_cubit.dart";
import "package:pos_mobile/blocs/theme_bloc/theme_cubit.dart";
import "package:pos_mobile/constants/enums.dart";
import "package:pos_mobile/constants/uiConstants.dart";
import "package:pos_mobile/controller/ui_controller.dart";
import "package:pos_mobile/features/cus_showmodelbottomsheet.dart";
import "package:pos_mobile/features/logout_feature.dart";
import "package:pos_mobile/screens/authenticaton/check_user_screen.dart";
import "package:pos_mobile/utils/txt_formatters.dart";
import "package:pos_mobile/widgets/cusTxt_widget.dart";
import "package:pos_mobile/widgets/logo_folder/logo_image_widget.dart";

import "../blocs/userData_bloc/user_data_cubit.dart";
import "../models/user_model_folder/user_model.dart";
import '../screens/confirm_screens_folder/comfirm_screen.dart';

class ProfileWidget extends StatelessWidget {
  const ProfileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final UserModel userModel = context.watch<UserDataCubit>().state.userModel!;
    final UIController uiController = UIController.instance;
    final ThemeModeType themeModeType = context.watch<ThemeCubit>().state.themeModeType;
    final CusShowSheet showSheet = CusShowSheet();

    Widget profileBox(){
      if(userModel.imageId != null){

        // TODO : design for profilebox
        return const SizedBox();
      }else{
        return const LogoImageWidget(widthandheight: 100);
      }
    }

    return SizedBox(
      width: double.infinity,
      height: 190,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            left: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                profileBox(),
                CusTxtWidget(
                  txtStyle: Theme.of(context).textTheme.bodyLarge!,
                  txt: userModel.userName,
                ),
                CusTxtWidget(
                  txt : TextFormatters.getDateTime(userModel.userLoginTime),
                  txtStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: uiController.getOppositeClr(themeModeType).withOpacity(0.7),
                  ),
                ),
                uiController.sizedBox(cusHeight: UIConstants.mediumSpace, cusWidth: null),
              ],
            ),
          ),
          Positioned(
            top: 20,
            left: 20,
            child:  IconButton(
              tooltip: "Log out",
              style: IconButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: (){
                //

                // showDialog(
                //   context: context,
                //   builder: (ctx){
                //     return ConfirmScreen(
                //       txt: "Are you sure to logout ?",
                //       title: "Confirm !!!",
                //       acceptBtnTxt: "Yes, logout",
                //       cancelBtnTxt: "Cancel",
                //       acceptFunc: ()async{
                //         Navigator.of(ctx).pop();
                //         context.read<LoadingCubit>().setLoading("Logout ...");
                //         await Logout.logout(context).then((value) {
                //           if(value){
                //             context.read<LoadingCubit>().changeLoadingValue(false);
                //             Navigator.of(context).pushNamedAndRemoveUntil(CheckUserScreen.routeName, (route) => false);
                //           }else{
                //             context.read<LoadingCubit>().setFail("Logout Failed");
                //           }
                //         });
                //       },
                //       cancelFunc: (){
                //         Navigator.of(ctx).pop();
                //       },
                //     );
                //   },
                // );
                showSheet.showCusDialogScreen(ConfirmScreen(
                  txt: "Are you sure to logout ?",
                  title: "Confirm !!!",
                  acceptBtnTxt: "Yes, logout",
                  cancelBtnTxt: "Cancel",
                  acceptFunc: ()async{
                    Navigator.of(context).pop();
                    context.read<LoadingCubit>().setLoading("Logout ...");
                    await Logout.logout(context).then((value) {
                      if(value){
                        context.read<LoadingCubit>().changeLoadingValue(false);
                        Navigator.of(context).pushNamedAndRemoveUntil(CheckUserScreen.routeName, (route) => false);
                      }else{
                        context.read<LoadingCubit>().setFail("Logout Failed");
                      }
                    });
                  },
                  cancelFunc: (){
                    Navigator.of(context).pop();
                  },
                ));
              },
              icon: const Icon(
                Icons.logout,
                size: UIConstants.bigIcon,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

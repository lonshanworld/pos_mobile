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
        return const LogoImageWidget(widthandheight: 80);
      }
    }

    String userLevelLabel() {
      switch (userModel.userLevel) {
        case UserLevel.staff:
          return "Staff";
        case UserLevel.merchant:
          return "Merchant";
        case UserLevel.superAdmin:
          return "Super Admin";
      }
    }

    Color userLevelColor() {
      switch (userModel.userLevel) {
        case UserLevel.staff:
          return Colors.blue;
        case UserLevel.merchant:
          return Colors.deepPurple;
        case UserLevel.superAdmin:
          return Colors.red;
      }
    }

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: UIConstants.bigSpace,
          horizontal: UIConstants.mediumSpace,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            profileBox(),
            const SizedBox(height: UIConstants.mediumSpace),
            Text(
              userModel.userName,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: UIConstants.mediumSpace,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: userLevelColor().withValues(alpha: 0.1),
                borderRadius: UIConstants.smallBorderRadius,
              ),
              child: Text(
                userLevelLabel(),
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: userLevelColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 6),
            CusTxtWidget(
              txt: TextFormatters.getDateTime(userModel.userLoginTime),
              txtStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: uiController.getOppositeClr(themeModeType).withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: UIConstants.mediumSpace),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  showSheet.showCusDialogScreen(ConfirmScreen(
                    txt: "Are you sure to logout ?",
                    title: "Confirm !!!",
                    acceptBtnTxt: "Yes, logout",
                    cancelBtnTxt: "Cancel",
                    acceptFunc: () async {
                      final navigator = Navigator.of(context);
                      final loadingCubit = context.read<LoadingCubit>();
                      navigator.pop(); // Close dialog
                      loadingCubit.setLoading("Logout ...");
                      final value = await Logout.logout(context);
                      if (value) {
                        loadingCubit.changeLoadingValue(false);
                        navigator.pushNamedAndRemoveUntil(
                            CheckUserScreen.routeName, (route) => false);
                      } else {
                        loadingCubit.setFail("Logout Failed");
                      }
                    },
                    cancelFunc: () {
                      Navigator.of(context).pop();
                    },
                  ));
                },
                icon: const Icon(Icons.logout, size: 18),
                label: const Text("Logout"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: UIConstants.smallBorderRadius,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: UIConstants.smallSpace,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/widgets/btns_folder/cusTxtElevatedButton_widget.dart';

import '../../blocs/theme_bloc/theme_cubit.dart';
import '../../constants/enums.dart';
import '../../constants/uiConstants.dart';
import '../../controller/ui_controller.dart';
import '../../widgets/btns_folder/cusTextOnlyBtn_widget.dart';

class ConfirmScreen extends StatelessWidget {

  final String title;
  final String txt;
  final String acceptBtnTxt;
  final String cancelBtnTxt;
  final VoidCallback acceptFunc;
  final VoidCallback cancelFunc;
  const ConfirmScreen({
    super.key,
    required this.txt,
    required this.title,
    required this.acceptBtnTxt,
    required this.cancelBtnTxt,
    required this.acceptFunc,
    required this.cancelFunc,
  });

  @override
  Widget build(BuildContext context) {
    final UIController uiController = UIController.instance;
    final ThemeModeType themeModeType = context.watch<ThemeCubit>().state.themeModeType;

    return AlertDialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
        textAlign: TextAlign.center,
      ),
      content: Text(
        txt,
        style: Theme.of(context).textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: UIConstants.bigBorderRadius,
      ),
      titlePadding:  const EdgeInsets.only(
        top: UIConstants.mediumSpace + UIConstants.smallSpace,
        left: UIConstants.mediumSpace,
        right: UIConstants.mediumSpace,
      ),
      contentPadding:const EdgeInsets.only(
          top: UIConstants.mediumSpace,
          left: UIConstants.mediumSpace,
          right: UIConstants.mediumSpace
      ),
      actionsPadding: const EdgeInsets.only(
          top: UIConstants.mediumSpace,
          left: UIConstants.mediumSpace,
          right: UIConstants.mediumSpace,
          bottom:UIConstants.mediumSpace + UIConstants.smallSpace,
      ),
      actions: [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            CusTxtOnlyBtn(
              textStyle: Theme.of(context).textTheme.titleSmall!,
              txt: cancelBtnTxt,
              func: cancelFunc,
              clr: uiController.getpureOppositeClr(themeModeType),
            ),
            CusTxtElevatedBtn(
              txt: acceptBtnTxt,
              verticalpadding: UIConstants.smallSpace,
              horizontalpadding: UIConstants.mediumSpace + UIConstants.smallSpace,
              bdrRadius: UIConstants.mediumRadius,
              bgClr: Colors.red,
              func: acceptFunc,
              txtStyle: Theme.of(context).textTheme.titleSmall!,
              txtClr: Colors.white,
            ),
          ],
        )
      ],
    );
  }
}

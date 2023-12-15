import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import '../../blocs/theme_bloc/theme_cubit.dart';
import '../../constants/enums.dart';
import '../../constants/uiConstants.dart';
import '../../controller/ui_controller.dart';
import '../../widgets/btns_folder/cusTextOnlyBtn_widget.dart';

class CannotDeleteItemBoxError extends StatelessWidget {

  final String title;
  final String txt;
  const CannotDeleteItemBoxError({
    super.key,
    required this.title,
    required this.txt,
  });

  @override
  Widget build(BuildContext context) {
    final UIController uiController = UIController.instance;
    final ThemeModeType themeModeType = context.watch<ThemeCubit>().state.themeModeType;

    return AlertDialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Text(
        title,
        style : Theme.of(context).textTheme.titleSmall!.copyWith(
          color: Colors.red
        ),
        textAlign: TextAlign.center,
      ),
      content: Text(
        txt,
        style: Theme.of(context).textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(UIConstants.bigRadius),
        ),
      ),
      titlePadding:  const EdgeInsets.only(
        top: UIConstants.mediumSpace,
        left: UIConstants.mediumSpace,
        right: UIConstants.mediumSpace,
      ),
      contentPadding: const EdgeInsets.only(
          top: UIConstants.mediumSpace,
          left: UIConstants.mediumSpace,
          right: UIConstants.mediumSpace
      ),
      actionsPadding:const EdgeInsets.only(
          top: UIConstants.mediumSpace,
          left: UIConstants.mediumSpace,
          right: UIConstants.mediumSpace
      ),
      actions: [
        Align(
          alignment: Alignment.center,
          child: CusTxtOnlyBtn(
            textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: Colors.red,
            ),
            txt: 'Cancel',
            func: () {
              Navigator.of(context).pop();
            },
            clr: uiController.getpureOppositeClr(themeModeType),
          ),
        ),
      ],
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/blocs/theme_bloc/theme_cubit.dart';
import 'package:pos_mobile/constants/enums.dart';
import 'package:pos_mobile/constants/uiConstants.dart';
import 'package:pos_mobile/controller/ui_controller.dart';
import 'package:pos_mobile/widgets/btns_folder/cusTextOnlyBtn_widget.dart';

class ErrorBoxWithBtn extends StatelessWidget {

  final String? title;
  final String txt;
  const ErrorBoxWithBtn({
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
      title: title == null ? const SizedBox.shrink() : Text(
        title ?? "",
        style : Theme.of(context).textTheme.titleSmall,
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
      titlePadding: const EdgeInsets.only(
        top: UIConstants.mediumSpace,
        left: UIConstants.mediumSpace,
        right: UIConstants.mediumSpace,
      ),
      contentPadding: const EdgeInsets.only(
        top: UIConstants.mediumSpace,
        left: UIConstants.mediumSpace,
        right: UIConstants.mediumSpace
      ),
      actionsPadding: const EdgeInsets.only(
        top: UIConstants.mediumSpace,
        left: UIConstants.mediumSpace,
        right: UIConstants.mediumSpace
      ),
      actions: [
        Align(
          alignment: Alignment.center,
          child: CusTxtOnlyBtn(
            textStyle: Theme.of(context).textTheme.titleMedium!,
            txt: 'OK',
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

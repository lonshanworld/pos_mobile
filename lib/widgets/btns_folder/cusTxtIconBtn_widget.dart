import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/theme_bloc/theme_cubit.dart';
import '../../constants/enums.dart';
import '../../controller/ui_controller.dart';

class CusTxtIconElevatedBtn extends StatelessWidget {

  final String txt;
  final double verticalpadding;
  final double horizontalpadding;
  final double bdrRadius;
  final Color bgClr;
  final TextStyle txtStyle;
  final Color txtClr;
  final VoidCallback func;
  final IconData icon;
  final double iconSize;
  const CusTxtIconElevatedBtn({
    super.key,
    required this.txt,
    required this.verticalpadding,
    required this.horizontalpadding,
    required this.bdrRadius,
    required this.bgClr,
    required this.txtStyle,
    required this.txtClr,
    required this.func,
    required this.icon,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final UIController uiController = UIController.instance;
    final ThemeModeType themeModeType = context.watch<ThemeCubit>().state.themeModeType;

    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: bgClr,
        foregroundColor: uiController.getpureDirectClr(themeModeType),
        padding: EdgeInsets.symmetric(
          vertical: verticalpadding,
          horizontal: horizontalpadding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(bdrRadius)),
        ),
        minimumSize: const Size(0, 0),
      ),
      onPressed: func,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            txt,
            style: txtStyle.copyWith(
              color: txtClr,
            ),
          ),
          Icon(
            icon,
            size: iconSize,
            color: txtClr,
          ),
        ],
      ),
    );
  }
}

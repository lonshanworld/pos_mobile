import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:pos_mobile/blocs/theme_bloc/theme_cubit.dart";
import "package:pos_mobile/constants/enums.dart";
import "package:pos_mobile/controller/ui_controller.dart";

class CusTxtElevatedBtn extends StatelessWidget {

  final String txt;
  final double verticalpadding;
  final double horizontalpadding;
  final double bdrRadius;
  final Color bgClr;
  final TextStyle txtStyle;
  final Color txtClr;
  final VoidCallback func;

  const CusTxtElevatedBtn({
    super.key,
    required this.txt,
    required this.verticalpadding,
    required this.horizontalpadding,
    required this.bdrRadius,
    required this.bgClr,
    required this.func,
    required this.txtStyle,
    required this.txtClr,

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
      ),
      onPressed: func,
      child: Text(
        txt,
        style: txtStyle.copyWith(
          color: txtClr,
        ),
      ),
    );
  }
}

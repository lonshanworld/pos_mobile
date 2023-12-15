import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:pos_mobile/constants/uiConstants.dart";

import "../../blocs/theme_bloc/theme_cubit.dart";
import "../../constants/enums.dart";
import "../../controller/ui_controller.dart";
import "cusIconBtn_widget.dart";

class CusLeadingBackIconBtn extends StatelessWidget {
  const CusLeadingBackIconBtn({super.key});

  @override
  Widget build(BuildContext context) {
    final UIController uiController = UIController.instance;
    final ThemeModeType themeModeType = context.watch<ThemeCubit>().state.themeModeType;

    return CusIconBtn(
      size: UIConstants.bigIcon,
      func: (){
        Navigator.of(context).pop();
      },
      clr: uiController.getpureOppositeClr(themeModeType),
      icon: Icons.arrow_back,
    );
  }
}

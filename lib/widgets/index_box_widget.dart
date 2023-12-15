import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/theme_bloc/theme_cubit.dart';
import '../constants/enums.dart';
import '../constants/uiConstants.dart';
import '../controller/ui_controller.dart';
import 'cusTxt_widget.dart';

class IndexBoxWidget extends StatelessWidget {

  final String index;
  const IndexBoxWidget({
    super.key,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final UIController uiController = UIController.instance;
    final ThemeModeType themeModeType = context.watch<ThemeCubit>().state.themeModeType;

    return Container(
      constraints:const BoxConstraints(
        minHeight: 0,
        minWidth: 0,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 0,
      ),
      decoration: BoxDecoration(
        color: uiController.getpureOppositeClr(themeModeType),
        borderRadius: UIConstants.smallBorderRadius,
      ),
      child: CusTxtWidget(
        txt: index,
        txtStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
          color: uiController.getpureDirectClr(themeModeType),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/theme_bloc/theme_cubit.dart';
import '../../constants/enums.dart';
import '../../constants/uiConstants.dart';
import '../../controller/ui_controller.dart';
import '../../widgets/btns_folder/cusIconBtn_widget.dart';
import '../../widgets/cusTxt_widget.dart';

class NoSelectedIdErrorWidget extends StatelessWidget {

  final String txt;
  final VoidCallback func;
  const NoSelectedIdErrorWidget({
    super.key,
    required this.txt,
    required this.func,
  });

  @override
  Widget build(BuildContext context) {

    final ThemeModeType themeModeType = context.watch<ThemeCubit>().state.themeModeType;
    final UIController uiController = UIController.instance;

    return Center(
      child: Column(
        children: [
          CusTxtWidget(
            txt: txt,
            txtStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: Colors.grey,
            ),
          ),
          CusIconBtn(
            size: UIConstants.bigIcon,
            func: func,
            clr: uiController.getpureOppositeClr(themeModeType),
            icon: Icons.arrow_back,
          ),
        ],
      ),
    );
  }
}

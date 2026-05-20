import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/theme_bloc/theme_cubit.dart';
import '../../constants/enums.dart';
import '../../constants/uiConstants.dart';
import '../../controller/ui_controller.dart';
import '../btns_folder/cusIconBtn_widget.dart';
import '../cusTxt_widget.dart';

class StockInItemAppBar extends StatelessWidget {

  final String txt;
  final VoidCallback func;
  const StockInItemAppBar({
    super.key,
    required this.txt,
    required this.func,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeModeType themeModeType = context.watch<ThemeCubit>().state.themeModeType;
    final UIController uiController = UIController.instance;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.mediumSpace,
        vertical: UIConstants.smallSpace,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: uiController.getpureOppositeClr(themeModeType).withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          CusIconBtn(
            size: UIConstants.bigIcon,
            func: func,
            clr: uiController.getpureOppositeClr(themeModeType),
            icon: Icons.arrow_back,
          ),
          uiController.sizedBox(cusHeight: null, cusWidth: UIConstants.mediumSpace),
          Flexible(
            child: CusTxtWidget(
              txtStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: uiController.getpureOppositeClr(themeModeType),
              ),
              txt: txt,
            ),
          ),
        ],
      ),
    );
  }
}

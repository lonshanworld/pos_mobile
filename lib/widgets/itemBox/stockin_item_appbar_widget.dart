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

    return Padding(
      padding: const EdgeInsets.only(
        left: UIConstants.mediumSpace,
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
          CusTxtWidget(
            txtStyle: Theme.of(context).textTheme.titleSmall!,
            txt: txt,
          ),
        ],
      ),
    );
  }
}

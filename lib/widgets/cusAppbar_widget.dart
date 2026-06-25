import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/blocs/shop_info_bloc/shop_info_cubit.dart';
import 'package:pos_mobile/blocs/theme_bloc/theme_cubit.dart';
import 'package:pos_mobile/constants/business_type_utils.dart';
import 'package:pos_mobile/constants/enums.dart';
import 'package:pos_mobile/constants/uiConstants.dart';
import 'package:pos_mobile/widgets/btns_folder/cusIconBtn_widget.dart';

class CusAppBar extends StatelessWidget {
  final String txt;
  final bool? showThemeToggle;

  const CusAppBar({
    super.key,
    required this.txt,
    this.showThemeToggle,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeModeType themeModeType =
        context.watch<ThemeCubit>().state.themeModeType;
    final BusinessType businessType =
        context.watch<ShopInfoCubit>().state.businessType;
    final bool canToggleTheme =
        showThemeToggle ?? businessType.allowsThemeToggle;

    return SafeArea(
      child: Container(
        width: double.infinity,
        height: Theme.of(context).appBarTheme.toolbarHeight,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: UIConstants.bigSpace,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              txt,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (canToggleTheme)
              CusIconBtn(
                size: UIConstants.bigIcon,
                func: () {
                  context.read<ThemeCubit>().switchTheme();
                },
                clr: themeModeType == ThemeModeType.light
                    ? Colors.orange
                    : Colors.purple,
                icon: themeModeType == ThemeModeType.light
                    ? Icons.light_mode
                    : Icons.dark_mode,
              )
            else
              const SizedBox(width: UIConstants.bigIcon),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/blocs/promotion_bloc/promotion_cubit.dart';
import 'package:pos_mobile/blocs/userData_bloc/user_data_cubit.dart';
import 'package:pos_mobile/constants/enums.dart';
import 'package:pos_mobile/models/promotion_model_folder/promotion_model.dart';
import 'package:pos_mobile/models/user_model_folder/user_model.dart';
import 'package:pos_mobile/widgets/promotion/promotion_widget.dart';

import '../../constants/uiConstants.dart';
import '../../widgets/btns_folder/cusTxtIconBtn_widget.dart';
import '../screen_data_loader.dart';

class PromotionListScreen extends StatefulWidget {
  final VoidCallback goToCreateScreen;
  const PromotionListScreen({super.key, required this.goToCreateScreen});

  @override
  State<PromotionListScreen> createState() => _PromotionListScreenState();
}

class _PromotionListScreenState extends State<PromotionListScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(loadData());
  }

  Future<void> loadData() async {
    await Future.wait([
      ScreenDataLoader.promotions(context),
      ScreenDataLoader.users(context),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final List<PromotionModel> promotionList = context
        .watch<PromotionCubit>()
        .state
        .activePromotionList;
    final UserModel? userModel = context.watch<UserDataCubit>().state.userModel;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: UIConstants.bigSpace,
                  left: UIConstants.bigSpace,
                  right: UIConstants.bigSpace,
                  bottom: UIConstants.bigSpace * 5,
                ),
                child: Wrap(
                  spacing: UIConstants.bigSpace,
                  runSpacing: UIConstants.bigSpace,
                  alignment: WrapAlignment.center,
                  children: promotionList.map((e) {
                    return PromotionWidget(
                      promotionModel: e,
                      index: promotionList.indexOf(e) + 1,
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          if (userModel != null && userModel.userLevel == UserLevel.merchant)
            Positioned(
              bottom: 30,
              right: 30,
              child: CusTxtIconElevatedBtn(
                txt: "Create new promotion",
                verticalpadding: UIConstants.mediumSpace,
                horizontalpadding: UIConstants.bigSpace,
                bdrRadius: UIConstants.mediumRadius,
                bgClr: Colors.pinkAccent,
                func: () {
                  widget.goToCreateScreen();
                },
                txtStyle: Theme.of(context).textTheme.titleSmall!,
                txtClr: Colors.white,
                icon: Icons.add,
                iconSize: UIConstants.normalNormalIconSize,
              ),
            ),
        ],
      ),
    );
  }
}

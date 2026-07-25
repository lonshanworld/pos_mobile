import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:pos_mobile/blocs/shop_info_bloc/shop_info_cubit.dart";
import "package:pos_mobile/blocs/theme_bloc/theme_cubit.dart";
import "package:pos_mobile/blocs/userData_bloc/user_data_cubit.dart";
import "package:pos_mobile/constants/business_type_utils.dart";
import "package:pos_mobile/constants/enums.dart";
import "package:pos_mobile/constants/uiConstants.dart";
import "package:pos_mobile/controller/ui_controller.dart";

import "package:pos_mobile/models/user_model_folder/user_model.dart";
import "package:pos_mobile/routes/drawer_pagemodelList.dart";
import "package:pos_mobile/screens/drawers/drawerinlarge_screen.dart";

import "package:pos_mobile/screens/drawers/drawerinsmall_screen.dart";
import "package:pos_mobile/screens/authenticaton/check_user_screen.dart";

import "package:pos_mobile/widgets/btns_folder/cusIconBtn_widget.dart";
import "package:pos_mobile/widgets/cusAppbar_widget.dart";
import "package:pos_mobile/widgets/loading_widget.dart";
import "package:pos_mobile/languages/app_strings.dart";

import "../features/logout_feature.dart";
import "../constants/txtconstants.dart";

class HomeScreen extends StatefulWidget {
  static const String routeName = "/homescreen";

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int pageIndex = 0;
  late final PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: pageIndex, keepPage: true);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserModel? userModel = context.select(
      (UserDataCubit cubit) => cubit.state.userModel,
    );
    final UIController uiController = UIController.instance;
    final ThemeModeType themeModeType = context.select(
      (ThemeCubit cubit) => cubit.state.themeModeType,
    );
    final BusinessType businessType = context.select(
      (ShopInfoCubit cubit) => cubit.state.businessType,
    );
    final bool showThemeToggle = businessType.allowsThemeToggle;
    final strings = AppStrings.of(context);
    final pages = PageList.getPages(userModel?.userLevel ?? UserLevel.merchant);
    final int safePageIndex = pages.isEmpty
        ? 0
        : pageIndex.clamp(0, pages.length - 1);

    if (pageIndex != safePageIndex && pages.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          pageIndex = safePageIndex;
        });
        pageController.jumpToPage(safePageIndex);
      });
    }

    void changePage(int value) {
      setState(() {
        pageIndex = value;
        pageController.jumpToPage(value);
      });
    }

    void logoutFunc() async {
      if (userModel == null) {
        Logout.forceLogout();
        return;
      }

      final bool isOwner =
          userModel.userLevel == UserLevel.merchant ||
          userModel.userLevel == UserLevel.superAdmin;

      if (isOwner) {
        final navigator = Navigator.of(context);
        bool value = await Logout.logout(context);
        if (value) {
          if (!mounted) return;
          navigator.pushNamedAndRemoveUntil(
            CheckUserScreen.routeName,
            (route) => false,
          );
        }
      } else {
        Logout.forceLogout();
      }
    }

    return PopScope(
      // onWillPop: ()async{
      //   return await Logout.logout(context);
      // },
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        logoutFunc();
      },
      child: LayoutBuilder(
        builder: (BuildContext ctx, BoxConstraints constraints) {
          if (userModel == null) {
            return const Center(child: LoadingWidget());
          } else {
            if (constraints.maxWidth > UIConstants.screenBreakPoint) {
              return Scaffold(
                body: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: UIConstants.bigDrawerWidth,
                      child: DrawerInLargeScreen(
                        func: changePage,
                        currentIndex: pageIndex,
                      ),
                    ),
                    // const VerticalDivider(
                    //   thickness: 2,
                    //   color: Colors.grey,
                    //   width: 2,
                    // ),
                    Expanded(
                      child: Column(
                        children: [
                          CusAppBar(
                            txt: TxtConstants.shopName,
                            showThemeToggle: showThemeToggle,
                          ),
                          Expanded(
                            child: PageView(
                              controller: pageController,
                              physics: const NeverScrollableScrollPhysics(),
                              children: pages.map((e) => e.screen).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Scaffold(
                appBar: AppBar(
                  centerTitle: true,
                  title: Text(strings.pageTitle(pages[safePageIndex].title)),
                  leading: Builder(
                    builder: (ctx) {
                      return CusIconBtn(
                        size: UIConstants.bigIcon,
                        func: () {
                          Scaffold.of(ctx).openDrawer();
                        },
                        clr: uiController.getpureOppositeClr(themeModeType),
                        icon: Icons.menu_open_rounded,
                      );
                    },
                  ),
                  actions: [
                    if (showThemeToggle)
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
                      ),
                  ],
                ),
                drawer: DrawerInSmallScreen(
                  func: changePage,
                  currentIndex: pageIndex,
                ),
                body: PageView(
                  controller: pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: pages.map((e) => e.screen).toList(),
                ),
              );
            }
          }
        },
      ),
    );
  }
}

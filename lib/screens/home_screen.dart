import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:pos_mobile/blocs/theme_bloc/theme_cubit.dart";
import "package:pos_mobile/blocs/userData_bloc/user_data_cubit.dart";
import "package:pos_mobile/constants/enums.dart";
import "package:pos_mobile/constants/uiConstants.dart";
import "package:pos_mobile/controller/ui_controller.dart";

import "package:pos_mobile/models/user_model_folder/user_model.dart";
import "package:pos_mobile/routes/drawer_pagemodelList.dart";
import "package:pos_mobile/screens/drawers/drawerinlarge_screen.dart";

import "package:pos_mobile/screens/drawers/drawerinsmall_screen.dart";

import "package:pos_mobile/widgets/btns_folder/cusIconBtn_widget.dart";
import "package:pos_mobile/widgets/cusAppbar_widget.dart";
import "package:pos_mobile/widgets/loading_widget.dart";

import "../feature/logout_feature.dart";


class HomeScreen extends StatefulWidget {
  static const String routeName = "/homescreen";

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int pageIndex = 0;



  @override
  Widget build(BuildContext context) {
    UserModel? userModel= context.watch<UserDataCubit>().state.userModel;
    final UIController uiController = UIController.instance;
    final ThemeModeType themeModeType = context.watch<ThemeCubit>().state.themeModeType;

    PageController pageController = PageController(
      initialPage: pageIndex,
      keepPage: true,
    );

    void changePage(int value){
      setState(() {
        pageIndex = value;
        pageController.jumpToPage(value);
      });
    }

    void logoutFunc()async{
      bool value = await Logout.logout(context);
      if(value)Logout.forceLogout();
    }

    return PopScope(
      // onWillPop: ()async{
      //   return await Logout.logout(context);
      // },
      canPop: false,
      onPopInvoked: (value) {
        logoutFunc();
      },
      child: LayoutBuilder(
        builder: (BuildContext ctx, BoxConstraints constraints){
          if(userModel == null){
            return const Center(
              child: LoadingWidget(),
            );
          }else{
            if(constraints.maxWidth > UIConstants.screenBreakPoint){
              return Scaffold(
                body: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: UIConstants.bigDrawerWidth,
                      child:  DrawerInLargeScreen(
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
                          const CusAppBar(txt: "ME - Medical Equipments"),
                          Expanded(
                            child: PageView(
                              controller: pageController,
                              physics: const NeverScrollableScrollPhysics(),
                              children: PageList.getPages(userModel.userLevel).map((e) => e.screen).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }else{
              return Scaffold(
                appBar: AppBar(
                  centerTitle: true,
                  title: Text(
                    PageList.getPages(userModel.userLevel)[pageIndex].title,
                  ),
                  leading: Builder(
                      builder: (ctx) {
                        return CusIconBtn(
                          size: UIConstants.bigIcon,
                          func: (){
                            Scaffold.of(ctx).openDrawer();
                          },
                          clr: uiController.getpureOppositeClr(themeModeType),
                          icon: Icons.menu_open_rounded,
                        );
                      }
                  ),
                  actions: [
                    CusIconBtn(
                      size: UIConstants.bigIcon,
                      func: (){
                        context.read<ThemeCubit>().switchTheme();
                      },
                      clr: themeModeType == ThemeModeType.light ? Colors.orange : Colors.purple,
                      icon: themeModeType == ThemeModeType.light ? Icons.light_mode : Icons.dark_mode,
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
                  children: PageList.getPages(userModel.userLevel).map((e) => e.screen).toList(),
                ),
              );
            }
          }
        },
      ),
    );

  }
}

import "package:flutter/material.dart";
import "package:pos_mobile/constants/uiConstants.dart";
import "package:pos_mobile/screens/accounts/checkallAccount_screen.dart";
import 'package:pos_mobile/screens/accounts/create_useraccount_screen.dart';

class AccountScreen extends StatelessWidget {
  static const String routeName = "/accountscreen";


  const AccountScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController(
      initialPage: 0,
    );

    void goToCreateScreen(){
      pageController.jumpToPage(1);
    }

    void goBackToCheckAllAccountScreen(){
      pageController.jumpToPage(0);
    }

    return Padding(
      padding: const EdgeInsets.only(
        top: UIConstants.mediumSpace,
      ),
      child: PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          CheckAllAccountScreen(goToCreateScreen: goToCreateScreen,),
          CreateUserScreen(goBack : goBackToCheckAllAccountScreen,),
        ],
      ),
    );
  }
}

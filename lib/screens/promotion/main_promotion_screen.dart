import 'package:flutter/material.dart';
import 'package:pos_mobile/screens/promotion/create_promotion_screen.dart';
import 'package:pos_mobile/screens/promotion/promotion_list_screen.dart';

class MainPromotionScreen extends StatelessWidget {
  const MainPromotionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController(initialPage: 0);

    void goToPromotionListScreen(){
      pageController.jumpToPage(0);
    }

    void goToCreatePromotionScreen(){
      pageController.jumpToPage(1);
    }

    return PageView(
      controller: pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        PromotionListScreen(goToCreateScreen: goToCreatePromotionScreen,),
        CreatePromotionScreen(goBackToListScreen: goToPromotionListScreen,),
      ],
    );
  }
}

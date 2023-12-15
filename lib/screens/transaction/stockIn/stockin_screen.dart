import 'package:flutter/material.dart';

import 'package:pos_mobile/screens/transaction/stockIn/category/category_screen.dart';
import 'package:pos_mobile/screens/transaction/stockIn/group/group_screen.dart';

import 'package:pos_mobile/screens/transaction/stockIn/type/type_screen.dart';


class StockInScreen extends StatefulWidget {
  static const String routeName = "/stockinscreen";

  final bool isStorage;
  const StockInScreen({
    super.key,
    required this.isStorage,
  });

  @override
  State<StockInScreen> createState() => _StockInScreenState();
}

class _StockInScreenState extends State<StockInScreen> {
  int? selectedCategoryId;
  int? selectedGroupId;

  int? selectedItemId;

  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController(
      initialPage: 0,
    );

    void goToCategoryScreen(){
      pageController.jumpToPage(0);
    }

    void goToGroupScreen(){
      pageController.jumpToPage(1);
    }

    void goToTypeScreen(){
      pageController.jumpToPage(2);
    }



    void setSelectedCategoryId(int value){
      setState(() {
        selectedCategoryId = value;
      });
      goToGroupScreen();
    }

    void setSelectedGroupId(int value){
      setState(() {
        selectedGroupId = value;
      });
      goToTypeScreen();
    }




    return PageView(
      controller: pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        CategoryScreen(
          setSelectedCategoryId: (value) {
            setSelectedCategoryId(value);
          },
          isStorage: widget.isStorage,
        ),
        GroupScreen(
          selectedCategoryId: selectedCategoryId,
          goBackFunc: goToCategoryScreen ,
          setSelectedGroupId: (int value) {
            setSelectedGroupId(value);
          },
          isStorage: widget.isStorage,
        ),
        TypeScreen(
          selectedGroupId: selectedGroupId,
          goBackFunc: goToGroupScreen,
          isStorage: widget.isStorage,
        ),
      ],
    );
  }
}

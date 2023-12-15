import "package:flutter/material.dart";

import "package:pos_mobile/constants/uiConstants.dart";
import "package:pos_mobile/controller/ui_controller.dart";
import "package:pos_mobile/utils/debug_print.dart";
import "package:pos_mobile/widgets/cusTxt_widget.dart";

class LoadingScreen extends StatelessWidget {

  final String txt;

  final Color clr;
  final Widget widget;
  const LoadingScreen({
    super.key,
    required this.txt,

    required this.widget,
    required this.clr,
  });

  @override
  Widget build(BuildContext context) {
    final UIController uiController = UIController.instance;

    return PopScope(
      // onWillPop: ()async{
      //   cusDebugPrint("prevent back key");
      //   return false;
      // },
      canPop: false,
      child: Container(
        width: uiController.getDeviceWidth,
        height: uiController.getDeviceHeight,
        color: Colors.transparent,
        child: Center(
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 300,
              minWidth: 100,
              minHeight: 100,
              maxHeight: 300,
            ),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: UIConstants.bigBorderRadius,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5), // Shadow color
                  spreadRadius: 3, // How far the shadow spreads
                  blurRadius: 5, // The intensity of the blur effect
                  offset: const Offset(0, 3), // Offset of the shadow (X, Y)
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: UIConstants.bigLoadingIconSize,
                  height: UIConstants.bigLoadingIconSize,
                  child: widget,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: UIConstants.bigSpace,
                  ),
                  child: CusTxtWidget(
                    txt: txt,
                    txtStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: clr,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

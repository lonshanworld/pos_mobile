import "package:flutter/material.dart";

import "../constants/uiConstants.dart";
import "cusTxt_widget.dart";

class NoItemWidget extends StatelessWidget {

  final String noItemTxt;
  const NoItemWidget({
    super.key,
    required this.noItemTxt,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 220,
        height: 180,
        padding: const EdgeInsets.all(UIConstants.mediumSpace),
        decoration: BoxDecoration(
          borderRadius: UIConstants.bigBorderRadius,
          border: Border.all(color: Colors.grey.withOpacity(0.7)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.not_interested,
              size: 50,
              color: Colors.grey.withOpacity(0.7),
            ),
            CusTxtWidget(
              txtStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Colors.grey.withOpacity(0.7),
              ),
              txt: noItemTxt,
            ),
          ],
        ),
      ),
    );
  }
}

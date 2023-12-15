import 'package:flutter/material.dart';
import 'package:pos_mobile/constants/uiConstants.dart';

class DrawerWidget extends StatelessWidget {

  final int index;
  final String txt;
  final VoidCallback func;
  final bool isSelected;
  const DrawerWidget({
    super.key,
    required this.index,
    required this.txt,
    required this.func,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.grey.withOpacity(0.1),
      onTap: func,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: UIConstants.smallSpace + 2,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.purpleAccent.withOpacity(0.5): Colors.transparent,
          borderRadius: UIConstants.mediumBorderRadius,
        ),
        margin: const EdgeInsets.symmetric(
          vertical: UIConstants.mediumSpace - 2,
          horizontal: 2 * UIConstants.bigSpace,
        ),
        alignment: Alignment.center,
        child: Text(
          txt,
          style: Theme.of(context).textTheme.titleSmall,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

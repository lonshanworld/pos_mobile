import "package:flutter/material.dart";

class CusIconBtn extends StatelessWidget {

  final double size;
  final VoidCallback func;
  final Color clr;
  final IconData icon;
  final bool hasBorder;

  const CusIconBtn({
    super.key,
    required this.size,
    required this.func,
    required this.clr,
    required this.icon,
    this.hasBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: IconButton.styleFrom(
        foregroundColor: clr,
        side: hasBorder ? BorderSide(color: clr, width: 1.0) : BorderSide.none,
      ),
      onPressed: func,
      icon: Icon(
        icon,
        color: clr,
        size: size,
      ),
    );
  }
}

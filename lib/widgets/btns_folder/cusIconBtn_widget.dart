import "package:flutter/material.dart";

class CusIconBtn extends StatelessWidget {

  final double size;
  final VoidCallback func;
  final Color clr;
  final IconData icon;
  const CusIconBtn({
    super.key,
    required this.size,
    required this.func,
    required this.clr,
    required this.icon
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: IconButton.styleFrom(
        foregroundColor: clr,
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

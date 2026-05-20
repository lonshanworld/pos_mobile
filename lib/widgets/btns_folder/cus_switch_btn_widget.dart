import "package:flutter/material.dart";

class CusSwitchBtnWidget extends StatelessWidget {

  final bool boolValue;
  final Function(bool value) func;
  final Color clr;
  const CusSwitchBtnWidget({
    super.key,
    required this.boolValue,
    required this.func,
    required this.clr,
  });

  @override
  Widget build(BuildContext context) {
    return Switch(
      activeThumbColor: clr,
      activeTrackColor: clr.withValues(alpha: 0.3),
      inactiveThumbColor: Colors.grey.withValues(alpha: 0.7),
      inactiveTrackColor: Colors.grey.withValues(alpha: 0.2),
      value: boolValue,
      onChanged: func,
    );
  }
}

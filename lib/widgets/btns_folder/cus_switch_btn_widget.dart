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
      activeThumbColor: Colors.green.shade700,
      activeTrackColor: Colors.green.shade200,
      inactiveThumbColor: Colors.red.shade700,
      inactiveTrackColor: Colors.red.shade200,
      value: boolValue,
      onChanged: func,
    );
  }
}

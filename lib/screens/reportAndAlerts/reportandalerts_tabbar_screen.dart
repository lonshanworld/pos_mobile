import 'package:flutter/material.dart';

class ReportAndAlertTabScreen extends StatelessWidget {
  static const String routeName = "/reportandalertscreen";

  const ReportAndAlertTabScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(
        child: Text(
          "This is $routeName screen",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}

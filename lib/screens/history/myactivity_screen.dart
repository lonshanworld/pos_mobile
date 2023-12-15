import 'package:flutter/material.dart';

class MyActivityScreen extends StatelessWidget {
  static const String routeName = "/myactivityscreen";

  const MyActivityScreen({super.key});

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

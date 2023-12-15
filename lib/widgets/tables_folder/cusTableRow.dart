import 'package:flutter/material.dart';

class CusTableRow{

  static Widget txtWidget(String txt,BuildContext context){
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Text(
        txt,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium!,
      ),
    );
  }

  static TableRow tableRowWithThreeStringsForStockOutHistory(String txt1, String txt2, String txt3, BuildContext context){
    return TableRow(
        children: [
          txtWidget(txt1, context),
          txtWidget(txt2, context),
          txtWidget(txt3, context),
        ]
    );
  }
}
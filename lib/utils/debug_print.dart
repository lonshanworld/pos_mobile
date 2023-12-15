import 'package:flutter/foundation.dart';

void cusDebugPrint(dynamic data){
  assert(() {
    if (kDebugMode) {
      print(data);
    }
    return true; // Always return true to make assert pass in release mode.
  }());
}
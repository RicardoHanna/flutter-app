import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class LoadingHelper {
  static void configureLoading() {
    EasyLoading.instance
      ..displayDuration = const Duration(seconds: 3)
      ..loadingStyle = EasyLoadingStyle.custom
      ..indicatorSize = 45.0
      ..radius = 10.0
      ..progressColor = Colors.blue.shade900
      ..backgroundColor = Colors.blue
      ..indicatorColor = Colors.white
      ..textColor = Colors.white
      ..textStyle = const TextStyle(fontSize: 22, fontStyle: FontStyle.italic);
  }

  static void showLoading() {
    EasyLoading.show();
  }

  static void dismissLoading() {
    EasyLoading.dismiss();
  }
}

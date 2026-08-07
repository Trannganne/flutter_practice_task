import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Apptoast {
  static void show(String message) {
    Fluttertoast.cancel();

    Fluttertoast.showToast(
      msg: message,
      textColor: Colors.white,
      backgroundColor: Colors.blueAccent,
      gravity: ToastGravity.CENTER,
      toastLength: Toast.LENGTH_SHORT,
    );
  }
}

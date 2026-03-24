import 'package:flutter/material.dart';

class MyProgressIndicator {
  static dynamic showProgressIndicator(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(
          ),
        );
      },
    );
  }
}
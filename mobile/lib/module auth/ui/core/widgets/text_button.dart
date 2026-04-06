import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

//import 'package:shop/core/misc/extensions.dart';

class MyTextButton extends StatelessWidget {
  final String? text;
  final String buttonText;
  final String routeName;

  const MyTextButton({
    super.key,
    this.text,
    required this.buttonText,
    required this.routeName
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
      context.pushReplacement(
          routeName,
        );
      },
      child: Column(
        children: [
          Text(
            '$text',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            buttonText,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
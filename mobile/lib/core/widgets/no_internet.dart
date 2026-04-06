import 'package:flutter/material.dart';

class BuildNoInternet extends StatelessWidget {
  const BuildNoInternet({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Image.asset(
            'assets/images/no-internet.png',
          ),
        ),
        Center(
          child: Text(
            "No internet connection!",
          ),
        )
      ],
    );
  }
}

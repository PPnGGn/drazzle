import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Image.asset(
        'assets/png/background_img.png',
        fit: BoxFit.cover,
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
      ),
    );
  }
}

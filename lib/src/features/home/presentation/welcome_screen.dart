import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          context.go('/menu');
        },
        child: Stack(
          children: [
            Container(
              color: Colors.black,
            ),
            Opacity(
              opacity: 0.9,
              child: Image.asset(
                'assets/images/pc_bg.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            Center(
              child: Image.asset(
                "assets/images/pc_startordering.png",
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
            Image.asset(
              'assets/images/pc_bg.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                width: double.infinity,
                height: 120,
                child: Center(
                  child: Image.asset("assets/images/startordering.png"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

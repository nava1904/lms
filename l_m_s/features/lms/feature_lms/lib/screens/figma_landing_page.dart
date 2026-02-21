import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FigmaLandingPage extends StatelessWidget {
  const FigmaLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('LMS', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.go('/login'),
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

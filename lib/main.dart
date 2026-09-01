import 'package:flutter/material.dart';

void main() {
  runApp(const RootsApp());
}

/// Sprint 0 shell: proves the pinned toolchain builds, runs, and tests.
/// Product screens arrive in later sprints; the contract lives in docs/.
class RootsApp extends StatelessWidget {
  const RootsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plant Selfie',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF10151C),
      ),
      home: const Scaffold(
        body: Center(
          child: Text(
            'PLANT SELFIE',
            style: TextStyle(
              color: Color(0xFFF4F7F8),
              fontSize: 24,
              letterSpacing: 4,
            ),
          ),
        ),
      ),
    );
  }
}

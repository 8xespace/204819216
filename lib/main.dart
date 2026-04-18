import 'package:flutter/material.dart';

import 'intro/intro_splash.dart';

void main() {
  runApp(const Game204819216App());
}

class Game204819216App extends StatelessWidget {
  const Game204819216App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '204819216',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD39A52)),
        scaffoldBackgroundColor: const Color(0xFFFAF8EF),
        useMaterial3: true,
      ),
      home: const IntroSplash3sEndAt4s(),
    );
  }
}

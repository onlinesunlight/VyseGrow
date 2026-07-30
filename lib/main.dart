import 'package:flutter/material.dart';
import 'home_screen.dart';

void main() {
  runApp(const VyseGrowApp());
}

class VyseGrowApp extends StatelessWidget {
  const VyseGrowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VyseGrow Capitals',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F9FC),
      ),
      home: const HomeScreen(),
    );
  }
}

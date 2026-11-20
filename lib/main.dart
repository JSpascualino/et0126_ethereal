import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const EtherealApp());
}

class EtherealApp extends StatelessWidget {
  const EtherealApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ethereal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFB39DDB)),
        useMaterial3: true,
      ),
      home:  HomeScreen(),
    );
  }
}
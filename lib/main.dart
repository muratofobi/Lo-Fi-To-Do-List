import 'package:flutter/material.dart';
import 'screens/main_wrapper.dart';

void main() {
  runApp(const LoFiToDoApp());
}

class LoFiToDoApp extends StatelessWidget {
  const LoFiToDoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chill To-Do',
      theme: ThemeData(
        fontFamily: 'Courier',
        scaffoldBackgroundColor: const Color(0xFF141526),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE5A96A),
          surface: Color(0xFF282A45),
        ),
      ),
      home: const MainWrapper(),
    );
  }
}

import 'package:ai_medi_app/screens/Chat_Screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Health Assistant',
      theme: ThemeData(
        fontFamily: 'SF Pro Display',
        primaryColor: Colors.cyanAccent,
        scaffoldBackgroundColor: Color(0xFFF8FFFE),
        colorScheme: ColorScheme.light(
          primary: Colors.cyanAccent,
          secondary: Colors.blueAccent,
          surface: Colors.white,
        ),
        appBarTheme: AppBarThemeData(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.cyanAccent),
          titleTextStyle: TextStyle(
            color: Color(0XFF1A1A1A),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      home: ChatScreen(),
    );
  }
}

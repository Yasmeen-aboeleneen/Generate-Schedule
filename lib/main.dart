import 'package:flutter/material.dart';
import 'package:generate_schedule_app/Views/Home/home_screen.dart';
import 'package:generate_schedule_app/Views/Home/schedule_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

   @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Generate Schedule',
          home: HomeScreen(),

    );
  }
}

 
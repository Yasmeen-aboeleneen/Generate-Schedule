import 'package:flutter/material.dart';
import 'package:generate_schedule_app/Core/Constants/colors.dart';
import 'package:generate_schedule_app/Views/Home/Widgets/custom_appbar.dart';
import 'package:generate_schedule_app/Views/Home/home_screen_body.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // var h = MediaQuery.of(context).size.height;
    // var w = MediaQuery.of(context).size.width;
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: kPrimary3,
          child: Icon(
            Icons.add,
            color: kPrimary,
          ),
          onPressed: () {},
        ),
        backgroundColor: kveryWhite,
        body: Column(
          children: [CustomAppbar(), HomeScreenBody()],
        ));
  }
}

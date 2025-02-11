import 'package:flutter/material.dart';
import 'package:generate_schedule_app/Core/Constants/colors.dart';

class CustomAppbar extends StatelessWidget {
  const CustomAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    return Container(
      height: h * .14,
      width: w,
      decoration: BoxDecoration(
          color: kPrimary,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40))),
      child: Center(
        child: Text(
          "Generate Schedule",
          style: TextStyle(
              color: kPrimary3, fontWeight: FontWeight.bold, fontSize: 25),
        ),
      ),
    );
  }
}

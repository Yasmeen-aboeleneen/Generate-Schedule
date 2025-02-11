import 'package:flutter/material.dart';
 
class HomeScreenBody extends StatelessWidget {
  const HomeScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    // var w = MediaQuery.of(context).size.width;
    return Column(
      children: [
        SizedBox(
          height: h * .05,
        ),
         
      ],
    );
  }
}

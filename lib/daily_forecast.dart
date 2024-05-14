import 'package:flutter/material.dart';
import 'package:my_weather_app/widgets/Custom_text.dart';

class ForecastContainer extends StatelessWidget {
  ForecastContainer(
      {super.key,
      required this.icon,
      required this.date,
      required this.temp,
      required this.height,
      required this.width});
  IconData icon;
  final date;
  final temp;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      //margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Color(0xFFFFE142),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Custom_text(text: temp, fontSize: 17, fontWeight: FontWeight.bold),
          Icon(
            icon,
            size: 20,
          ),
          Custom_text(text: date, fontSize: 11, fontWeight: FontWeight.w600),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Custom_text extends StatelessWidget {
  const Custom_text({
    super.key,
    required this.text,
    required this.fontSize,
    required this.fontWeight,
    this.color,
  });
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.lato(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color != null ? color : Colors.black,
      ),
    );
  }
}

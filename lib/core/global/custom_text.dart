import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String? text;
  final double? size;
  final Color? color;
  final FontWeight? weight;
  final TextAlign? textAlign;
  final FontStyle? fontStyle;
  final TextStyle? textStyle;

  const CustomText({
    this.text,
    this.size,
    this.color,
    this.weight,
    this.textAlign,
    this.fontStyle,
    this.textStyle,
    super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text!,
      textAlign: textAlign,
      style: textStyle ?? TextStyle(
          color: color,
          fontSize: size,
          fontWeight: weight,
          fontStyle: fontStyle
      ),
    );
  }
}
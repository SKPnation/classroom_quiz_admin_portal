import 'package:classroom_quiz_admin_portal/core/theme/colors.dart';
import 'package:classroom_quiz_admin_portal/core/utils/helpers/size_helpers.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String? text;
  final Widget? child;
  final Color? bgColor;
  final Color? borderColor;
  final Color? textColor;
  final bool? showBorder;
  final double? radius;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Function()? onPressed;
  final double? borderWidth;

  const CustomButton({
    super.key,
    this.text,
    required this.onPressed,
    this.child,
    this.bgColor,
    this.borderColor,
    this.showBorder = false,
    this.radius,
    this.textColor,
    this.fontSize,
    this.borderWidth,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    final bw = (showBorder ?? false) ? (borderWidth ?? 1) : 0.0;
    final bc = borderColor ?? Colors.transparent;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor ?? AppColors.purple,
        minimumSize: Size(displayWidth(context), 44),
        // shadowColor: AppColors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius ?? 8),
          side: BorderSide(width: bw, color: bc),
        ),
      ),
      onPressed: onPressed,
      child:
          child ??
          Text(
            text!,
            style: TextStyle(
              fontSize: fontSize,
              color: textColor ?? AppColors.white,
              fontWeight: fontWeight,
            ),
          ),
    );
  }
}

class Btn extends StatelessWidget {
  const Btn({
    super.key,
    this.label,
    required this.onPressed,
    this.primary = false,
    this.width,
    this.child,
  });

  final String? label;
  final VoidCallback onPressed;
  final bool primary;
  final double? width;
  final Widget? child;

  factory Btn.primary({
    required String label,
    required VoidCallback onPressed,
  }) => Btn(label: label, onPressed: onPressed);

  @override
  Widget build(BuildContext context) {
    final border = primary ? null : AppColors.grey[300]!.withValues(alpha: 0.2);
    final bgColor = primary ? AppColors.purple : AppColors.white;
    final textColor = primary ? AppColors.white : AppColors.black;

    return SizedBox(
      width: width ?? 150,
      child: CustomButton(
        onPressed: onPressed,
        text: label,
        bgColor: bgColor,
        showBorder: true,
        borderColor: border,
        textColor: textColor,
        child: child,
      ),
    );
  }
}

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
  final double? fontSize;
  final Function()? onPressed;

  const CustomButton({
    super.key,
    this.text,
    required this.onPressed,
    this.child,
    this.bgColor,
    this.borderColor,
    this.showBorder = false,
    this.textColor,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor ?? AppColors.purple,
        minimumSize: Size(displayWidth(context), 44),
        shadowColor: AppColors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide(
            width: showBorder! ? 1 : 0,
            color: borderColor ?? AppColors.purple,
          ),
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
            ),
          ),
    );
  }
}

class Btn extends StatelessWidget {
  const Btn({super.key,
    required this.label,
    required this.onPressed,
    this.primary = false,
    this.width
  });

  final String label;
  final VoidCallback onPressed;
  final bool primary;
  final double? width;

  factory Btn.primary({
    required String label,
    required VoidCallback onPressed,
  }) => Btn(label: label, onPressed: onPressed);

  @override
  Widget build(BuildContext context) {
    final border = primary ? AppColors.purple : AppColors.grey[200];
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
      ),
    );
  }
}

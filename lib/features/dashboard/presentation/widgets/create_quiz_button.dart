import 'package:classroom_quiz_admin_portal/core/constants/app_strings.dart';
import 'package:classroom_quiz_admin_portal/core/global/custom_button.dart';
import 'package:classroom_quiz_admin_portal/core/theme/fonts.dart';
import 'package:flutter/material.dart';

class CreateQuizButton extends StatelessWidget {
  const CreateQuizButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Btn(onPressed: () {}, label: AppStrings.createQuizTitle, primary: true,);
  }
}

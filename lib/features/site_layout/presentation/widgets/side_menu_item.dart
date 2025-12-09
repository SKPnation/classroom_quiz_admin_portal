import 'package:classroom_quiz_admin_portal/features/site_layout/presentation/widgets/horizontal_menu_item.dart';
import 'package:flutter/material.dart';

class SideMenuItem extends StatelessWidget {
  final String? itemName;
  final Function()? onTap;

  const SideMenuItem({super.key, this.itemName, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // itemName == AppStrings.logoutTitle
        //     ? SizedBox(height: displayHeight(context) / 3)
        //     : const SizedBox(),
        HorizontalMenuItem(itemName: itemName!, onTap: onTap!),
      ],
    );
  }
}

import 'package:classroom_quiz_admin_portal/core/utils/helpers/size_helpers.dart';
import 'package:flutter/cupertino.dart';

const int largeScreenSize = 1366;
const int mediumScreenSize = 768;
const int smallScreenSize = 360;
const int customScreenSize = 1100;

class ResponsiveWidget extends StatelessWidget {

  final Widget? largeScreen;
  final Widget? mediumScreen;
  final Widget? smallScreen;
  //final Widget? customScreen;

  const ResponsiveWidget(
      {Key? key,
        this.largeScreen,
        this.mediumScreen,
        this.smallScreen})
      : super(key: key);

  static bool isSmallScreen(BuildContext context)=>
      displayWidth(context) < mediumScreenSize;

  static bool isMediumScreen(BuildContext context)=>
      displayWidth(context) >= mediumScreenSize &&
          displayWidth(context) < largeScreenSize;

  static bool isLargeScreen(BuildContext context)=>
      displayWidth(context) >= largeScreenSize;

  static bool isCustomScreen(BuildContext context)=>
      displayWidth(context) >= mediumScreenSize &&
          displayWidth(context) <= customScreenSize;


  @override
  Widget build(BuildContext context) {
    if (isSmallScreen(context)) {
      return smallScreen ?? largeScreen!;
    } else if (isMediumScreen(context)) {
      return mediumScreen ?? largeScreen!;
    }
    return largeScreen!;
  }
}
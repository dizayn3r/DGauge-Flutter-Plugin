import 'package:flutter/material.dart';

abstract class AppColors {
  static const blackColor = Colors.black;
  static const white = Colors.white;
  static const dawnPink = Color(0xFFEBEBEB);
  static const porclainColor = Color(0xFFF2F2F2);
  static const busYellow = Color(0xFFDDA31D);
  static const boulderColor = Color(0xFF7A7A7A);
  static const lightGreyColor2 = Color(0xFFD9D9D9);
  static const errorRedColor = Color(0xFFE26844);
  static const errorRedLightColor = Color(0xFFFFE4E2);

  static const greenColor = Color(0xFF8DC153);
  static const greenLightColor = Color(0xFFEDFFE8);

  static const marineColor = Color(0xFF123064);
  static const black2Color = Color(0XFF4B4B4B);
  static const monsoonColor = Color(0xFF888888);
  static const healthCardColor = Color(0xFF3E64FF);
  static const lightOrange = Color(0xFFFF801C);
  static const lightGreyColor = Color(0xFFF0F3F5);
  static const lightPurpleColor = Color(0xFFF4ECFD);
  static const textGreyColor = Color(0xFF6B779A);
  static const paleGreen = Color(0xFFE8FFEE);
  static const paleYellow = Color(0xFFF8F6E6);
  static const navyBlue = Color(0xFF193364);
  static const marigold = Color(0xfffdbc00);
  static const lightBlue = Color(0xff3bafda);

  static const bgColor = Color(0XFFF7F8F8);

  static const inDarkGrey = Color(0xFF545e64);

  static const inSilver = Color(0xffbbbfc1);
  static const inLightRed = Color(0xfffd4344);
  static const inTurtleGreen = Color(0xff8cc152);

  static const textHighlightingColor = Color(0xff3bafda);
  static const failureColor = Color(0xfffd4344);

  static const titleTextColor = AppColors.navyBlue;
  static const descriptiveTextColor = Color(0xFF545e64);
  static const ghostTextColor = Color(0xFFbbbfc1);
  static const antiFlashWhite = Color(0XFFFBFBFB);

  static const MaterialColor primary = MaterialColor(0xfffdbc00, {
    50: Color.fromRGBO(253, 188, 0, .1),
    100: Color.fromRGBO(253, 188, 0, .2),
    200: Color.fromRGBO(253, 188, 0, .3),
    300: Color.fromRGBO(253, 188, 0, .4),
    400: Color.fromRGBO(253, 188, 0, .5),
    500: Color.fromRGBO(253, 188, 0, .6),
    600: Color.fromRGBO(253, 188, 0, .7),
    700: Color.fromRGBO(253, 188, 0, .8),
    800: Color.fromRGBO(253, 188, 0, .9),
    900: Color.fromRGBO(253, 188, 0, 1),
  });

  static getStatusBoxTextColor(String value){
    switch (value) {
      case "requested":
        return StatusColors.requestedTextColor;
      case "approved":
        return StatusColors.approvedTextColor;
      case "dispatched to vendor":
        return StatusColors.dispatchedToVendorTextColor;
      case "in retread":
        return StatusColors.inRetreadTextColor;
      case "dispatched to hub":
        return StatusColors.dispatchedToHubTextColor;
      case "invoice rejected":
        return StatusColors.invoiceRejectedTextColor;
      case "completed":
        return StatusColors.completedTextColor;
      default:
        return Colors.red;
    }
  }

  static getStatusBoxBgColor(String value){
    switch (value) {
      case "requested":
        return StatusColors.requestedBgColor;
      case "approved":
        return StatusColors.approvedBgColor;
      case "dispatched to vendor":
        return StatusColors.dispatchedToVendorBgColor;
      case "in retread":
        return StatusColors.inRetreadBgColor;
      case "dispatched to hub":
        return StatusColors.dispatchedToHubBgColor;
      case "invoice rejected":
        return StatusColors.invoiceRejectedBgColor;
      case "completed":
        return StatusColors.completedBgColor;
      default:
        return Colors.red.shade100;
    }
  }
}

class StatusColors {
  /// Requested
  static Color requestedTextColor = Colors.amber;
  static Color requestedBgColor = Colors.amber.shade100;
  /// Approved
  static Color approvedTextColor = Colors.green;
  static Color approvedBgColor = Colors.green.shade100;
  /// Dispatched To Vendor
  static Color dispatchedToVendorTextColor = Colors.cyan;
  static Color dispatchedToVendorBgColor = Colors.cyan.shade100;
  /// In Retread
  static Color inRetreadTextColor = Colors.blue;
  static Color inRetreadBgColor = Colors.blue.shade100;
  /// Dispatched To Hub
  static Color dispatchedToHubTextColor = Colors.indigo;
  static Color dispatchedToHubBgColor = Colors.indigo.shade100;
  /// Invoice Rejected
  static Color invoiceRejectedTextColor = Colors.red;
  static Color invoiceRejectedBgColor = Colors.red.shade100;

  /// Completed
  static Color completedTextColor = Colors.grey.shade900;
  static Color completedBgColor = Colors.grey.shade400;
}

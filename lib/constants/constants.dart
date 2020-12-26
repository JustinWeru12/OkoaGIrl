import 'package:flutter/material.dart';

const kPrimaryColor = Color(0xFF900C3F);
const kSecondaryColor = Color(0xFF581845);
const kTertiaryColor = Color(0xFF8D8D8D);
const kTextColor = Color(0xFF000000);
const kBackgroundColor = Color(0xFFE9D5CA);
const kActionColor = Color(0xFF2887C8);
const kInfectedColor = Color(0xFFFF8748);
const kDeathColor = Color(0xFFFF4848);
const kRecovercolor = Color(0xFF36C12C);
final kShadowColor = Color(0xFFB7B7B7).withOpacity(.16);
// Text Style
const kHeadingTextStyle = TextStyle(
  fontSize: 22,
  fontWeight: FontWeight.w600,
);

const kBoardingTextStyle = TextStyle(
  fontSize: 28,
  color: kSecondaryColor,
  fontWeight: FontWeight.w700,
);

const kSubTextStyle = TextStyle(fontSize: 16,fontWeight: FontWeight.w600, color: kTertiaryColor);
const kAlertTextStyle = TextStyle(fontSize: 16, color: kSecondaryColor);

const kTitleTextstyle = TextStyle(
  fontSize: 18,
  color: kTextColor,
  fontWeight: FontWeight.bold,
);

const kContentTextstyle = TextStyle(
  fontSize: 18,
  color: kTextColor,
  fontWeight: FontWeight.w600,
);

const kFormTextstyle = TextStyle(
  fontSize: 18,
  color: kBackgroundColor,
  fontWeight: FontWeight.w600,
);

const kAppBarstyle = TextStyle(
  fontSize: 20,
  color: kBackgroundColor,
  fontWeight: FontWeight.bold,
);

const double kDefaultPadding = 20.0;

const kGradient = const LinearGradient(
  begin: Alignment.topRight,
  end: Alignment.bottomLeft,
  colors: const [
    kPrimaryColor,
    kSecondaryColor,
  ],
);
extension CustomString on String {
  String capitalizeFirst() {
    return '${this[0].toUpperCase()}${this.substring(1)}';
  }
}
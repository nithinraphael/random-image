import 'package:flex_seed_scheme/flex_seed_scheme.dart';
import 'package:flutter/material.dart';

class ColorSets {
  static const Color primarySeedColor = Color(0xFFfe2453);
  static const Color secondarySeedColor = Colors.red; //  Red
  static const Color tertiarySeedColor = Color(0xFFFF6347); // Tomato

  static const Color errorColor = Color.fromARGB(255, 255, 49, 49);
  static const Color infoColor = Colors.cyan;
  static const Color criticalColor = Colors.red;
  static const Color successColor = Colors.greenAccent;
  static const Color warningColor = Colors.orange;
  static const Color neutralColor = Color.fromARGB(255, 0, 119, 255);

  static const Color dismissibleDelete = Color.fromARGB(255, 255, 0, 0);
  static const Color dismissibleSelect = Color.fromARGB(255, 0, 255, 38);

  // White muted shades
  static const Color whiteNormal = Color(0xFF4D4C4D);
  static const Color whiteLight = Color(0xFF7E7E7F);
  static const Color whiteExtraLight = Color(0xFFB2B3B3);
  static const Color whiteUltraLight = Color.fromARGB(255, 245, 245, 245);

  // Black muted shades
  static const Color blackNormal = Color(0xFFB3B3B3);
  static const Color blackLight = Color(0xFF818180);
  static const Color blackExtraLight = Color(0xFF4C4D4C);
  static const Color blackUltraLight = Color.fromARGB(255, 14, 14, 14);

  static Color dynamicMutedColor(
    BuildContext context, {
    double muteLevel = MutedLevel.normal,
  }) {
    switch (muteLevel) {
      case MutedLevel.normal:
        return context.isThemeDark ? blackNormal : whiteNormal;
      case MutedLevel.light:
        return context.isThemeDark ? blackLight : whiteLight;
      case MutedLevel.extraLight:
        return context.isThemeDark ? blackExtraLight : whiteExtraLight;
      case MutedLevel.ultraLight:
        return context.isThemeDark ? blackUltraLight : whiteUltraLight;
      default:
        return context.isThemeDark ? blackNormal : whiteNormal;
    }
  }

  static Color dynamicActiveColor(BuildContext context) {
    return context.isThemeDark ? Colors.white : Colors.black;
  }

  static const Color notificationDotColor = Color(0xFFFF0000);

  static const Color black = Colors.black;
  static const Color white = Colors.white;
  static const Color slightLightBlack = Color.fromARGB(255, 3, 3, 3);
  static const Color slightDarkWhite = Color.fromARGB(255, 252, 252, 252);

  // Output is black if theme is dark, else white
  static Color dynamicBWColor(
    BuildContext context, {
    bool useSlightlyOffShade = false,
  }) {
    if (useSlightlyOffShade) {
      return context.isThemeDark ? slightLightBlack : slightDarkWhite;
    }
    return context.isThemeDark ? ColorSets.black : ColorSets.white;
  }

  // Output is white if theme is dark, else black
  static Color dynamicWBColor(
    BuildContext context, {
    bool useSlightlyOffShade = false,
  }) {
    if (useSlightlyOffShade) {
      return context.isThemeDark ? slightDarkWhite : slightLightBlack;
    }
    return context.isThemeDark ? ColorSets.white : ColorSets.black;
  }
}

extension DarkModeExt on BuildContext {
  bool get isDarkMode {
    final brightness = MediaQuery.of(this).platformBrightness;
    return brightness == Brightness.dark;
  }

  bool get isThemeDark {
    return Theme.of(this).brightness == Brightness.dark;
  }

  // IMPORTANT This is  different it checks the platform brightness of the whole system not the app
  bool get isSystemDarkMode {
    final darkMode =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    return darkMode == Brightness.dark;
  }
}

extension ColorX on Color {
  /// Ultra-performant color opacity modifier.
  /// Uses bitwise operations for maximum performance.
  /// @param opacity Value between 0.0 and 1.0
  Color wAlpha(double opacity) {
    // Bitwise optimization - directly manipulate the 32-bit color value
    // This avoids multiple getter calls and conversions

    // Calculate alpha byte with fast paths for common values
    // Using bit shift instead of multiplication where possible
    final int alphaByte = opacity <= 0.0
        ? 0
        : opacity >= 1.0
        ? 0xFF
        : (opacity * 255.0 + 0.5).toInt(); // Adding 0.5 for fast rounding

    // Get the current color as an ARGB integer - using non-deprecated method
    final int argb = toARGB32();

    // Clear the alpha channel (first 8 bits) and set the new alpha value
    // This is ~20% faster than using fromARGB with component getters
    return Color((argb & 0x00FFFFFF) | (alphaByte << 24));
  }
}

class MutedLevel {
  static const normal = 0.7;
  static const light = 0.5;
  static const extraLight = 0.3;
  static const ultraLight = 0.05;
}

class Spacing {
  static const EdgeInsets screenPaddingX = EdgeInsets.only(left: 20, right: 20);
  static const EdgeInsets paddingY = EdgeInsets.only(top: 20, bottom: 20);
  static const EdgeInsets paddingYSm = EdgeInsets.only(top: 10, bottom: 10);
  static const EdgeInsets paddingYxSm = EdgeInsets.only(top: 5, bottom: 5);
  static const double paddingOneSide = 20;

  static const EdgeInsets paddingX = EdgeInsets.only(left: 20, right: 20);
  static const EdgeInsets paddingXSm = EdgeInsets.only(left: 10, right: 10);

  static const EdgeInsets paddingXY = EdgeInsets.all(20);

  static const EdgeInsets paddingXYSm = EdgeInsets.all(10);

  static const double borderRadiusSm = 5;
  static const double borderRadius = 10;
  static const double borderRadiusLg = 20;
  static const double borderRadiusXl = 30;
  static const double borderRadiusXxl = 40;
  static const double borderRadiusXxxl = 50;

  static const EdgeInsets paddingTop = EdgeInsets.only(top: 20);
  static const EdgeInsets paddingBottom = EdgeInsets.only(bottom: 20);
  static const EdgeInsets paddingTB = EdgeInsets.only(top: 20, bottom: 20);

  static const EdgeInsets paddingLeft = EdgeInsets.only(left: 20);
  static const EdgeInsets paddingRight = EdgeInsets.only(right: 20);
  static const EdgeInsets paddingLRT = EdgeInsets.only(
    right: 20,
    left: 20,
    top: 20,
  );

  static BorderRadius squareCircle = BorderRadius.circular(70);

  static const double notificationDotSize = 5;

  static const SizedBox gapXSm = SizedBox(width: 10);
  static const SizedBox gapX = SizedBox(width: 20);
  static const SizedBox gapXLg = SizedBox(width: 30);
  static const SizedBox gapXXl = SizedBox(width: 40);

  static const SizedBox gapYxSm = SizedBox(height: 5);
  static const SizedBox gapYSm = SizedBox(height: 10);
  static const SizedBox gapY = SizedBox(height: 20);
  static const SizedBox gapYLg = SizedBox(height: 30);
  static const SizedBox gapYXl = SizedBox(height: 40);
  static const SizedBox gapYXXXL = SizedBox(height: 150);

  // spacing values for direct use in Row/Column
  static const double xs = 5;
  static const double sm = 10;
  static const double md = 20;
  static const double lg = 30;
  static const double xl = 40;

  static const EdgeInsets textFieldLeftContentPadding = EdgeInsets.only(
    left: 10,
  );
}

class AppTheme {
  static const Color primarySeedColor = ColorSets.primarySeedColor;
  static const Color secondarySeedColor = ColorSets.secondarySeedColor;
  static const Color tertiarySeedColor = ColorSets.tertiarySeedColor;

  static const bool useMaterial3 = true;

  static ThemeData _createThemeData({
    Brightness brightness = Brightness.light,
  }) {
    return ThemeData(
      colorScheme: SeedColorScheme.fromSeeds(
        brightness: brightness,
        primaryKey: primarySeedColor,
        secondaryKey: secondarySeedColor,
        tertiaryKey: tertiarySeedColor,
        tones: FlexTones.vivid(brightness),
        surface: brightness == Brightness.dark ? Colors.black : Colors.white,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        elevation: 0,
        modalBarrierColor: brightness == Brightness.light
            ? ColorSets.black.wAlpha(0.5)
            : ColorSets.white.wAlpha(0.1),
      ),
      useMaterial3: useMaterial3,

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: brightness == Brightness.light
            ? Colors.white
            : Colors.black,
      ),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
    );
  }

  static ThemeData get light => _createThemeData();

  static ThemeData get dark => _createThemeData(brightness: Brightness.dark);
}

// TODO convert Asset images from string to AssetImage
class Images {
  static const AssetImage initialScreen = AssetImage(
    'assets/images/initial.png',
  );

  static const List<AssetImage> profilePicAssetImages =
      _ProfilePics.profilePicAssets;

  static _ProfileAssetPics profilePics = const _ProfileAssetPics(
    p1: _ProfilePics.profilePicAsset1,
    p2: _ProfilePics.profilePicAsset2,
    p3: _ProfilePics.profilePicAsset3,
    p4: _ProfilePics.profilePicAsset4,
    p5: _ProfilePics.profilePicAsset5,
    p6: _ProfilePics.profilePicAsset6,
    p7: _ProfilePics.profilePicAsset7,
    p8: _ProfilePics.profilePicAsset8,
    p9: _ProfilePics.profilePicAsset9,
    p10: _ProfilePics.profilePicAsset10,
    p11: _ProfilePics.profilePicAsset11,
    p12: _ProfilePics.profilePicAsset12,
    p13: _ProfilePics.profilePicAsset13,
    p14: _ProfilePics.profilePicAsset14,
    p15: _ProfilePics.profilePicAsset15,
    p16: _ProfilePics.profilePicAsset16,
    p17: _ProfilePics.profilePicAsset17,
    p18: _ProfilePics.profilePicAsset18,
    p19: _ProfilePics.profilePicAsset19,
    p20: _ProfilePics.profilePicAsset20,
    p21: _ProfilePics.profilePicAsset21,
    p22: _ProfilePics.profilePicAsset22,
    p23: _ProfilePics.profilePicAsset23,
    p24: _ProfilePics.profilePicAsset24,
    p25: _ProfilePics.profilePicAsset25,
    p26: _ProfilePics.profilePicAsset26,
    p27: _ProfilePics.profilePicAsset27,
    p28: _ProfilePics.profilePicAsset28,
    p29: _ProfilePics.profilePicAsset29,
    p30: _ProfilePics.profilePicAsset30,
    p31: _ProfilePics.profilePicAsset31,
    p32: _ProfilePics.profilePicAsset32,
  );
}

class _ProfileAssetPics {
  final AssetImage p1;
  final AssetImage p2;
  final AssetImage p3;
  final AssetImage p4;
  final AssetImage p5;
  final AssetImage p6;
  final AssetImage p7;
  final AssetImage p8;
  final AssetImage p9;
  final AssetImage p10;
  final AssetImage p11;
  final AssetImage p12;
  final AssetImage p13;
  final AssetImage p14;
  final AssetImage p15;
  final AssetImage p16;
  final AssetImage p17;
  final AssetImage p18;
  final AssetImage p19;
  final AssetImage p20;
  final AssetImage p21;
  final AssetImage p22;
  final AssetImage p23;
  final AssetImage p24;
  final AssetImage p25;
  final AssetImage p26;
  final AssetImage p27;
  final AssetImage p28;
  final AssetImage p29;
  final AssetImage p30;
  final AssetImage p31;
  final AssetImage p32;

  const _ProfileAssetPics({
    required this.p1,
    required this.p2,
    required this.p3,
    required this.p4,
    required this.p5,
    required this.p6,
    required this.p7,
    required this.p8,
    required this.p9,
    required this.p10,
    required this.p11,
    required this.p12,
    required this.p13,
    required this.p14,
    required this.p15,
    required this.p16,
    required this.p17,
    required this.p18,
    required this.p19,
    required this.p20,
    required this.p21,
    required this.p22,
    required this.p23,
    required this.p24,
    required this.p25,
    required this.p26,
    required this.p27,
    required this.p28,
    required this.p29,
    required this.p30,
    required this.p31,
    required this.p32,
  });
}

class _ProfilePics {
  static const profilePicAsset1 = AssetImage('assets/images/profiles/1.jpg');
  static const profilePicAsset2 = AssetImage('assets/images/profiles/2.jpg');
  static const profilePicAsset3 = AssetImage('assets/images/profiles/3.jpg');
  static const profilePicAsset4 = AssetImage('assets/images/profiles/4.jpg');
  static const profilePicAsset5 = AssetImage('assets/images/profiles/5.jpg');
  static const profilePicAsset6 = AssetImage('assets/images/profiles/6.jpg');
  static const profilePicAsset7 = AssetImage('assets/images/profiles/7.jpg');
  static const profilePicAsset8 = AssetImage('assets/images/profiles/8.jpg');
  static const profilePicAsset9 = AssetImage('assets/images/profiles/9.jpg');
  static const profilePicAsset10 = AssetImage('assets/images/profiles/10.jpg');
  static const profilePicAsset11 = AssetImage('assets/images/profiles/11.jpg');
  static const profilePicAsset12 = AssetImage('assets/images/profiles/12.jpg');
  static const profilePicAsset13 = AssetImage('assets/images/profiles/13.jpg');
  static const profilePicAsset14 = AssetImage('assets/images/profiles/14.jpg');
  static const profilePicAsset15 = AssetImage('assets/images/profiles/15.jpg');
  static const profilePicAsset16 = AssetImage('assets/images/profiles/16.jpg');
  static const profilePicAsset17 = AssetImage('assets/images/profiles/17.jpg');
  static const profilePicAsset18 = AssetImage('assets/images/profiles/18.jpg');
  static const profilePicAsset19 = AssetImage('assets/images/profiles/19.jpg');
  static const profilePicAsset20 = AssetImage('assets/images/profiles/20.jpg');
  static const profilePicAsset21 = AssetImage('assets/images/profiles/21.jpg');
  static const profilePicAsset22 = AssetImage('assets/images/profiles/22.jpg');
  static const profilePicAsset23 = AssetImage('assets/images/profiles/23.jpg');
  static const profilePicAsset24 = AssetImage('assets/images/profiles/24.jpg');
  static const profilePicAsset25 = AssetImage('assets/images/profiles/25.jpg');
  static const profilePicAsset26 = AssetImage('assets/images/profiles/26.jpg');
  static const profilePicAsset27 = AssetImage('assets/images/profiles/27.jpg');
  static const profilePicAsset28 = AssetImage('assets/images/profiles/28.jpg');
  static const profilePicAsset29 = AssetImage('assets/images/profiles/29.jpg');
  static const profilePicAsset30 = AssetImage('assets/images/profiles/30.jpg');
  static const profilePicAsset31 = AssetImage('assets/images/profiles/31.jpg');
  static const profilePicAsset32 = AssetImage('assets/images/profiles/32.jpg');

  static const profilePicAssets = [
    profilePicAsset1,
    profilePicAsset2,
    profilePicAsset3,
    profilePicAsset4,
    profilePicAsset5,
    profilePicAsset6,
    profilePicAsset7,
    profilePicAsset8,
    profilePicAsset9,
    profilePicAsset10,
    profilePicAsset11,
    profilePicAsset12,
    profilePicAsset13,
    profilePicAsset14,
    profilePicAsset15,
    profilePicAsset16,
    profilePicAsset17,
    profilePicAsset18,
    profilePicAsset19,
    profilePicAsset20,
    profilePicAsset21,
    profilePicAsset22,
    profilePicAsset23,
    profilePicAsset24,
    profilePicAsset25,
    profilePicAsset26,
    profilePicAsset27,
    profilePicAsset28,
    profilePicAsset29,
    profilePicAsset30,
    profilePicAsset31,
    profilePicAsset32,
  ];
}

import 'dart:math';

import 'package:aurora/config/config.dart' as config;
import 'package:aurora/widgets/basic/all.dart';
import 'package:aurora/widgets/forks/autoscroll.dart';
import 'package:aurora/widgets/forks/flutter_forks/show_cupertino_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SafeAreaConfig {
  const SafeAreaConfig({
    this.top = true,
    this.bottom = true,
    this.left = true,
    this.right = true,
  });
  final bool top, bottom, left, right;
}

class BBottomSheetWrapper extends StatelessWidget {
  const BBottomSheetWrapper({
    super.key,
    required this.child,
    this.height,
    this.beforeClose,
    this.padding = const EdgeInsets.all(20),
    this.safeAreaConfig = const SafeAreaConfig(
      top: false,
      left: false,
      right: false,
    ),
    this.backgroundColor,
    this.showCloseButton = true,
    this.closeButtonColor,
  });

  final Widget child;
  final Function? beforeClose;
  final double? height;
  final EdgeInsets padding;
  final SafeAreaConfig safeAreaConfig;
  final Color? backgroundColor;
  final bool showCloseButton;
  final Color? closeButtonColor;

  @override
  Widget build(BuildContext context) {
    final closeButtonColor = this.closeButtonColor ?? Colors.black;

    final color = backgroundColor ?? Colors.white;
    const borderRadius = BorderRadius.only(
      topLeft: Radius.circular(config.Spacing.borderRadiusLg),
      topRight: Radius.circular(config.Spacing.borderRadiusLg),
    );

    return ClipRSuperellipse(
      borderRadius: borderRadius,
      child: Material(
        color: Colors.transparent,
        child: SizedBox(
          height: height,
          child: ClipRSuperellipse(
            borderRadius: borderRadius,

            child: Scaffold(
              backgroundColor: backgroundColor,
              body: Container(
                width: double.infinity,
                height: height,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: borderRadius,
                ),
                child: Stack(
                  children: [
                    SafeArea(
                      top: safeAreaConfig.top,
                      left: safeAreaConfig.left,
                      right: safeAreaConfig.right,
                      bottom: safeAreaConfig.bottom,
                      child: Padding(
                        padding: padding,
                        child: SizedBox(
                          width: double.infinity,
                          height: height != null
                              ? height! - padding.vertical
                              : null,
                          child: child,
                        ),
                      ),
                    ),
                    if (showCloseButton)
                      Positioned(
                        top: 20,
                        right: 20,
                        child: GestureDetector(
                          onTap: () {
                            beforeClose?.call();
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(0, 2),
                                ),
                              ],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              CupertinoIcons.xmark,
                              color: closeButtonColor,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BWelcomeSheet extends StatelessWidget {
  const BWelcomeSheet({super.key, this.showSocials = true});

  static Future<void> showSheet(
    BuildContext context, {
    bool showSocials = true,
  }) async {
    await showCupertinoSheetMOD<void>(
      context: context,
      pageBuilder: (_) => BWelcomeSheet(showSocials: showSocials),
    );
  }

  final bool showSocials;

  @override
  Widget build(BuildContext context) {
    return BBottomSheetWrapper(
      backgroundColor: config.ColorSets.dynamicBWColor(context),
      closeButtonColor: Colors.black,
      padding: config.Spacing.paddingLRT,
      child: Scaffold(
        backgroundColor: config.ColorSets.dynamicBWColor(context),
        body: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    config.Spacing.gapYLg,
                    const _NeonText(
                      text: 'README.md',
                      fontSize: 50,
                      color: config.ColorSets.primarySeedColor,
                    ),
                    const SizedBox(height: 20),
                    RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: config.ColorSets.dynamicMutedColor(context),
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          height: 1.5, // Better line spacing
                        ),
                        children: [
                          const TextSpan(text: 'This app uses '),
                          const TextSpan(
                            text: 'functional programming',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                          const TextSpan(text: 'by using '),
                          const TextSpan(
                            text: 'FpDart',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                          const TextSpan(text: '.\n\nErrors are treated as  '),
                          const TextSpan(
                            text: 'values',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                          const TextSpan(text: '.\n\n'), // Paragraph break
                          const TextSpan(text: 'The UI is built with '),
                          const TextSpan(
                            text: 'Flutter Hooks',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                          const TextSpan(text: ' for less boilerplate'),

                          const TextSpan(text: '.\n\n'), // Paragraph break
                          const TextSpan(
                            text: 'Signals',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                          const TextSpan(
                            text: ' are used for reactive global state',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                _SlidingStuff(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NeonText extends HookWidget {
  const _NeonText({
    required this.text,
    this.fontSize = 40,
    this.color = Colors.cyan,
  });

  final String text;
  final double fontSize;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 1000),
    );

    useEffect(() {
      controller.repeat(reverse: true);
      return null;
    }, []);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final curve = Curves.easeInOut.transform(controller.value);
        final intensity = 0.2 + (curve * 0.8);

        return Text(
          text,

          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: color,
            shadows: [
              Shadow(color: color.wAlpha(intensity), blurRadius: 5),
              Shadow(color: color.wAlpha(intensity * 0.9), blurRadius: 15),
              Shadow(color: color.wAlpha(intensity * 0.8), blurRadius: 30),
              Shadow(color: color.wAlpha(intensity * 0.6), blurRadius: 45),
            ],
          ),
        );
      },
    );
  }
}

class _CarouselSection extends StatelessWidget {
  const _CarouselSection({required this.height, required this.width});

  final double height;
  final double width;

  @override
  Widget build(BuildContext context) => BContinuousCarousel(
    height: height,
    speed: 10,
    children: List.generate(10, _buildItem),
  );

  Widget _buildItem(int i) => Container(
    decoration: const BoxDecoration(
      boxShadow: [
        BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 10)),
      ],
    ),
    child: ClipRSuperellipse(
      borderRadius: BorderRadius.circular(config.Spacing.borderRadiusLg),
      child: Container(
        color: Colors.primaries[i],
        width: width,
        child: BFadeInAssetImage(
          // gradientLoader: config.CoolGradients.getDynamicRandom(context),
          image: getRandomProfileImageURL(useAIGenerated: true),
          fit: BoxFit.cover,
        ),
      ),
    ),
  );
}

class _SlidingStuff extends StatelessWidget {
  const _SlidingStuff({this.angle = -0.4});

  final double angle;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Transform.rotate(
        angle: angle,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _CarouselSection(height: 100, width: 100),
            config.Spacing.gapY,
            _CarouselSection(height: 100, width: 100),
          ],
        ),
      ),
    );
  }
}

class BContinuousCarousel extends HookWidget {
  const BContinuousCarousel({
    super.key,
    required this.children,
    this.height = 250,
    this.speed = 1.0,
    this.margin = const EdgeInsets.symmetric(horizontal: 10),
    this.pauseOnTouch = true,
    this.enableRotation = false,
  });

  final List<Widget> children;
  final double height;
  final double speed;
  final EdgeInsets margin;
  final bool pauseOnTouch;
  final bool enableRotation;

  @override
  Widget build(BuildContext context) {
    final spacing = enableRotation ? margin * 2 : margin;

    return SizedBox(
      height: height,
      child: ScrollLoopAutoScroll(
        scrollDirection: Axis.horizontal,
        gap: spacing.horizontal,
        enableScrollInput: pauseOnTouch,
        duplicateChild: 10,
        speed: speed,
        child: Row(
          children: children
              .asMap()
              .entries
              .map(
                (e) => enableRotation
                    ? _RotatedItem(
                        index: e.key,
                        margin: spacing,
                        height: height,
                        child: e.value,
                      )
                    : Container(
                        height: height,
                        margin: spacing,
                        child: e.value,
                      ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _RotatedItem extends StatelessWidget {
  const _RotatedItem({
    required this.index,
    required this.margin,
    required this.height,
    required this.child,
  });

  final int index;
  final EdgeInsets margin;
  final double height;
  final Widget child;

  static const kAngle = 0.04;

  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: index.isEven ? kAngle : -kAngle,
    child: Container(
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(12), child: child),
    ),
  );
}

AssetImage getRandomProfileImageURL({required bool useAIGenerated}) {
  final rng = Random();
  return config.Images.profilePicAssetImages[rng.nextInt(
    config.Images.profilePicAssetImages.length,
  )];
}

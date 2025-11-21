import 'package:aurora/widgets/basic/rotating_text.dart';
import 'package:aurora/widgets/basic/zoomtap.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:aurora/config/config.dart' as config;

const _kButtonHeight = 50.0;
const _kDebounceMs = 300;

class BButton extends HookWidget {
  factory BButton({
    Key? key,
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
    bool disabled = false,
    bool hasBoldText = false,
    IconData? icon,
    Color? borderColor,
    bool enableDebounce = true,
  }) => BButton._(
    key: key,
    text: text,
    onPressed: onPressed,
    disabled: disabled,
    color: config.ColorSets.dynamicMutedColor(context).wAlpha(0.1),
    textColor: config.ColorSets.primarySeedColor,
    hasBoldText: hasBoldText,
    icon: icon,
    borderColor: borderColor,
    enableDebounce: enableDebounce,
  );

  const BButton._({
    Key? key,
    required this.text,
    required this.onPressed,
    this.disabled = false,
    this.color,
    required this.textColor,
    this.hasBoldText = false,
    this.icon,
    this.hasBorder = false,
    this.borderColor,
    this.enableDebounce = true,
  }) : super(key: key);

  factory BButton.cta({
    Key? key,
    required String text,
    required VoidCallback onPressed,
    bool disabled = false,
    bool hasBoldText = true,
    IconData? icon,
    Color? borderColor,
    bool enableDebounce = true,
  }) => BButton._(
    key: key,
    text: text,
    onPressed: onPressed,
    disabled: disabled,
    color: config.ColorSets.primarySeedColor,
    textColor: config.ColorSets.white,
    hasBoldText: hasBoldText,
    icon: icon,
    borderColor: borderColor,
    enableDebounce: enableDebounce,
  );

  factory BButton.dynamicWB({
    Key? key,
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
    bool disabled = false,
    bool hasBoldText = true,
    IconData? icon,
    bool enableDebounce = true,
  }) => BButton._(
    key: key,
    text: text,
    onPressed: onPressed,
    disabled: disabled,
    color: config.ColorSets.dynamicWBColor(context),
    textColor: config.ColorSets.dynamicBWColor(context),
    hasBoldText: hasBoldText,
    icon: icon,
    enableDebounce: enableDebounce,
  );

  factory BButton.dynamicBW({
    Key? key,
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
    bool disabled = false,
    bool hasBoldText = true,
    IconData? icon,
    bool enableDebounce = true,
  }) => BButton._(
    key: key,
    text: text,
    onPressed: onPressed,
    disabled: disabled,
    color: config.ColorSets.dynamicBWColor(context),
    textColor: config.ColorSets.dynamicWBColor(context),
    hasBoldText: hasBoldText,
    icon: icon,
    enableDebounce: enableDebounce,
  );

  factory BButton.btnTxtPrimary({
    Key? key,
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
    bool disabled = false,
    bool hasBoldText = true,
    IconData? icon,
    Color? borderColor,
    bool enableDebounce = true,
  }) => BButton._(
    key: key,
    text: text,
    onPressed: onPressed,
    disabled: disabled,
    color: config.ColorSets.dynamicMutedColor(context).wAlpha(0.1),
    textColor: config.ColorSets.primarySeedColor,
    hasBoldText: hasBoldText,
    icon: icon,
    borderColor: borderColor,
    enableDebounce: enableDebounce,
  );

  factory BButton.btnTxtBW({
    Key? key,
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
    bool disabled = false,
    bool hasBoldText = true,
    IconData? icon,
    Color? borderColor,
    Color? textColor,
    bool enableDebounce = true,
  }) => BButton._(
    key: key,
    text: text,
    onPressed: onPressed,
    disabled: disabled,
    color: config.ColorSets.dynamicMutedColor(context).wAlpha(0.1),
    textColor: textColor ?? config.ColorSets.dynamicWBColor(context),
    hasBoldText: hasBoldText,
    icon: icon,
    borderColor: borderColor,
    enableDebounce: enableDebounce,
  );

  factory BButton.outlined(
    BuildContext context, {
    Key? key,
    required String text,
    required VoidCallback onPressed,
    bool disabled = false,
    bool hasBoldText = true,
    IconData? icon,
    Color? borderColor,
    bool enableDebounce = true,
  }) => BButton._(
    key: key,
    text: text,
    onPressed: onPressed,
    disabled: disabled,
    textColor: config.ColorSets.dynamicWBColor(context),
    hasBoldText: hasBoldText,
    icon: icon,
    hasBorder: true,
    borderColor:
        borderColor ??
        config.ColorSets.dynamicMutedColor(
          context,
          muteLevel: config.MutedLevel.extraLight,
        ),
    enableDebounce: enableDebounce,
  );

  final String text;
  final VoidCallback onPressed;
  final bool disabled;
  final Color? color;
  final Color textColor;
  final bool hasBoldText;
  final IconData? icon;
  final bool? hasBorder;
  final Color? borderColor;
  final bool enableDebounce;

  @override
  Widget build(BuildContext context) {
    final lastPressed = useRef<DateTime?>(null);

    final finalOnPressed = useMemoized(() {
      if (disabled) return null;
      if (!enableDebounce) return onPressed;

      return () {
        final now = DateTime.now();
        if (lastPressed.value != null &&
            now.difference(lastPressed.value!).inMilliseconds < _kDebounceMs) {
          return;
        }

        lastPressed.value = now;
        onPressed();
      };
    }, [disabled, onPressed, enableDebounce]);

    return Opacity(
      opacity: disabled ? 0.8 : 1,
      child: Container(
        height: _kButtonHeight,
        decoration: hasBorder == true
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(
                  config.Spacing.borderRadius,
                ),

                border: Border.all(
                  color:
                      borderColor ??
                      config.ColorSets.dynamicMutedColor(
                        context,
                        muteLevel: config.MutedLevel.extraLight,
                      ),
                ),
              )
            : null,
        child: CupertinoButton(
          borderRadius: BorderRadius.circular(config.Spacing.borderRadius),
          color: color,
          onPressed: finalOnPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: hasBoldText ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BRotatingBorderButton extends HookWidget {
  const BRotatingBorderButton({
    super.key,
    required this.onTap,
    required this.child,
    this.size = 50,
    this.borderWidth = 2,
    this.borderColor = config.ColorSets.black,
    this.backgroundColor = Colors.transparent,
    this.innerCircleColor,
    this.rotationDuration = const Duration(seconds: 10),
    this.borderText = 'SIGN UP',
    this.textStyle,
  });

  final VoidCallback onTap;
  final Widget child;
  final double size;
  final double borderWidth;
  final Color borderColor;
  final Color backgroundColor;
  final Color? innerCircleColor;
  final Duration rotationDuration;
  final String borderText;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) => BZoomTap(
    onTap: onTap,
    child: SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          BRotatingText(
            text: borderText,
            radius: size / 2.2,
            textStyle:
                textStyle ??
                TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: borderColor,
                ),
            rotationDuration: rotationDuration,
          ),
          if (innerCircleColor != null)
            Container(
              width: size * 0.6,
              height: size * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: innerCircleColor,
              ),
            ),
          Container(
            width: size - (borderWidth * 4),
            height: size - (borderWidth * 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: backgroundColor,
            ),
            child: Center(child: child),
          ),
        ],
      ),
    ),
  );
}

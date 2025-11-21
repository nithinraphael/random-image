import 'package:flutter/material.dart';
import 'package:aurora/config/config.dart' as config;

class BBottomNavigatorWrapper extends StatelessWidget {
  const BBottomNavigatorWrapper({
    super.key,
    required this.child,
    this.backgroundColor,
  });

  final Widget child;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final color = backgroundColor ?? config.ColorSets.dynamicBWColor(context);

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.wAlpha(0.1),
            blurRadius: 100,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: ClipRSuperellipse(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: Container(
          color: color,
          child: Padding(
            padding: EdgeInsets.only(
              top: config.Spacing.paddingXY.top,
              bottom:
                  MediaQuery.of(context).padding.bottom +
                  config.Spacing.paddingXY.bottom,
              left: config.Spacing.paddingXY.top,
              right: config.Spacing.paddingXY.top,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

import 'package:aurora/config/config.dart' as config;
import 'package:flutter/material.dart';

import 'package:aurora/globals/globals.dart' as globals;

class SnackbarAction {
  SnackbarAction(this.label, this.onPressed);
  final String label;
  final VoidCallback onPressed;
}

const closeI18n = 'close';

class BSnackbar extends StatelessWidget {
  const BSnackbar(this.message, {super.key, this.snackbarAction});
  final String message;
  final SnackbarAction? snackbarAction;

  @override
  Widget build(BuildContext context) =>
      BSnackbar.create(message, snackbarAction: snackbarAction);

  static SnackBar create(String message, {SnackbarAction? snackbarAction}) {
    return SnackBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      behavior: SnackBarBehavior.floating,
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.only(bottom: 10, left: 20, right: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(config.Spacing.borderRadius),
      ),
      content: _SnackContent(msg: message, action: snackbarAction),
      action: null,
    );
  }
}

class _SnackContent extends StatelessWidget {
  const _SnackContent({required this.msg, this.action});
  final String msg;
  final SnackbarAction? action;

  static const double kPad = 10, kGap = 10;
  @override
  Widget build(BuildContext context) {
    final fg = config.ColorSets.dynamicBWColor(context);
    final wb = config.ColorSets.dynamicWBColor(context);
    final act =
        action ??
        SnackbarAction(
          closeI18n.toUpperCase(),
          () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        );

    return ClipRSuperellipse(
      borderRadius: BorderRadius.circular(config.Spacing.borderRadius),
      child: Container(
        decoration: BoxDecoration(
          color: wb,
          boxShadow: [
            BoxShadow(
              color: Colors.black.wAlpha(0.25),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: kPad, vertical: 0),
        child: Row(
          children: [
            Expanded(
              child: Text(msg, style: TextStyle(color: fg)),
            ),
            const SizedBox(width: kGap),
            TextButton(
              onPressed: act.onPressed,
              style: TextButton.styleFrom(foregroundColor: wb),
              child: Text(act.label.toUpperCase()),
            ),
          ],
        ),
      ),
    );
  }
}

void showBSnackbar(String message, {SnackbarAction? snackbarAction}) {
  globals.snackbarKey.currentState?.showSnackBar(
    BSnackbar.create(message, snackbarAction: snackbarAction),
  );
}

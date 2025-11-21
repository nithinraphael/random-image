/// Common exports and functions.
/// - [ComponentRestriction] `num.restricted`
/// - [alphaFromStrength]
library colors;

import 'package:flutter/material.dart' show Color;

export 'package:flutter/material.dart';

export 'material.dart';
export 'operators.dart';
export 'shading.dart';
export 'spectrum.dart';

///     int get restricted => clamp(0,255).truncate();
extension ComponentRestriction on num {
  ///     int get restricted => clamp(0,255).truncate();
  ///
  /// A quick getter for `num`s that returns an `int` that has been
  /// clamped between `0..255` by integer division with `1` or `0xFF`.
  ///
  /// This value is in the valid range for a component of a [Color].
  int get restricted => clamp(0, 255).truncate();
  // int get restricted => this ~/ 0xff;
}

/// Considers the provided number(?) [strength].
///
/// If this number is a [double] between `0..1`, the return is
/// `0xFF * strength`.
///
/// After that check, if `strength` is an [int] or [double], the return is
/// `strength`.
///
/// Else returns `null`.
///
/// Not to be confused with the available [Color.getAlphaFromOpacity] which is
/// used strictly to convert a `<= 0.0 .. 1.0 >=` `double` "opacity" to a
/// clamped `0 .. 255` `int` "alpha".
/// - Such that a value of `1.0` as well as `2` would both return `255`
/// - Whereas this function [alphaFromStrength] would take `1.0` and also return
///   `255` but take `2` and instead return `2`.
int? alphaFromStrength(num? strength) =>
    (strength is double) && (strength >= 0 && strength <= 1)
        ? (0xFF * strength).restricted
        : (strength is double || strength is int)
            ? strength!.restricted
            : null;

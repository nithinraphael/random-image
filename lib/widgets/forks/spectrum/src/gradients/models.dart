/// `enum`s
/// - [GradientProperty]
///
/// `typedef`s
//\ - [TweenSpec]
/// - [ColorArithmetic], [StopsArithmetic]
///
/// Static Method Wrappers
/// - [Shades], [Maths]
library gradients;

import 'common.dart';
import 'steps/steps.dart';

/// Potential gradient properties for tweenage, notably excluding
/// `colors`, `stops`, `transform`, & `tileMode`,
/// as well as `shadeFunction` for `FooShadedSteps`.
enum GradientProperty {
  /// Potential [LinearGradient] property.
  begin,

  /// Potential [LinearGradient] property.
  end,

  /// Potential [RadialGradient] or [SweepGradient] property.
  center,

  /// Potential [RadialGradient] property.
  radius,

  /// Potential [RadialGradient] property.
  focal,

  /// Potential [RadialGradient] property.
  focalRadius,

  /// Potential [SweepGradient] property.
  startAngle,

  /// Potential [SweepGradient] property.
  endAngle,

  /// Potential [Steps] or `FooShadedSteps` property.
  softness,

  /// Potential `FooShadedSteps` property.
  shadeFactor,

  /// Potential `FooShadedSteps` property.
  distance,
}

/// A `ColorArithmetic` is a function that returns a [Color] after accepting
/// and considering a `Color` and an `double` [factor].
///
/// The default `ColorArithmetic` function for `FooShadedSteps` is
/// [Shades.withWhite], where a positive value lightens the color and negative
/// values darken it.
typedef ColorArithmetic = Color Function(Color color, double factor);

/// A few options for functions that fulfill the [ColorArithmetic] definition.
abstract class Shades {
  /// Perform no shading and simply return the provided [color].
  static Color none(Color color, double factor) => color;

  /// Default [ColorArithmetic] function for `FooShadedSteps`.
  ///
  /// A positive factor lightens the color, a negative factor darkens it.
  /// Clamped to appropriate range. Factor is `round()`ed to an `int`.
  static Color withWhite(Color color, double factor) =>
      color.withWhite(factor.restricted);

  /// A positive factor darkens the color, while a negative factor lightens it.
  /// Clamped to appropriate range. Factor is `round()`ed to an `int`.
  static Color withBlack(Color color, double factor) =>
      color.withBlack(factor.restricted);

  /// A factor between `0..254` represents a transparent color, while a
  /// factor of `255` will return the color entirely opaque. Factor is
  /// rounded to an `int`.
  static Color withAlpha(Color color, double factor) =>
      color.withAlpha(factor.restricted);
}

/// A `StopsArithmetic` is a function that returns a [double] after accepting
/// and considering a `double` [stop] and an `double` [factor].
///
/// The default `StopsArithmetic` function for `FooShadedSteps` is
/// [Maths.subtraction].
typedef StopsArithmetic = double Function(double stop, double factor);

/// A few options for functions that fulfill the [StopsArithmetic] definition.
abstract class Maths {
  /// Perform no maths and simply return the provided stop [s].
  static double none(double s, double f) => s;

  /// Add the provided animation value [f] to the provided stop [s],
  /// claming between `0..1`.
  static double addition(double s, double f) => (s + f).clamp(0, 1);

  /// Subtract the provided animation value [f] from the provided stop [s],
  /// claming between `0..1`.
  static double subtraction(double s, double f) => (s - f).clamp(0, 1);

  /// Multiply the provided stop [s] by the provided animation factor [f],
  /// claming between `0..1`.
  static double multiplication(double s, double f) => (s * f).clamp(0, 1);

  /// Divide the provided stop [s] by the provided animation factor [f],
  /// claming between `0..1`.
  static double division(double s, double f) => (s / f).clamp(0, 1);
}

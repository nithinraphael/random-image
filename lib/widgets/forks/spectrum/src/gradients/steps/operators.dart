/// Operator overrides on `List`s of [Color]s & [double]s for `Steps`
/// duplication.
///
/// [Shade] & [ShadeStep] models for `FooShadedSteps`-style `Steps`
/// quadruplication.
library gradients;

import '../common.dart';
import '../models.dart';

/// Defines the [function] and [factor] for step shading.
class Shade {
  /// Defines the [function] and [factor] for step shading.
  const Shade({required this.function, required this.factor});

  /// A `ColorArithmetic` is a function that returns a [Color] after accepting
  /// and considering a `Color` and an `int` [factor].
  ///
  /// Consider `ColorArithmetic` function [Shades.withWhite], a positive value
  /// lightens the color and negative values darken it.
  final ColorArithmetic function;

  /// The `factor` to provide to [function].
  final double factor;
}

/// Defines the [distance] and [softness] for step shading.
class ShadeStep {
  /// Defines the [distance] and [softness] for step shading.
  const ShadeStep(double distance, double softness)
      : _distance = distance,
        _softness = softness;

  final double _distance;

  /// The percentage between the current stop and the next stop
  /// (ranging `0.0 .. 1.0`) to begin shading.
  double get distance => _distance.clamp(0.0, 1.0);

  final double _softness;

  /// Softens/blurs the hard edges between steps, making it appear more like
  /// its original `Gradient` counterpart.
  double get softness => _softness.clamp(0.0, 1.0);
}

/// Provides Duplication & Shaded Quadruplication Operators
extension CopyColors on List<Color> {
  /// ### Duplication Operator
  /// Takes a `List<Color>` and returns a list with duplicated entries.
  List<Color> operator ~() =>
      fold([], (List<Color> list, Color entry) => list..addAll([entry, entry]));

  /// ### Shaded Quadruplication Operator
  /// Takes a `List<double>` and returns a list with duplicated entries where
  /// every duplicated entry may optionally have an [shade] added to it.
  // List<Color> operator ^(int shade) => fold(
  List<Color> operator ^(Shade shade) => fold(
        [],
        (List<Color> list, Color entry) => list
          ..addAll(
            [
              entry,
              // entry.withWhite(shade ~/ 2),
              shade.function(entry, shade.factor / 3),
              // entry.withWhite(shade ~/ 3),
              shade.function(entry, shade.factor.toDouble()),
              // entry.withWhite(shade),
              shade.function(entry, (shade.factor * 1.4)),
              // entry.withWhite((shade * 1.4).truncate()),
            ],
          ),
      );
}

/// Provides Softening & Quadruplication Operators
extension CopyStops on List<double> {
  /// ### "Softening" Duplication Operator
  /// Takes a `List<double>` and returns a list with duplicated entries where
  /// every duplicated entry may optionally have an [softness] added to it.
  ///
  /// If `additive` is `0.0`, then this operator functions like
  /// [CopyColors].
  List<double> operator ^(double softness) => fold(
        [],
        (List<double> list, double entry) => list
          ..addAll(
            [entry, entry + softness],
          ),
      );

  /// ### "Softening" Quadruplication Operator
  /// Takes a `List<double>` and returns a list with quadrupled entries
  /// with special calculations made.
  List<double> operator %(ShadeStep step) {
    final sets = <List<double>>[];
    for (var i = 0; i < length; i++) {
      final current = this[i] == 1.0 ? this[i] - step.softness * 3 : this[i];
      final next = (i == length - 1) ? 1.0 : this[i + 1];
      sets.add([
        current,
        current + (next - current) * step.distance,
        // next - 0.002,
        // next - 0.001,
        next - step.softness,
        next - step.softness,
        // next,
      ]);
    }
    return sets.reduce((value, element) => value + element);
  }
}

/// Provides `FooShadedSteps`:
/// - [LinearShadedSteps]
/// - [RadialShadedSteps]
/// - [SweepShadedSteps]
library gradients;

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show listEquals, objectRuntimeType;

import '../common.dart';
import '../models.dart';
import 'operators.dart';
import 'steps.dart';

/// Return a list of stops that is four times the size of the original,
/// including potential maths performed on intermediate colors considering
/// [softness] and [distance].
List<double> _quadruple(
  List<double>? stops,
  List<Color> colors,
  double softness,
  double distance,
) {
  stops ??= List<double>.from(stopsOrImplied(stops, colors.length + 1))
    ..removeLast();
  return stops % ShadeStep(distance, softness);
}

/// Construct a [new LinearShadedSteps] that progresses from one color to the
/// next in hard steps, each with its own intrinsic "shading," as opposed to
/// smooth transitions by way of "quadruplicating" colors and stops.
///
/// Consider [LinearSteps] for more information. \
/// The difference for `FooShadedSteps` is that instead of duplicating a color
/// to make it hard step at each transition, each color and stop is laid out
/// according to a `softness`, `shadeFunction` and `shadeFactor` to provide the
/// same effect across *four* entries instead of only two and allow greater
/// control over the inner appearance of *each* given step.
class LinearShadedSteps extends LinearSteps {
  /// A standard [Steps] gradient differs from the average [Gradient] in its
  /// progression from one color to the next. Instead of smoothly transitioning
  /// between colors, `Steps` have hard edges created by duplicating colors and
  /// stops.
  ///
  /// This `LinerShadedSteps` evolves [LinearSteps] one step further by creating
  /// the "stepping" effect across four colors/stops entries instead of only
  /// two. This allows greater control over the inner appearance of *each*
  /// given step; "shading" it darker or "shading" it more transparent, for
  /// example, in accordance with [shadeFunction].
  ///
  /// The default `shadeFunction` is [Shades.withWhite] and the default
  /// [shadeFactor] is `-90`. In this default scenario, each step will
  /// transition from `color` to `color.withwhite(-90)`.
  ///
  /// The [distance], defaulting at `0.6` is a percentage between the start and
  /// end of *each* step color to begin transitioning toward the color value
  /// with [shadeFunction] applied to it.
  ///
  /// See [LinearSteps] for more information.
  const LinearShadedSteps({
    this.shadeFunction = Shades.withWhite,
    this.shadeFactor = -90,
    this.distance = 0.6,
    double softness = 0.0,
    required List<Color> colors,
    List<double>? stops,
    AlignmentGeometry begin = Alignment.centerLeft,
    AlignmentGeometry end = Alignment.centerRight,
    TileMode tileMode = TileMode.clamp,
    GradientTransform? transform,
  }) : super(
         softness: softness,
         colors: colors,
         stops: stops,
         begin: begin,
         end: end,
         tileMode: tileMode,
         transform: transform,
       );

  /// For any given "step", comprised of a single color "quadruplicated" across
  /// four stops, the `shadeFunction` will be called on the color and this
  /// result is placed as the fourth, final stop for this color step.
  ///
  /// There is a standard gradient transition between `color` and the "shaded"
  /// final entry `shadeFunction(color, shadeFactor)` begining at a percentage
  /// from start->end of this step denoted by [distance]. Default `distance`
  /// is `0.6`.
  ///
  /// A [ColorArithmetic] function, as required, must confrom to
  ///
  ///     Color Function(Color color, double factor)
  ///
  /// Default `shadeFunction` is [Shades.withWhite] which provides [shadeFactor]
  /// as `color.withWhite(shadeFactor)`. Method `withWhite()` is like
  /// `withRed()` or `withBlue()` but it adds the given value to all three
  /// [Color] components, lightening the color. See [Shading].
  ///
  /// See [Shades] for a few pre-defined [ColorArithmetic] functions.
  final ColorArithmetic shadeFunction;

  /// A `double` to provide to [shadeFunction] when "shading" each colored step.
  ///
  /// The default value is `-90` as this corresponds to the default
  /// [shadeFunction] of [Shades.withWhite]. In this scenario, the color of each
  /// step transitions from `thatColor` to `thatColor.withWhite(-90)`.
  final double shadeFactor;

  /// A value between `0.0 .. 1.0`, defaulting at `0.6`, that places the
  /// "midpoint" for each color shading function in the `Steps`.
  ///
  /// It is a percentage between the start and end of *each* step color to begin
  /// transitioning toward the color value with [shadeFunction] applied to it.
  ///
  /// Imagine this represents the color red as a dark "shaded step" with
  /// `distance ~= 0.5` (note: each color and stop in a `FooShadedSteps` is
  /// "quadruplicated", so this diagram accurately represents how each color
  /// will be divided):
  ///
  ///     |-----------------+++++++++++++++++++++++|
  ///     [RED]  . [RED]  . [MIDPOINT] . [DARK RED]
  ///
  /// Then imagine this represents the same scenario but `distance ~= 0.25`:
  ///
  ///     |--------++++++++++++++++++++++++++++++++++++++++++|
  ///     [RED]  . [MIDPOINT] . [STILL BLENDING] . [DARK RED]
  final double distance;

  /// Overrides `Steps` property to "quadruplicate" with shading instead of
  /// only duplicating.
  @override
  List<Color> get steppedColors =>
      colors ^ Shade(function: shadeFunction, factor: shadeFactor);

  /// Overrides `Steps` property to "quadruplicate" with shading instead of
  /// only duplicating.
  @override
  List<double> get steppedStops =>
      _quadruple(stops, colors, softness, distance);

  /// 📋 Returns a new copy of this `LinearShadedSteps` with any provided
  /// optional parameters overriding those of `this`.
  @override
  LinearShadedSteps copyWith({
    ColorArithmetic? shadeFunction,
    double? shadeFactor,
    double? distance,
    double? softness,
    List<Color>? colors,
    List<double>? stops,
    AlignmentGeometry? begin,
    AlignmentGeometry? end,
    TileMode? tileMode,
    GradientTransform? transform,
  }) => LinearShadedSteps(
    shadeFunction: shadeFunction ?? this.shadeFunction,
    shadeFactor: shadeFactor ?? this.shadeFactor,
    distance: distance ?? this.distance,
    softness: softness ?? this.softness,
    colors: colors ?? this.colors,
    stops: stops ?? this.stops,
    begin: begin ?? this.begin,
    end: end ?? this.end,
    tileMode: tileMode ?? this.tileMode,
    transform: transform ?? this.transform,
  );

  /// Returns a new [LinearSteps] with its colors scaled by the given factor.
  /// Since the alpha channel is what receives the scale factor,
  /// `0.0` or less results in a gradient that is fully transparent.
  @override
  LinearShadedSteps scale(double factor) => copyWith(
    colors: colors
        .map<Color>((Color color) => Color.lerp(null, color, factor)!)
        .toList(),
  );

  @override
  Gradient? lerpFrom(Gradient? a, double t) =>
      (a == null || (a is LinearShadedSteps))
      ? LinearShadedSteps.lerp(a as LinearShadedSteps?, this, t)
      : super.lerpFrom(a, t);

  @override
  Gradient? lerpTo(Gradient? b, double t) =>
      (b == null || (b is LinearShadedSteps))
      ? LinearShadedSteps.lerp(this, b as LinearShadedSteps?, t)
      : super.lerpTo(b, t);

  /// Linearly interpolate between two [LinearSteps].
  ///
  /// If either `LinearSteps` is `null`, this function linearly interpolates
  /// from a `LinearSteps` that matches the other in [begin], [end], [stops] and
  /// [tileMode] and with the same [colors] but transparent (using [scale]).
  ///
  /// The `t` argument represents a position on the timeline, with `0.0` meaning
  /// that the interpolation has not started, returning `a` (or something
  /// equivalent to `a`); `1.0` meaning that the interpolation has finished,
  /// returning `b` (or something equivalent to `b`); and values in between
  /// `0.0 < t < 1.0` meaning that the interpolation is at the relevant point as
  /// a percentage along the timeline between `a` and `b`.
  ///
  /// The interpolation can be extrapolated beyond `0.0` and `1.0`, so negative
  /// values and values greater than `1.0` are valid (and can easily be
  /// generated by curves such as [Curves.elasticInOut]).
  ///
  /// Values for `t` are usually obtained from an [Animation<double>], such as
  /// an `AnimationController`.
  static Gradient? lerp(LinearShadedSteps? a, LinearShadedSteps? b, double t) {
    if (a == null && b == null) return null;
    if (a == null) return b!.scale(t);
    if (b == null) return a.scale(1.0 - t);
    // return GradientTween(begin: a, end: b).lerp(t);
    final stretched = PrimitiveGradient.fromStretchLerp(a, b, t);
    final interpolated = PrimitiveGradient.byProgressiveMerge(
      t < 0.5 ? PrimitiveGradient.from(a) : stretched,
      t < 0.5 ? stretched : PrimitiveGradient.from(b),
      // t < 0.5 ? t * 2 : (t - 0.5) * 2);
      t,
    );

    // // final interpolated = PrimitiveGradient.byCombination(a, b, t);
    // // final interpolated = PrimitiveGradient.fromStretchLerp(a, b, t);
    // // final interpolated = PrimitiveGradient.byProgressiveMerge(
    // // PrimitiveGradient.from(a), PrimitiveGradient.from(b), t);
    return LinearShadedSteps(
      // shadeFactor:StepTween(begin: a.shadeFactor,end: b.shadeFactor).lerp(t),
      shadeFactor: math.max(
        0.0,
        ui.lerpDouble(a.shadeFactor, b.shadeFactor.toDouble(), t)!,
      ),
      distance: math.max(0.0, ui.lerpDouble(a.distance, b.distance, t)!),
      softness: math.max(0.0, ui.lerpDouble(a.softness, b.softness, t)!),
      colors: interpolated.colors,
      stops: interpolated.stops,
      // TODO: Interpolate Matrix4 / GradientTransform
      transform: t > 0.5 ? a.transform : b.transform,
      // TODO: interpolate tile mode
      tileMode: t < 0.5 ? a.tileMode : b.tileMode,
      begin: AlignmentGeometry.lerp(a.begin, b.begin, t)!,
      end: AlignmentGeometry.lerp(a.end, b.end, t)!,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is LinearShadedSteps &&
        other.shadeFunction == shadeFunction &&
        other.shadeFactor == shadeFactor &&
        other.distance == distance &&
        other.softness == softness &&
        listEquals<Color>(other.colors, colors) &&
        listEquals<double>(other.stops, stops) &&
        other.tileMode == tileMode &&
        other.begin == begin &&
        other.end == end;
  }

  @override
  int get hashCode => Object.hash(
    shadeFunction,
    shadeFactor,
    distance,
    softness,
    Object.hashAll(colors),
    Object.hashAll(stops ?? []),
    tileMode,
    begin,
    end,
  );

  @override
  String toString() =>
      '${objectRuntimeType(this, 'LinearShadedSteps')} '
      '(shade: $shadeFactor, distance: $distance, softness: $softness, '
      'colors: $colors, stops: $stops, $tileMode, '
      'begin: $begin, end: $end)';
  // ', \nresolved colors: $steppedColors, resolved stops: $steppedStops';
}

/// Construct a [new RadialShadedSteps] that progresses from one color to the
/// next in hard steps, each with its own intrinsic "shading," as opposed to
/// smooth transitions by way of "quadruplicating" colors and stops.
///
/// Consider [RadialSteps] for more information. \
/// The difference for `FooShadedSteps` is that instead of duplicating a color
/// to make it hard step at each transition, each color and stop is laid out
/// according to a `softness`, `shadeFunction` and `shadeFactor` to provide the
/// same effect across *four* entries instead of only two and allow greater
/// control over the inner appearance of *each* given step.
class RadialShadedSteps extends RadialSteps {
  /// A standard [Steps] gradient differs from the average [Gradient] in its
  /// progression from one color to the next. Instead of smoothly transitioning
  /// between colors, `Steps` have hard edges created by duplicating colors and
  /// stops.
  ///
  /// This `RadialShadedSteps` evolves [RadialSteps] one step further by
  /// creating the "stepping" effect across four colors/stops entries instead of
  /// only two. This allows greater control over the inner appearance of *each*
  /// given step; "shading" it darker or "shading" it more transparent, for
  /// example, in accordance with [shadeFunction].
  ///
  /// The default `shadeFunction` is [Shades.withWhite] and the default
  /// [shadeFactor] is `-90`. In this default scenario, each step will
  /// transition from `color` to `color.withwhite(-90)`.
  ///
  /// The [distance], defaulting at `0.6` is a percentage between the start and
  /// end of *each* step color to begin transitioning toward the color value
  /// with [shadeFunction] applied to it.
  ///
  /// See [RadialSteps] for more information.
  const RadialShadedSteps({
    this.shadeFunction = Shades.withWhite,
    this.shadeFactor = -90,
    this.distance = 0.6,
    double softness = 0.0,
    required List<Color> colors,
    List<double>? stops,
    AlignmentGeometry center = Alignment.center,
    double radius = 0.5,
    AlignmentGeometry? focal,
    double focalRadius = 0.0,
    TileMode tileMode = TileMode.clamp,
    GradientTransform? transform,
  }) : super(
         softness: softness,
         colors: colors,
         stops: stops,
         center: center,
         radius: radius,
         focal: focal,
         focalRadius: focalRadius,
         tileMode: tileMode,
         transform: transform,
       );

  /// For any given "step", comprised of a single color "quadruplicated" across
  /// four stops, the `shadeFunction` will be called on the color and this
  /// result is placed as the fourth, final stop for this color step.
  ///
  /// There is a standard gradient transition between `color` and the "shaded"
  /// final entry `shadeFunction(color, shadeFactor)` begining at a percentage
  /// from start->end of this step denoted by [distance]. Default `distance`
  /// is `0.6`.
  ///
  /// A [ColorArithmetic] function, as required, must confrom to
  ///
  ///     Color Function(Color color, double factor)
  ///
  /// Default `shadeFunction` is [Shades.withWhite] which provides [shadeFactor]
  /// as `color.withWhite(shadeFactor)`. Method `withWhite()` is like
  /// `withRed()` or `withBlue()` but it adds the given value to all three
  /// [Color] components, lightening the color. See [Shading].
  ///
  /// See [Shades] for a few pre-defined [ColorArithmetic] functions.
  final ColorArithmetic shadeFunction;

  /// A `double` to provide to [shadeFunction] when "shading" each colored step.
  ///
  /// The default value is `-90` as this corresponds to the default
  /// [shadeFunction] of [Shades.withWhite]. In this scenario, the color of each
  /// step transitions from `thatColor` to `thatColor.withWhite(-90)`.
  final double shadeFactor;

  /// A value between `0.0 .. 1.0`, defaulting at `0.6`, that places the
  /// "midpoint" for each color shading function in the `Steps`.
  ///
  /// It is a percentage between the start and end of *each* step color to begin
  /// transitioning toward the color value with [shadeFunction] applied to it.
  ///
  /// Imagine this represents the color red as a dark "shaded step" with
  /// `distance ~= 0.5` (note: each color and stop in a `FooShadedSteps` is
  /// "quadruplicated", so this diagram accurately represents how each color
  /// will be divided):
  ///
  ///     |-----------------+++++++++++++++++++++++|
  ///     [RED]  . [RED]  . [MIDPOINT] . [DARK RED]
  ///
  /// Then imagine this represents the same scenario but `distance ~= 0.25`:
  ///
  ///     |--------++++++++++++++++++++++++++++++++++++++++++|
  ///     [RED]  . [MIDPOINT] . [STILL BLENDING] . [DARK RED]
  final double distance;

  /// Overrides `Steps` property to "quadruplicate" with shading instead of
  /// only duplicating.
  @override
  List<Color> get steppedColors =>
      colors ^ Shade(function: shadeFunction, factor: shadeFactor);

  /// Overrides `Steps` property to "quadruplicate" with shading instead of
  /// only duplicating.
  @override
  List<double> get steppedStops =>
      _quadruple(stops, colors, softness, distance);

  /// 📋 Returns a new copy of this `RadialShadedSteps` with any provided
  /// optional parameters overriding those of `this`.
  @override
  RadialShadedSteps copyWith({
    ColorArithmetic? shadeFunction,
    double? shadeFactor,
    double? distance,
    double? softness,
    List<Color>? colors,
    List<double>? stops,
    TileMode? tileMode,
    AlignmentGeometry? center,
    double? radius,
    AlignmentGeometry? focal,
    double? focalRadius,
    GradientTransform? transform,
  }) => RadialShadedSteps(
    shadeFunction: shadeFunction ?? this.shadeFunction,
    shadeFactor: shadeFactor ?? this.shadeFactor,
    distance: distance ?? this.distance,
    softness: softness ?? this.softness,
    colors: colors ?? this.colors,
    stops: stops ?? this.stops,
    transform: transform ?? this.transform,
    tileMode: tileMode ?? this.tileMode,
    center: center ?? this.center,
    radius: radius ?? this.radius,
    focal: focal ?? this.focal,
    focalRadius: focalRadius ?? this.focalRadius,
  );

  /// Returns a new [RadialSteps] with its colors scaled by the given factor.
  /// Since the alpha channel is what receives the scale factor,
  /// `0.0` or less results in a gradient that is fully transparent.
  @override
  RadialShadedSteps scale(double factor) => copyWith(
    colors: colors
        .map<Color>((Color color) => Color.lerp(null, color, factor)!)
        .toList(),
  );

  @override
  Gradient? lerpFrom(Gradient? a, double t) =>
      (a == null || (a is RadialShadedSteps))
      ? RadialShadedSteps.lerp(a as RadialShadedSteps?, this, t)
      : super.lerpFrom(a, t);

  @override
  Gradient? lerpTo(Gradient? b, double t) =>
      (b == null || (b is RadialShadedSteps))
      ? RadialShadedSteps.lerp(this, b as RadialShadedSteps?, t)
      : super.lerpTo(b, t);

  /// Linearly interpolate between two [RadialShadedSteps]s.
  ///
  /// If either gradient is `null`, this function linearly interpolates from a
  /// a gradient that matches the other gradient in [center], [radius], [stops]
  /// and [tileMode] and with the same [colors] but transparent (using [scale]).
  ///
  /// The `t` argument represents a position on the timeline, with `0.0` meaning
  /// that the interpolation has not started, returning `a` (or something
  /// equivalent to `a`); `1.0` meaning that the interpolation has finished,
  /// returning `b` (or something equivalent to `b`); and values in between
  /// `0.0 < t < 1.0` meaning that the interpolation is at the relevant point as
  /// a percentage along the timeline between `a` and `b`.
  ///
  /// The interpolation can be extrapolated beyond `0.0` and `1.0`, so negative
  /// values and values greater than `1.0` are valid (and can easily be
  /// generated by curves such as [Curves.elasticInOut]).
  ///
  /// Values for `t` are usually obtained from an [Animation<double>], such as
  /// an `AnimationController`.
  static RadialShadedSteps? lerp(
    RadialShadedSteps? a,
    RadialShadedSteps? b,
    double t,
  ) {
    if (a == null && b == null) return null;
    if (a == null) return b!.scale(t);
    if (b == null) return a.scale(1.0 - t);
    final stretched = PrimitiveGradient.fromStretchLerp(a, b, t);
    final interpolated = PrimitiveGradient.byProgressiveMerge(
      t < 0.5 ? PrimitiveGradient.from(a) : stretched,
      t < 0.5 ? stretched : PrimitiveGradient.from(b),
      // t < 0.5 ? t * 2 : (t - 0.5) * 2);
      t,
    );

    // final interpolated = PrimitiveGradient.byCombination(a, b, t);
    // final interpolated = PrimitiveGradient.fromStretchLerp(a, b, t);
    // final interpolated = PrimitiveGradient.byProgressiveMerge(
    // PrimitiveGradient.from(a), PrimitiveGradient.from(b), t);
    return RadialShadedSteps(
      // shadeFactor:StepTween(begin: a.shadeFactor,end: b.shadeFactor).lerp(t),
      shadeFactor: math.max(
        0.0,
        ui.lerpDouble(a.shadeFactor, b.shadeFactor.toDouble(), t)!,
      ),
      distance: math.max(0.0, ui.lerpDouble(a.distance, b.distance, t)!),
      softness: math.max(0.0, ui.lerpDouble(a.softness, b.softness, t)!),
      colors: interpolated.colors,
      stops: interpolated.stops,
      // TODO: Interpolate Matrix4 / GradientTransform
      transform: t > 0.5 ? a.transform : b.transform,
      // TODO: interpolate tile mode
      tileMode: t < 0.5 ? a.tileMode : b.tileMode,
      center: AlignmentGeometry.lerp(a.center, b.center, t)!,
      radius: math.max(0.0, ui.lerpDouble(a.radius, b.radius, t)!),
      focal: AlignmentGeometry.lerp(a.focal, b.focal, t),
      focalRadius: math.max(
        0.0,
        ui.lerpDouble(a.focalRadius, b.focalRadius, t)!,
      ),
    );
  }

  @override
  bool operator ==(Object other) => (identical(this, other))
      ? true
      : (other.runtimeType != runtimeType)
      ? false
      : other is RadialShadedSteps &&
            other.shadeFunction == shadeFunction &&
            other.shadeFactor == shadeFactor &&
            other.distance == distance &&
            other.softness == softness &&
            listEquals<Color>(other.colors, colors) &&
            listEquals<double>(other.stops, stops) &&
            other.tileMode == tileMode &&
            other.center == center &&
            other.radius == radius &&
            other.focal == focal &&
            other.focalRadius == focalRadius;

  @override
  int get hashCode => Object.hash(
    shadeFunction,
    shadeFactor,
    distance,
    softness,
    Object.hashAll(colors),
    Object.hashAll(stops ?? []),
    tileMode,
    center,
    radius,
    focal,
    focalRadius,
  );

  @override
  String toString() =>
      '${objectRuntimeType(this, 'RadialShadedSteps')}'
      '(softness: $softness, shade: $shadeFactor, distance: $distance, '
      'colors: $colors, stops: $stops, $tileMode, '
      'center: $center, radius: $radius, '
      'focal: $focal, focalRadius: $focalRadius)';
  // ', \nresolved colors: $steppedColors, resolved stops: $steppedStops';
}

/// Construct a [new SweepShadedSteps] that progresses from one color to the
/// next in hard steps, each with its own intrinsic "shading," as opposed to
/// smooth transitions by way of "quadruplicating" colors and stops.
///
/// Consider [SweepSteps] for more information. \
/// The difference for `FooShadedSteps` is that instead of duplicating a color
/// to make it hard step at each transition, each color and stop is laid out
/// according to a `softness`, `shadeFunction` and `shadeFactor` to provide the
/// same effect across *four* entries instead of only two and allow greater
/// control over the inner appearance of *each* given step.
class SweepShadedSteps extends SweepSteps {
  /// A standard [Steps] gradient differs from the average [Gradient] in its
  /// progression from one color to the next. Instead of smoothly transitioning
  /// between colors, `Steps` have hard edges created by duplicating colors and
  /// stops.
  ///
  /// This `SweepShadedSteps` evolves [SweepSteps] one step further by creating
  /// the "stepping" effect across four colors/stops entries instead of only
  /// two. This allows greater control over the inner appearance of *each*
  /// given step; "shading" it darker or "shading" it more transparent, for
  /// example, in accordance with [shadeFunction].
  ///
  /// The default `shadeFunction` is [Shades.withWhite] and the default
  /// [shadeFactor] is `-90`. In this default scenario, each step will
  /// transition from `color` to `color.withwhite(-90)`.
  ///
  /// The [distance], defaulting at `0.6` is a percentage between the start and
  /// end of *each* step color to begin transitioning toward the color value
  /// with [shadeFunction] applied to it.
  ///
  /// See [SweepSteps] for more information.
  const SweepShadedSteps({
    this.shadeFunction = Shades.withWhite,
    this.shadeFactor = -90,
    this.distance = 0.6,
    double softness = 0.0,
    required List<Color> colors,
    List<double>? stops,
    TileMode tileMode = TileMode.clamp,
    AlignmentGeometry center = Alignment.center,
    double startAngle = 0.0,
    double endAngle = math.pi * 2,
    GradientTransform? transform,
  }) : super(
         softness: softness,
         colors: colors,
         stops: stops,
         center: center,
         startAngle: startAngle,
         endAngle: endAngle,
         tileMode: tileMode,
         transform: transform,
       );

  /// For any given "step", comprised of a single color "quadruplicated" across
  /// four stops, the `shadeFunction` will be called on the color and this
  /// result is placed as the fourth, final stop for this color step.
  ///
  /// There is a standard gradient transition between `color` and the "shaded"
  /// final entry `shadeFunction(color, shadeFactor)` begining at a percentage
  /// from start->end of this step denoted by [distance]. Default `distance`
  /// is `0.6`.
  ///
  /// A [ColorArithmetic] function, as required, must confrom to
  ///
  ///     Color Function(Color color, double factor)
  ///
  /// Default `shadeFunction` is [Shades.withWhite] which provides [shadeFactor]
  /// as `color.withWhite(shadeFactor)`. Method `withWhite()` is like
  /// `withRed()` or `withBlue()` but it adds the given value to all three
  /// [Color] components, lightening the color. See [Shading].
  ///
  /// See [Shades] for a few pre-defined [ColorArithmetic] functions.
  final ColorArithmetic shadeFunction;

  /// A `double` to provide to [shadeFunction] when "shading" each colored step.
  ///
  /// The default value is `-90` as this corresponds to the default
  /// [shadeFunction] of [Shades.withWhite]. In this scenario, the color of each
  /// step transitions from `thatColor` to `thatColor.withWhite(-90)`.
  final double shadeFactor;

  /// A value between `0.0 .. 1.0`, defaulting at `0.6`, that places the
  /// "midpoint" for each color shading function in the `Steps`.
  ///
  /// It is a percentage between the start and end of *each* step color to begin
  /// transitioning toward the color value with [shadeFunction] applied to it.
  ///
  /// Imagine this represents the color red as a dark "shaded step" with
  /// `distance ~= 0.5` (note: each color and stop in a `FooShadedSteps` is
  /// "quadruplicated", so this diagram accurately represents how each color
  /// will be divided):
  ///
  ///     |-----------------+++++++++++++++++++++++|
  ///     [RED]  . [RED]  . [MIDPOINT] . [DARK RED]
  ///
  /// Then imagine this represents the same scenario but `distance ~= 0.25`:
  ///
  ///     |--------++++++++++++++++++++++++++++++++++++++++++|
  ///     [RED]  . [MIDPOINT] . [STILL BLENDING] . [DARK RED]
  final double distance;

  /// Overrides `Steps` property to "quadruplicate" with shading instead of
  /// only duplicating.
  @override
  List<Color> get steppedColors =>
      colors ^ Shade(function: shadeFunction, factor: shadeFactor);

  /// Overrides `Steps` property to "quadruplicate" with shading instead of
  /// only duplicating.
  @override
  List<double> get steppedStops =>
      _quadruple(stops, colors, softness, distance);

  /// 📋 Returns a new copy of this `SweepShadedSteps` with any provided
  /// optional parameters overriding those of `this`.
  @override
  SweepShadedSteps copyWith({
    ColorArithmetic? shadeFunction,
    double? shadeFactor,
    double? distance,
    double? softness,
    List<Color>? colors,
    List<double>? stops,
    TileMode? tileMode,
    AlignmentGeometry? center,
    double? startAngle,
    double? endAngle,
    GradientTransform? transform,
  }) => SweepShadedSteps(
    shadeFunction: shadeFunction ?? this.shadeFunction,
    shadeFactor: shadeFactor ?? this.shadeFactor,
    distance: distance ?? this.distance,
    softness: softness ?? this.softness,
    colors: colors ?? this.colors,
    stops: stops ?? this.stops,
    center: center ?? this.center,
    startAngle: startAngle ?? this.startAngle,
    endAngle: endAngle ?? this.endAngle,
    tileMode: tileMode ?? this.tileMode,
    transform: transform ?? this.transform,
  );

  /// Returns a new [SweepSteps] with its colors scaled by the given factor.
  /// Since the alpha channel is what receives the scale factor,
  /// `0.0` or less results in a gradient that is fully transparent.
  @override
  SweepShadedSteps scale(double factor) => copyWith(
    colors: colors
        .map<Color>((Color color) => Color.lerp(null, color, factor)!)
        .toList(),
  );

  @override
  Gradient? lerpFrom(Gradient? a, double t) =>
      (a == null || (a is SweepShadedSteps))
      ? SweepShadedSteps.lerp(a as SweepShadedSteps?, this, t)
      : super.lerpFrom(a, t);

  @override
  Gradient? lerpTo(Gradient? b, double t) =>
      (b == null || (b is SweepShadedSteps))
      ? SweepShadedSteps.lerp(this, b as SweepShadedSteps?, t)
      : super.lerpTo(b, t);

  /// Linearly interpolate between two [SweepShadedSteps]s.
  ///
  /// If either gradient is `null`, this function linearly interpolates from a
  /// a gradient that matches the other gradient in [center], [startAngle],
  /// [endAngle], [stops] & [tileMode] and with the same [colors] but
  /// transparent (using [scale]).
  ///
  /// The `t` argument represents a position on the timeline, with `0.0` meaning
  /// that the interpolation has not started, returning `a` (or something
  /// equivalent to `a`); `1.0` meaning that the interpolation has finished,
  /// returning `b` (or something equivalent to `b`); and values in between
  /// `0.0 < t < 1.0` meaning that the interpolation is at the relevant point as
  /// a percentage along the timeline between `a` and `b`.
  ///
  /// The interpolation can be extrapolated beyond `0.0` and `1.0`, so negative
  /// values and values greater than `1.0` are valid (and can easily be
  /// generated by curves such as [Curves.elasticInOut]).
  ///
  /// Values for `t` are usually obtained from an [Animation<double>], such as
  /// an `AnimationController`.
  static SweepShadedSteps? lerp(
    SweepShadedSteps? a,
    SweepShadedSteps? b,
    double t,
  ) {
    if (a == null && b == null) return null;
    if (a == null) return b!.scale(t);
    if (b == null) return a.scale(1.0 - t);
    final stretched = PrimitiveGradient.fromStretchLerp(a, b, t);
    final interpolated = PrimitiveGradient.byProgressiveMerge(
      t < 0.5 ? PrimitiveGradient.from(a) : stretched,
      t < 0.5 ? stretched : PrimitiveGradient.from(b),
      // t < 0.5 ? t * 2 : (t - 0.5) * 2);
      t,
    );

    // final interpolated = PrimitiveGradient.byCombination(a, b, t);
    // final interpolated = PrimitiveGradient.fromStretchLerp(a, b, t);
    // final interpolated = PrimitiveGradient.byProgressiveMerge(
    // PrimitiveGradient.from(a), PrimitiveGradient.from(b), t);
    return SweepShadedSteps(
      // shadeFactor: StepTween(begin:a.shadeFactor, end:b.shadeFactor).lerp(t),
      // shadeFactor:
      shadeFactor: math.max(
        0.0,
        ui.lerpDouble(a.shadeFactor, b.shadeFactor.toDouble(), t)!,
      ),
      distance: math.max(0.0, ui.lerpDouble(a.distance, b.distance, t)!),
      softness: math.max(0.0, ui.lerpDouble(a.softness, b.softness, t)!),
      colors: interpolated.colors,
      stops: interpolated.stops,
      // TODO: Interpolate Matrix4 / GradientTransform
      transform: t > 0.5 ? a.transform : b.transform,
      // TODO: interpolate tile mode
      tileMode: t < 0.5 ? a.tileMode : b.tileMode,
      center: AlignmentGeometry.lerp(a.center, b.center, t)!,
      startAngle: math.max(0.0, ui.lerpDouble(a.startAngle, b.startAngle, t)!),
      endAngle: math.max(0.0, ui.lerpDouble(a.endAngle, b.endAngle, t)!),
    );
  }

  @override
  bool operator ==(Object other) => (identical(this, other))
      ? true
      : (other.runtimeType != runtimeType)
      ? false
      : other is SweepShadedSteps &&
            other.shadeFunction == shadeFunction &&
            other.shadeFactor == shadeFactor &&
            other.distance == distance &&
            other.softness == softness &&
            listEquals<Color>(other.colors, colors) &&
            listEquals<double>(other.stops, stops) &&
            other.center == center &&
            other.startAngle == startAngle &&
            other.endAngle == endAngle &&
            other.tileMode == tileMode;

  @override
  int get hashCode => Object.hash(
    shadeFunction,
    shadeFactor,
    distance,
    softness,
    Object.hashAll(colors),
    Object.hashAll(stops ?? []),
    tileMode,
    center,
    startAngle,
    endAngle,
  );

  @override
  String toString() =>
      '${objectRuntimeType(this, 'SweepShadedSteps')}'
      '(softness: $softness, shade: $shadeFactor, distance: $distance, '
      'colors: $colors, stops: $stops, $tileMode, center: $center, '
      'startAngle: $startAngle, endAngle: $endAngle)';
  // ', \nresolved colors: $steppedColors, resolved stops: $steppedStops';
}

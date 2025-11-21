library gradients;

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show listEquals, objectRuntimeType;

import '../common.dart';
import 'operators.dart';

abstract class Steps extends Gradient {
  const Steps({
    this.softness = 0.0,
    required List<Color> colors,
    List<double>? stops,
    this.tileMode = TileMode.clamp,
    GradientTransform? transform,
  }) : super(colors: colors, stops: stops, transform: transform);

  final double softness;
  final TileMode tileMode;

  List<Color> get steppedColors => ~colors;

  List<double> get steppedStops {
    final kStops = List<double>.from(stopsOrImplied(stops, colors.length + 1));
    if (stops == null) kStops.removeLast();
    return kStops ^ softness
      ..removeAt(0)
      ..add(1.0);
  }

  Gradient get asGradient;

  @override
  ui.Shader createShader(ui.Rect rect, {ui.TextDirection? textDirection}) =>
      asGradient.createShader(rect, textDirection: textDirection);
}

class LinearSteps extends Steps {
  const LinearSteps({
    super.softness = 0.001,
    required super.colors,
    super.stops,
    this.begin = Alignment.centerLeft,
    this.end = Alignment.centerRight,
    super.tileMode,
    super.transform,
  });

  final AlignmentGeometry begin, end;

  @override
  LinearGradient get asGradient => LinearGradient(
    colors: steppedColors,
    stops: steppedStops,
    begin: begin,
    end: end,
    tileMode: tileMode,
    transform: transform,
  );

  @override
  LinearSteps scale(double factor) => copyWith(
    colors: colors.map((c) => Color.lerp(null, c, factor)!).toList(),
  );

  @override
  Gradient? lerpFrom(Gradient? a, double t) => (a == null || a is LinearSteps)
      ? LinearSteps.lerp(a as LinearSteps?, this, t)
      : super.lerpFrom(a, t);

  @override
  Gradient? lerpTo(Gradient? b, double t) => (b == null || b is LinearSteps)
      ? LinearSteps.lerp(this, b as LinearSteps?, t)
      : super.lerpTo(b, t);

  static LinearSteps? lerp(LinearSteps? a, LinearSteps? b, double t) {
    if (a == null && b == null) return null;
    if (a == null) return b!.scale(t);
    if (b == null) return a.scale(1.0 - t);

    final kInterpolated = PrimitiveGradient.byCombination(a, b, t);
    return LinearSteps(
      softness: math.max(0.0, ui.lerpDouble(a.softness, b.softness, t)!),
      colors: kInterpolated.colors,
      stops: kInterpolated.stops,
      transform: t > 0.5 ? a.transform : b.transform,
      tileMode: t < 0.5 ? a.tileMode : b.tileMode,
      begin: AlignmentGeometry.lerp(a.begin, b.begin, t)!,
      end: AlignmentGeometry.lerp(a.end, b.end, t)!,
    );
  }

  LinearSteps copyWith({
    double? softness,
    List<Color>? colors,
    List<double>? stops,
    AlignmentGeometry? begin,
    AlignmentGeometry? end,
    TileMode? tileMode,
    GradientTransform? transform,
  }) => LinearSteps(
    softness: softness ?? this.softness,
    colors: colors ?? this.colors,
    stops: stops ?? this.stops,
    begin: begin ?? this.begin,
    end: end ?? this.end,
    tileMode: tileMode ?? this.tileMode,
    transform: transform ?? this.transform,
  );

  @override
  LinearSteps withOpacity(double opacity) => copyWith(
    colors: colors.map((c) => c.withOpacity(c.opacity * opacity)).toList(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LinearSteps &&
          other.softness == softness &&
          listEquals(other.colors, colors) &&
          listEquals(other.stops, stops) &&
          other.tileMode == tileMode &&
          other.begin == begin &&
          other.end == end);

  @override
  int get hashCode => Object.hash(
    softness,
    Object.hashAll(colors),
    Object.hashAll(stops ?? []),
    tileMode,
    begin,
    end,
  );

  @override
  String toString() =>
      '${objectRuntimeType(this, 'LinearSteps')}(softness: $softness, '
      'colors: $colors, stops: $stops, $tileMode, begin: $begin, end: $end)';
}

class RadialSteps extends Steps {
  const RadialSteps({
    super.softness = 0.0025,
    required super.colors,
    super.stops,
    this.center = Alignment.center,
    this.radius = 0.5,
    this.focal,
    this.focalRadius = 0.0,
    super.tileMode,
    super.transform,
  });

  final AlignmentGeometry center;
  final double radius;
  final AlignmentGeometry? focal;
  final double focalRadius;

  @override
  RadialGradient get asGradient => RadialGradient(
    colors: steppedColors,
    stops: steppedStops,
    center: center,
    radius: radius,
    focal: focal,
    focalRadius: focalRadius,
    tileMode: tileMode,
    transform: transform,
  );

  @override
  RadialSteps scale(double factor) => copyWith(
    colors: colors.map((c) => Color.lerp(null, c, factor)!).toList(),
  );

  @override
  Gradient? lerpFrom(Gradient? a, double t) => (a == null || a is RadialSteps)
      ? RadialSteps.lerp(a as RadialSteps?, this, t)
      : super.lerpFrom(a, t);

  @override
  Gradient? lerpTo(Gradient? b, double t) => (b == null || b is RadialSteps)
      ? RadialSteps.lerp(this, b as RadialSteps?, t)
      : super.lerpTo(b, t);

  static RadialSteps? lerp(RadialSteps? a, RadialSteps? b, double t) {
    if (a == null && b == null) return null;
    if (a == null) return b!.scale(t);
    if (b == null) return a.scale(1.0 - t);

    final kInterpolated = PrimitiveGradient.byCombination(a, b, t);
    return RadialSteps(
      softness: math.max(0.0, ui.lerpDouble(a.softness, b.softness, t)!),
      colors: kInterpolated.colors,
      stops: kInterpolated.stops,
      transform: t > 0.5 ? a.transform : b.transform,
      tileMode: t < 0.5 ? a.tileMode : b.tileMode,
      center: AlignmentGeometry.lerp(a.center, b.center, t)!,
      radius: ui.lerpDouble(a.radius, b.radius, t)!,
      focal: AlignmentGeometry.lerp(a.focal, b.focal, t),
      focalRadius: ui.lerpDouble(a.focalRadius, b.focalRadius, t)!,
    );
  }

  RadialSteps copyWith({
    double? softness,
    List<Color>? colors,
    List<double>? stops,
    TileMode? tileMode,
    AlignmentGeometry? center,
    double? radius,
    AlignmentGeometry? focal,
    double? focalRadius,
    GradientTransform? transform,
  }) => RadialSteps(
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

  @override
  RadialSteps withOpacity(double opacity) => copyWith(
    colors: colors.map((c) => c.withOpacity(c.opacity * opacity)).toList(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RadialSteps &&
          other.softness == softness &&
          listEquals(other.colors, colors) &&
          listEquals(other.stops, stops) &&
          other.tileMode == tileMode &&
          other.center == center &&
          other.radius == radius &&
          other.focal == focal &&
          other.focalRadius == focalRadius);

  @override
  int get hashCode => Object.hash(
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
      '${objectRuntimeType(this, 'RadialSteps')}(softness: $softness, '
      'colors: $colors, stops: $stops, $tileMode, center: $center, '
      'radius: $radius, focal: $focal, focalRadius: $focalRadius)';
}

class SweepSteps extends Steps {
  const SweepSteps({
    super.softness = 0.0,
    required super.colors,
    super.stops,
    super.tileMode,
    this.center = Alignment.center,
    this.startAngle = 0.0,
    this.endAngle = math.pi * 2,
    super.transform,
  });

  final AlignmentGeometry center;
  final double startAngle, endAngle;

  @override
  SweepGradient get asGradient => SweepGradient(
    colors: steppedColors,
    stops: steppedStops,
    center: center,
    startAngle: startAngle,
    endAngle: endAngle,
    tileMode: tileMode,
    transform: transform,
  );

  @override
  SweepSteps scale(double factor) => copyWith(
    colors: colors.map((c) => Color.lerp(null, c, factor)!).toList(),
  );

  @override
  Gradient? lerpFrom(Gradient? a, double t) => (a == null || a is SweepSteps)
      ? SweepSteps.lerp(a as SweepSteps?, this, t)
      : super.lerpFrom(a, t);

  @override
  Gradient? lerpTo(Gradient? b, double t) => (b == null || b is SweepSteps)
      ? SweepSteps.lerp(this, b as SweepSteps?, t)
      : super.lerpTo(b, t);

  static SweepSteps? lerp(SweepSteps? a, SweepSteps? b, double t) {
    if (a == null && b == null) return null;
    if (a == null) return b!.scale(t);
    if (b == null) return a.scale(1.0 - t);

    final kInterpolated = PrimitiveGradient.byCombination(a, b, t);
    return SweepSteps(
      softness: math.max(0.0, ui.lerpDouble(a.softness, b.softness, t)!),
      colors: kInterpolated.colors,
      stops: kInterpolated.stops,
      transform: t > 0.5 ? a.transform : b.transform,
      tileMode: t < 0.5 ? a.tileMode : b.tileMode,
      center: AlignmentGeometry.lerp(a.center, b.center, t)!,
      startAngle: ui.lerpDouble(a.startAngle, b.startAngle, t)!,
      endAngle: ui.lerpDouble(a.endAngle, b.endAngle, t)!,
    );
  }

  SweepSteps copyWith({
    double? softness,
    List<Color>? colors,
    List<double>? stops,
    TileMode? tileMode,
    AlignmentGeometry? center,
    double? startAngle,
    double? endAngle,
    GradientTransform? transform,
  }) => SweepSteps(
    softness: softness ?? this.softness,
    colors: colors ?? this.colors,
    stops: stops ?? this.stops,
    center: center ?? this.center,
    startAngle: startAngle ?? this.startAngle,
    endAngle: endAngle ?? this.endAngle,
    tileMode: tileMode ?? this.tileMode,
    transform: transform ?? this.transform,
  );

  @override
  SweepSteps withOpacity(double opacity) => copyWith(
    colors: colors.map((c) => c.withOpacity(c.opacity * opacity)).toList(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SweepSteps &&
          other.softness == softness &&
          listEquals(other.colors, colors) &&
          listEquals(other.stops, stops) &&
          other.center == center &&
          other.startAngle == startAngle &&
          other.endAngle == endAngle &&
          other.tileMode == tileMode);

  @override
  int get hashCode => Object.hash(
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
      '${objectRuntimeType(this, 'SweepSteps')}(softness: $softness, '
      'colors: $colors, stops: $stops, $tileMode, center: $center, '
      'startAngle: $startAngle, endAngle: $endAngle)';
}

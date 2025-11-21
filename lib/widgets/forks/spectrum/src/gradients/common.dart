/// Common exports & methods
library gradients;

import 'package:flutter/material.dart';

import 'interpolation.dart';
import 'models.dart';
import 'steps/steps.dart';
import 'tween.dart';
import 'utils.dart';

export 'package:flutter/material.dart';

export '../colors/common.dart' show ComponentRestriction;
export '../colors/shading.dart';
export 'interpolation.dart';
export 'utils.dart';

/// Receiving a potentially `null` list of [stops] and a concrete [colorCount]:
/// - immediately return [stops] if non-`null`
/// - return an interpreted list of stops
List<double> stopsOrImplied(List<double>? stops, int colorCount) {
  if (stops != null) return stops;
  final separation = 1.0 / (colorCount - 1);
  return List<double>.generate(
    colorCount,
    (int index) => index * separation,
    growable: false,
  );
}

/// Present a [Gradient] and this method will return a `List<double>`
/// representing this gradient's `stops`.
///
/// If the gradient has an explicit `stops`, it is returned unmodified.
///
/// Method [stopsOrImplied] considers the presented `List<double>`,
/// potentionally `null`, and creates an implied list of stops if necessary.
///
/// If the gradient to consider is an [IntermediateGradient], the method will
/// utilize it's native [PrimitiveGradient].
///
/// If the gradient to consider is a set of [Steps] and it needs its stops
/// created by implication, that is done by increasing parameter `colorCount`
/// for that [stopsOrImplied] by 1 and then subtracting the final entry from
/// the resultant list.
List<double> interpretStops(Gradient gradient) {
  final stops = List<double>.from(stopsOrImplied(
    (gradient is IntermediateGradient)
        ? gradient.primitive.stops
        : gradient.stops,
    (gradient is IntermediateGradient)
        ? gradient.primitive.colors.length
        : (gradient is Steps)
            ? gradient.colors.length + 1
            : gradient.colors.length,
  ));
  if (gradient is Steps && gradient.stops == null) stops.removeLast();
  return stops;
}

/// Wrapper for this package's default [GradientCopyWith] method:
/// the `Gradient.copyWith()` extension from [GradientUtils].
Gradient spectrumCopyWith(
  Gradient original, {
  // Universal
  List<Color>? colors,
  List<double>? stops,
  GradientTransform? transform,
  TileMode? tileMode,
  // Linear
  AlignmentGeometry? begin,
  AlignmentGeometry? end,
  // Radial or Sweep
  AlignmentGeometry? center,
  // Radial
  double? radius,
  AlignmentGeometry? focal,
  double? focalRadius,
  // Sweep
  double? startAngle,
  double? endAngle,
  // Steps
  double? softness,
  // Shaded Steps
  ColorArithmetic? shadeFunction,
  double? shadeFactor,
  double? distance,
}) =>
    original.copyWith(
      colors: colors,
      stops: stops,
      transform: transform,
      tileMode: tileMode,
      begin: begin,
      end: end,
      center: center,
      radius: radius,
      focal: focal,
      focalRadius: focalRadius,
      startAngle: startAngle,
      endAngle: endAngle,
      softness: softness,
      shadeFunction: shadeFunction,
      shadeFactor: shadeFactor,
      distance: distance,
    );

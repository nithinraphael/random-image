/// Provide relevantly typed "Nill" `Gradient`s for smooth tweens to emptiness.
library gradients;

import 'common.dart';

import 'steps/steps.dart';

/// A wrapper for retrieving transparent, empty `Gradient`s appropriate for
/// smooth `GradientTween`s.
///
/// Though all are transparent, consider that some have other properties set
/// as well; such as the start and end angle for [sweep] both being `~0`
/// or the `radius` of [radial] being `0`.
///
/// The getter [asNill] is an extended property for an instantiated `Gradient`.
/// It refers to the static method [nillify], which may be called as:
///
///     NillGradients.nillify(Type type)
extension NillGradients on Gradient {
  ///     Gradient get asNill => nillify( /* this. */ runtimeType);
  ///
  /// Returns an empty, transparent [Gradient] of type matching [runtimeType] if
  /// one is available. If `this` gradient's type is not pre-mapped to an empty,
  /// transparent "nill" gradient, `this` is copied with a number of pre-set
  /// "nill"-style properties, such as transparent colors, 0 radius,
  /// stops `[1.0, 1.0]`, etc.
  ///
  /// `Gradient.copyWith` itself falls back to returning a [new RadialGradient]
  /// if type cannot be matched.
  ///
  /// Used as:
  ///
  ///     final radialGradient = RadialGradient(. . .);
  ///     final emptyRadialGradient = radialGradient.asNill;
  Gradient get asNill =>
      nillify(runtimeType) ??
      copyWith(
        colors: [Colors.transparent, Colors.transparent],
        // stops: [0.5, 0.5],
        tileMode: TileMode.clamp,
        begin: Alignment.center,
        end: Alignment.center,
        center: Alignment.center,
        startAngle: 0.0,
        endAngle: 0.01,
        radius: 0.0,
        focal: Alignment.center,
        focalRadius: 0.0,
      );

  /// Returns an empty, transparent [Gradient] of type matching [type] if
  /// one is available. Otherwise returns `null` such that [asNill] might
  /// generate a "nill" gradient by `Gradient.copyWith()`, which itself falls
  /// back to `RadialGradient` if [type] cannot be matched.
  ///
  /// Used as:
  ///
  ///     final emptyRadialGradient = NillGradients.nillify(RadialGradient);
  ///
  /// ---
  /// TODO: Implement [GradientCopyWith]
  static Gradient? nillify(Type type) => (type == LinearGradient)
      ? linear
      : (type == RadialGradient)
          ? radial
          : (type == SweepGradient)
              ? sweep
              : (type == LinearSteps)
                  ? stepsLinear
                  : (type == RadialSteps)
                      ? stepsRadial
                      : (type == SweepSteps)
                          ? stepsSweep
                          : null;

  /// An empty, transparent [LinearGradient].
  static LinearGradient get linear => const LinearGradient(
        colors: [Colors.transparent, Colors.transparent],
        // stops: [0.5, 0.5],
        tileMode: TileMode.clamp,
        begin: Alignment.center,
        end: Alignment.center,
      );

  /// An empty, transparent [RadialGradient].
  static RadialGradient get radial => const RadialGradient(
        colors: [Colors.transparent, Colors.transparent],
        // stops: [0.5, 0.5],
        tileMode: TileMode.clamp,
        center: Alignment.center,
        radius: 0.0,
        // focal: Alignment.center,
        focal: null,
        focalRadius: 0.0,
      );

  /// An empty, transparent [SweepGradient].
  static SweepGradient get sweep => const SweepGradient(
        colors: [Colors.transparent, Colors.transparent],
        // stops: [0.5, 0.5],
        tileMode: TileMode.clamp,
        center: Alignment.center,
        startAngle: 0.0,
        endAngle: 0.01,
      );

  /// An empty, transparent [LinearSteps].
  static LinearSteps get stepsLinear => const LinearSteps(
        colors: [Colors.transparent, Colors.transparent],
        // stops: [0.5, 0.5],
        tileMode: TileMode.clamp,
        begin: Alignment.center,
        end: Alignment.center,
      );

  /// An empty, transparent [RadialSteps].
  static RadialSteps get stepsRadial => const RadialSteps(
        colors: [Colors.transparent, Colors.transparent],
        // stops: [0.5, 0.5],
        tileMode: TileMode.clamp,
        center: Alignment.center,
        radius: 0.0,
        // focal: Alignment.center,
        focal: null,
        focalRadius: 0.0,
      );

  /// An empty, transparent [SweepSteps].
  static SweepSteps get stepsSweep => const SweepSteps(
        colors: [Colors.transparent, Colors.transparent],
        // stops: [0.5, 0.5],
        tileMode: TileMode.clamp,
        center: Alignment.center,
        startAngle: 0.0,
        endAngle: 0.01,
      );
}

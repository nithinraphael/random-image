/// Provides `GradientTween` which specializes the interpolation
/// of [Tween<Gradient>] to use [Gradient.lerp] and bespoke
/// [IntermediateGradient]s.
library gradients;

import 'dart:math' as math;

import 'common.dart';
import 'steps/steps.dart';

/// An interpolation between two `Gradient`s.
///
/// This class specializes the interpolation of [Tween<Gradient>]
/// to use [Gradient.lerp] and bespoke [IntermediateGradient]s.
///
/// See [Tween] for a discussion on how to use interpolation objects.
class GradientTween extends Tween<Gradient?> {
  /// An interpolation between two `Gradient`s.
  ///
  /// This class specializes the interpolation of [Tween<Gradient>]
  /// to use [Gradient.lerp] and bespoke [IntermediateGradient]s.
  ///
  /// If needed, consider overriding [IntermediateGradient._copyWith] by
  /// providing a custom [GradientCopyWith] during construction as
  /// `overrideCopyWith`.
  ///
  /// See [Tween] for a discussion on how to use interpolation objects.
  GradientTween({
    Gradient? begin,
    Gradient? end,
    this.isAgressive = true,
    GradientCopyWith overrideCopyWith = spectrumCopyWith,
  }) : _copyWith = overrideCopyWith,
       super(begin: begin, end: end);

  /// Override this package's default `Gradient.copyWith()` method:
  /// [spectrumCopyWith], a wrapper for [GradientUtils] extension
  /// `Gradient.copyWith()`.
  ///
  /// ---
  /// {@macro GradientCopyWith}
  final GradientCopyWith _copyWith;

  /// Control the method used to lerp the gradients.
  final bool isAgressive;

  /// Return the value this variable has at the given animation clock value [t].
  ///
  /// If [begin] and [end] are gradients of the same type or if either is
  /// `null`, employs [Gradient.lerp]; which itself is a step up from the
  /// standard behavior.
  /// - [Gradient.lerp] will fade to `null` between gradients of dissimilar
  ///   types which gives a fad-out/fade-in tween
  ///
  /// In all other circumstances, however, this method can generated an
  /// [IntermediateGradient].
  ///
  /// This is done by comparing the [runtimeType] of [begin] & [end]
  /// against [t], providing the first type before `0.5` and the second after;
  /// creating a [GradientPacket] containing both gradients and passing [t]
  /// which can provide *any requested potential* gradient property using lerp;
  /// and interpolating the colors and stops of [begin] & [end] by creating
  /// and passing along a [PrimitiveGradient].
  ///
  /// If needed, consider overriding [IntermediateGradient._copyWith] by
  /// providing a custom [GradientCopyWith] during construction as
  /// `overrideCopyWith`.
  @override
  Gradient lerp(double t) {
    if (begin == null ||
        end == null ||
        (begin.runtimeType == end.runtimeType)) {
      return Gradient.lerp(begin, end, t)!;
    }

    final resolvedBegin = begin is IntermediateGradient
        ? (begin as IntermediateGradient).resolved
        // : begin is Steps
        //     ? (begin as Steps).asGradient
        : begin!;
    final resolvedEnd = end is IntermediateGradient
        ? (end as IntermediateGradient).resolved
        // : end is Steps
        //     ? (end as Steps).asGradient
        : end!;
    if (resolvedBegin.runtimeType == resolvedEnd.runtimeType) {
      return Gradient.lerp(resolvedBegin, resolvedEnd, t)!;
    }

    if (isAgressive) {
      final interpolated = PrimitiveGradient.fromStretchLerp(
        resolvedBegin,
        resolvedEnd,
        t,
      );
      return IntermediateGradient(
        PrimitiveGradient.byProgressiveMerge(
          t < 0.5 ? PrimitiveGradient.from(resolvedBegin) : interpolated,
          t < 0.5 ? interpolated : PrimitiveGradient.from(resolvedEnd),
          t < 0.5 ? t * 2 : (t - 0.5) * 2,
        ),
        GradientPacket(resolvedBegin, resolvedEnd, t),
        overrideCopyWith: _copyWith,
      );
    }

    return IntermediateGradient(
      PrimitiveGradient.byCombination(resolvedBegin, resolvedEnd, t),
      GradientPacket(resolvedBegin, resolvedEnd, t),
      overrideCopyWith: _copyWith,
    );
  }
}

/// A [new IntermediateGradient] can be [resolved] to a discrete form of
/// [Gradient] during tweens.
class IntermediateGradient extends Gradient {
  /// Considering the [GradientPacket.gradient] to output, [packet] of potential
  /// properties from both of two gradients, and the [primitive] of colors and
  /// stops formed from those same two gradients:
  ///
  /// Provide a dynamic [createShader] method that considers all the above to
  /// create a `dart:ui` [Shader] that best represents a mix of these gradients.
  IntermediateGradient(
    this.primitive,
    this.packet, {
    GradientCopyWith overrideCopyWith = spectrumCopyWith,
  }) : _copyWith = overrideCopyWith,
       super(colors: primitive.colors, stops: primitive.stops);

  /// The most basic representation of a [Gradient]: \
  /// a list of colors and a list of stops.
  ///
  /// This object is created by factory [PrimitiveGradient.fromStretchLerp]
  /// using these two lists of colors and two lists of stops and which
  /// considers a keyframe `t` for interpolating between them.
  final PrimitiveGradient primitive;

  /// {@macro gradientpacket}
  final GradientPacket packet;

  /// Override this package's default `Gradient.copyWith()` method:
  /// [spectrumCopyWith], a wrapper for [GradientUtils] extension
  /// `Gradient.copyWith()`.
  ///
  /// ---
  /// {@macro GradientCopyWith}
  final GradientCopyWith _copyWith;

  /// Falls back to `LinearGradient` if type is not hard-coded.
  ///
  /// Consider overriding [_copyWith] by providing a custom [GradientCopyWith]
  /// during construction as `overrideCopyWith`.
  @override
  Shader createShader(Rect rect, {TextDirection? textDirection}) =>
      resolved.createShader(rect, textDirection: textDirection);

  @override
  IntermediateGradient scale(double factor) =>
      IntermediateGradient(primitive.scale(factor), packet);

  @override
  Gradient withOpacity(double opacity) => resolved.withOpacity(opacity);

  /// Returns the literal `Gradient` result that this interpreted
  /// `IntermediateGradient` represents with its interpolated [packet], a
  /// [GradientPacket] with its own `t` keyframe, and [primitive] basic
  /// gradient representation with colors and stops.
  ///
  /// The lists of colors and stops should already be same length by this point,
  /// but something may have happened along the way through lerping or hot
  /// restarting that leaves a few cycles with dissimilar values.
  ///
  /// This getter will secure their lengths to a safe value.
  Gradient get resolved {
    if (packet.gradient is LinearSteps) {
      return (_copyWith(
                packet.gradient,
                colors: colors,
                stops: stops,
                transform: packet.transform,
                tileMode: packet.tileMode,
                begin: packet.begin,
                end: packet.end,
                softness: packet.softness,
                shadeFunction: packet.shadeFunction,
                shadeFactor: packet.shadeFactor,
                distance: packet.distance,
              )
              as LinearSteps)
          .asGradient;
    } else if (packet.gradient is RadialSteps) {
      return (_copyWith(
                packet.gradient,
                colors: colors,
                stops: stops,
                transform: packet.transform,
                tileMode: packet.tileMode,
                center: packet.center,
                radius: packet.radius,
                focal: packet.focal,
                focalRadius: packet.focalRadius,
                softness: packet.softness,
                shadeFunction: packet.shadeFunction,
                shadeFactor: packet.shadeFactor,
                distance: packet.distance,
              )
              as RadialSteps)
          .asGradient;
    } else if (packet.gradient is SweepSteps) {
      return (_copyWith(
                packet.gradient,
                colors: colors,
                stops: stops,
                transform: packet.transform,
                tileMode: packet.tileMode,
                center: packet.center,
                startAngle: packet.startAngle,
                endAngle: packet.endAngle,
                softness: packet.softness,
                shadeFunction: packet.shadeFunction,
                shadeFactor: packet.shadeFactor,
                distance: packet.distance,
              )
              as SweepSteps)
          .asGradient;
    }

    final safeLength = math.min(colors.length, stops?.length ?? colors.length);
    final safeColors =
        //  (packet.gradient is Steps) ? packet.gradient.steppedColors :
        <Color>[for (int i = 0; i < safeLength; i++) colors[i]];
    final safeStops =
        // (packet.gradient is Steps) ? packet.gradient.steppedStops :
        stops != null
        ? <double>[for (int i = 0; i < safeLength; i++) stops![i]]
        : stops;

    return _copyWith(
      packet.gradient,
      colors: safeColors,
      stops: safeStops,
      transform: packet.transform,
      tileMode: packet.tileMode,
      begin: packet.begin,
      end: packet.end,
      center: packet.center,
      radius: packet.radius,
      focal: packet.focal,
      focalRadius: packet.focalRadius,
      startAngle: packet.startAngle,
      endAngle: packet.endAngle,
      softness: packet.softness,
      shadeFunction: packet.shadeFunction,
      shadeFactor: packet.shadeFactor,
      distance: packet.distance,
    );
  }
}

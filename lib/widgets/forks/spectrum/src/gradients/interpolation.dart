/// A [PrimitiveGradient] and [GradientPacket] comprise the core of `Gradient`
/// interpolation. A [GradientTween] utilizes an [IntermediateGradient] during
/// the interpolation process; and a `PrimitiveGradient` and `GradientPacket`
/// construct the `IntermediateGradient`.
///
/// Beyond these two classes, provides functions [_mergeListDouble] and
/// [_mergeListColor] for lerping between lists of dissimilar length.
///
/// Through the variety of named constructors for [PrimitiveGradient], some
/// combination of interpolation is employed to achieve the required results.
library gradients;

import 'dart:collection' as collection;
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'common.dart';
import 'models.dart';
import 'steps/shaded.dart';
import 'steps/steps.dart';
import 'tween.dart';

/// Incorporate a `List<double>` [b] into list [a] over a period of time ranging
/// from [t] == `0.0 .. 1.0`.
///
/// When `t` is `0.0`, the list will resemble [a]. \
/// When `t` is `1.0`, the list will resemble [b].
///
/// The entries that lie within the range of "common length" are
/// [Color.lerp]ed from `a` -> `b` as `t` progresses `0.0` -> `1.0`.
///
/// As `t` grows, extra entries (considering the two `List`'s common length)
/// are progressively dropped from or added to the resultant list considering
/// their source is the begin or end list, `a` or `b`.
//
// ---
// - When `t == 0.0` *all extra entries* from [a] are present in returned list.
// - When `t == 1.0` *all extra entries* from [b] are present in return.
// ---
// - When `t == 1.0` *all extra entries* from [a] are absent from return.
// - When `t == 0.0` *all extra entries* from [b] are absent from return.
List<double> _mergeListDouble(
  List<double>? a,
  List<double>? b,
  double t, {
  bool shouldSort = true,
}) {
  a ??= <double>[];
  b ??= <double>[];
  final commonLength = math.min(a.length, b.length);
  final result = <double>[
    for (int i = 0; i < commonLength; i++) ui.lerpDouble(a[i], b[i], t)!,
    for (int i = commonLength; i < a.length && t < i / a.length / 100; i++)
      // for (int i = commonLength; i < a.length; i++)
      // ui.lerpDouble(a[i] * (1.0 - t), 1.0, t)!,
      // ui.lerpDouble(a[i], 0.0, t)!,
      // ui.lerpDouble(b.last, a[i], t < 0.5 ? (1.0 - t) * 2 : (1.0 - t) * 2)!,
      ui.lerpDouble(b.last, a[i], 1.0 - t)!,
    // ui.lerpDouble(a[i], b[(i / minLength).truncate()], t)!,
    for (int i = commonLength; i < b.length && t > i / b.length / 100; i++)
      // for (int i = commonLength; i < b.length; i++)
      // ui.lerpDouble(b[i] * (t), 1.0, t)!,
      // ui.lerpDouble(b[i], 0.0, t)!,
      // ui.lerpDouble(a.last, b[i], t < 0.5 ? (t) * 2 : (1.0 - t) * 2)!,
      // ui.lerpDouble(a.last, b[i], t)!,
      ui.lerpDouble(1.0, b[i], t)!,
    // ui.lerpDouble(b[i], a[(i / minLength).truncate()], t)!,
  ];
  if (shouldSort) result.sort();
  return result;
}

/// Incorporate a `List<Color>` [b] into list [a] over a period of time ranging
/// from [t] == `0.0 .. 1.0`.
///
/// When `t` is `0.0`, the list will resemble [a]. \
/// When `t` is `1.0`, the list will resemble [b].
///
/// The entries that lie within the range of "common length" are
/// [ui.lerpDouble]d from `a` -> `b` as `t` progresses `0.0` -> `1.0`.
///
/// As `t` grows, extra entries (considering the two `List`'s common length)
/// are progressively dropped from or added to the resultant list considering
/// their source is the begin or end list, `a` or `b`.
///
/// ---
/// - When `t == 0.0` *all extra entries* from [a] are present in returned list.
/// - When `t == 1.0` *all extra entries* from [b] are present in return.
/// ---
/// - When `t == 1.0` *all extra entries* from [a] are absent from return.
/// - When `t == 0.0` *all extra entries* from [b] are absent from return.
///
// ignore: unused_element
List<Color> _mergeListColor(List<Color>? a, List<Color>? b, double t) {
  if (a == null && b == null) return [Colors.transparent, Colors.transparent];
  if (b == null) return a!;
  if (a == null) return b;
  final commonLength = math.min(a.length, b.length);

  return <Color>[
    for (int i = 0; i < commonLength; i++) Color.lerp(a[i], b[i], t)!,
    // for (int i = commonLength; i < a.length; i++)
    //   Color.lerp(a[i], b.last, t)!,
    // for (int i = commonLength; i < b.length; i++)
    //   Color.lerp(b[i], a.last, (1.0 - t))!,
    for (int i = commonLength; i < a.length && t < i / a.length / 100; i++)
      // for (int i = commonLength; i < a.length; i++)
      // Color.lerp(null, a[i], 1.0 - t)!,
      Color.lerp(null, b.last, 1.0 - t)!,
    // Color.lerp(null, b[(i / commonLength).truncate()], 1.0 - t)!,
    // a[i].withOpacity((1.0 - t).clamp(0.0, 1.0)),
    for (int i = commonLength; i < b.length && t > i / b.length / 100; i++)
      // for (int i = commonLength; i < b.length; i++)
      // Color.lerp(b[i], null, 1.0 - t)!,
      Color.lerp(b[i], a.last, 1.0 - t)!,
    // Color.lerp(b[i], a[(i / commonLength).truncate()], 1.0 - t)!,
    // b[i].withOpacity((t).clamp(0.0, 1.0)),
  ];
}

/// The most basic representation of a gradient.
@immutable
class PrimitiveGradient {
  /// The most basic representation of a gradient: \
  /// `List<Color>` and `List<Stops>`.
  const PrimitiveGradient._(this.colors, this.stops);

  /// Dissolve a [Gradient] into a `PrimitiveGradient`.
  ///
  /// Borrows the provided [Gradient.colors] but feeds the (potentially `null`)
  /// `List<double>` [Gradient.stops] into the method [interpretStops].
  ///
  /// If this passed [gradient] has explicitly-constructed `stops`, they are
  /// returned unfettered. Otherwise an evenly-distributed list of implied stops
  /// is generated considering the [Gradient] type and the list of `colors`.
  factory PrimitiveGradient.from(Gradient gradient) =>
      PrimitiveGradient._(gradient.colors, interpretStops(gradient));

  /// This factory constructor will return a [PrimitiveGradient] whose [colors]
  /// and [stops] are progressively merged (as [t] progresses from `0.0 -> 1.0`)
  /// by lerping any entries that fall within a shared common list length range
  /// and adding any potential extra entries sourced from [b] as `t` grows while
  /// removing any potential extra entries sourced from [a] as `t` grows.
  factory PrimitiveGradient.byProgressiveMerge(
      PrimitiveGradient a, PrimitiveGradient b, double t) {
    final lerpedStops = _mergeListDouble(a.stops, b.stops, t, shouldSort: true);
    // final lerpedColors = _mergeListColor(a.colors, b.colors, t);
    final lerpedColors = lerpedStops
        .map<Color>(
          (double stop) => Color.lerp(
            // sample(a is Steps ? a.steppedColors : a.colors, aStops, stop),
            // sample(b is Steps ? b.steppedColors : b.colors, bStops, stop),
            sample(a.colors, a.stops, stop /*, isDecal*/),
            sample(b.colors, b.stops, stop /*, isDecal*/),
            t,
          )!,
        )
        .toList(growable: false);
    return PrimitiveGradient._(lerpedColors, lerpedStops);
  }

  /// Vanilla Flutter gradient merge process.
  ///
  /// Creates a new [collection.SplayTreeSet] with all stops from [a] & [b]
  /// then maps a list of `Color`s to that set of all stops.
  ///
  /// The mapped colors will still represent those of gradient `a` when `t`
  /// is `0.0` and represent gradient `b` when `t` is `1.0` by individually
  /// [Color.lerp]ing each mapping between a [sample] from `a` and another
  /// sample from `b` at the same keyframe `t`.
  factory PrimitiveGradient.byCombination(Gradient a, Gradient b, double t) {
    var aStops = /* a is Steps ? a.steppedStops : */ interpretStops(a);
    var bStops = /* b is Steps ? b.steppedStops : */ interpretStops(b);

    final stops = collection.SplayTreeSet<double>()
      ..addAll(aStops)
      ..addAll(bStops);
    final interpolatedStops = stops.toList(growable: false);

    // final stops = <double>[];
    // var stops = aStops + bStops;
    // var stops = aStops;
    // for (var stop in bStops) {
    //   if (!aStops.contains(stop)) stops.add(stop);
    // }
    // if ((t < 0.5 && b is Steps) || b is! Steps) stops.addAll(aStops);
    // if ((t > 0.5 && a is Steps) || a is! Steps) stops.addAll(bStops);
    // final interpolatedStops = stops..sort();

    // final isDecal =
    //     a.tileMode == TileMode.decal || b.tileMode == TileMode.decal;
    final interpolatedColors = interpolatedStops
        .map<Color>(
          (double stop) => Color.lerp(
            // sample(a is Steps ? a.steppedColors : a.colors, aStops, stop),
            // sample(b is Steps ? b.steppedColors : b.colors, bStops, stop),
            sample(a.colors, aStops, stop /*, isDecal*/),
            sample(b.colors, bStops, stop /*, isDecal*/),
            t,
          )!,
        )
        .toList(growable: false);
    return PrimitiveGradient._(interpolatedColors, interpolatedStops);
  }

  /// Interpolate two `Gradient`s' ***or*** `PrimitiveGradient`s'
  /// [colors] and [stops] at `t`.
  ///
  /// This factory constructor will use the provided [PrimitiveGradient]s
  /// or create them by [PrimitiveGradient.from] with provided [Gradient]s
  /// but the smaller (by length of `colors` list) is [stretchedTo] have
  /// the same number of entries as the larger.
  ///
  /// The returned [PrimitiveGradient] is then the result of [sameLengthLerp]ing
  /// the stretched and non-stretched gradient at the provided keyframe [t].
  factory PrimitiveGradient.fromStretchLerp(dynamic a, dynamic b, double t) {
    final max = math.max(
      a is Gradient
          ? a.colors.length
          : a is PrimitiveGradient
              ? a.colors.length
              : 0,
      b is Gradient
          ? b.colors.length
          : b is PrimitiveGradient
              ? b.colors.length
              : 0,
    );
    final _a = a is PrimitiveGradient ? a : PrimitiveGradient.from(a);
    final _b = b is PrimitiveGradient ? b : PrimitiveGradient.from(b);
    // Force these gradients to have the same number of colors/stops
    final stretchedA = _a.stretchedTo(max);
    final stretchedB = _b.stretchedTo(max);
    return PrimitiveGradient.sameLengthLerp(stretchedA, stretchedB, t);

    // final lerpedColorsA =
    //     lerpListColor(a.colors, stretchedA.colors, t < 0.5 ? t * 2 : 1.0);
    // final lerpedStopsA =
    //     lerpListDouble(a.stops, stretchedA.stops, t < 0.5 ? t * 2 : 1.0);
    // final lerpedColorsB =
    //     lerpListColor(b.colors, stretchedB.colors, t < 0.5 ? t * 2 : 1.0);
    // final lerpedStopsB =
    //     lerpListDouble(b.stops, stretchedB.stops, t < 0.5 ? t * 2 : 1.0);
    //
    // print('a.stops: ${interpretStops(a)}'); // print('stretchedA.stops: ${stretchedA.stops}'); // print('\nb.stops: ${interpretStops(b)}'); // print('stretchedB.stops: ${stretchedB.stops}');
    // return PrimitiveGradient.lerp(
    //   PrimitiveGradient._(lerpedColorsA, lerpedStopsA),
    //   PrimitiveGradient._(lerpedColorsB, lerpedStopsB),
    //   t,
    // );
  }

  /// The interpolated colors of the true [Gradient]s that this
  /// `PrimitiveGradient` boils down.
  final List<Color> colors;

  /// The interpolated stops of the true [Gradient]s that this
  /// `PrimitiveGradient` boils down.
  final List<double> stops;

  /// Extrapolate the stop at position [t] from a configured list of [stops].
  ///
  /// This process considers the actual beginning, ending, and intermediate
  /// values at each configured stop and returns a new stop that would resemble
  /// the place along this stops timeline of given length represented by
  /// keyframe [t].
  ///
  /// ---
  /// For example, if `stops` is `[0.0, 0.5, 0.75, 0.9]` with a length of four,
  /// a requested `t` percentage of `t: 0.8` returns the value `0.78`.
  ///
  /// The value returned may be expected to be `0.8` itself; however consider
  /// the stops list only ranges `0.0 .. 0.9`.
  ///
  /// This method starts with the lowest available stop that at least is greater
  /// than the truncated "position" of this `t` along a the list of
  /// `stops.length`.
  /// - As above, with `t: 0.8`, the position of this extrapolated stop is
  ///   `0.8 * stops.length` (length is 4) = `3.2`
  ///
  /// The individual "progress" of this extrapolated stop is 20% (`3.2 - 3`)
  /// of the way from the third stop to the fourth stop, `0.75` and `0.9`
  /// in this case.
  /// - `0.75 + (0.9 - 0.75) * 0.2 = 0.78`
  static double extrapolateStop(List<double> stops, double t) {
    final position = t * stops.length;
    final progress = position - position.truncate();

    final lastIndex = stops
        .lastIndexWhere((double s) => s <= position.truncate() / stops.length);
    final next = stops.firstWhere((double s) => s >= t, orElse: () => 1.0);

    final result = stops[lastIndex] + (next - stops[lastIndex]) * progress;
    // print('\nTARGET: $t; position: $position out of ${stops.length} | '
    //     'lastIndex: $lastIndex, next original stop: $next, \nresult: $result');
    return result;
  }

  /// Calculate the color at position [t] of the gradient
  /// defined by [colors] and [stops]. \
  /// Modified from vanilla [Gradient] `_sample()` to support fewer `Color`s.
  ///
  /// This abstracts the color selection process from the gradient type itself.
  // // static Color sample(List<Color> colors, List<double> stops, double t, bool isDecal ) {
  static Color sample(List<Color> colors, List<double> stops, double t) {
    if (colors.isEmpty) {
      colors = [Colors.transparent, Colors.transparent];
    } else if (colors.length == 1) {
      colors = colors + colors;
    }
    if (stops.isEmpty) {
      stops = [0.0, 1.0];
    } else if (stops.length == 1) {
      if (!stops.contains(1.0)) {
        stops = stops + [1.0];
      } else {
        stops = [0.0] + stops;
      }
    }
    final safeLength = math.min(colors.length, stops.length);
    final safeColors = <Color>[for (int i = 0; i < safeLength; i++) colors[i]];
    //final safeStops = <double>[for (int i = 0; i < safeLength; i++) stops[i]];
    for (var i = safeLength; i < stops.length; i++) {
      safeColors.add(colors.last);
    }
    // Colors at beginning and ending of stops/gradient
    if (t <= stops.first) {
      return // isDecal ? colors.first.withOpacity(0.0) :
          colors.first;
    }
    if (t >= stops.last) {
      return // isDecal ? colors.last.withOpacity(0.0) :
          colors.last;
    }
    final index = stops.lastIndexWhere((double s) => s <= t);
    return Color.lerp(
      safeColors[index],
      safeColors[index + 1],
      (t - stops[index]) / (stops[index + 1] - stops[index]),
    )!;
  }

  /// Force this [PrimitiveGradient] to have [length] number of colors/stops.
  ///
  /// This method tries to return a gradient comprised of more colors and stops
  /// than the original but that still represents the original visually.
  ///
  /// The returned `PrimitiveGradient` has first and last stops entries that
  /// have stayed the same but its intermittent entries have been remapped to
  /// accommodate extra colors/stops additions by [extrapolateStop]s and [sample].
  PrimitiveGradient stretchedTo(int length) {
    if (colors.length == length) return this;
    final stretchedStops = List<double>.generate(
      length,
      (int i) {
        if (i == 0) {
          return stops.first;
        } else if (i == length - 1) {
          return stops.last;
        } else {
          return extrapolateStop(stops, (i + 1) / length);
        }
      },
      growable: false,
    );
    final stretchedColors = stretchedStops
        .map<Color>((double stop) => sample(colors, stops, stop))
        .toList(growable: false);
    // print('input length: ${colors.length}, '
    // 'output length: ${stretchedColors.length} (desired: $length)\n\n');
    return PrimitiveGradient._(stretchedColors, stretchedStops);
  }

  /// "Scaling" this gradient represents reducing the opacity of all its colors
  /// by [Color.lerp] with `null` using [factor] as the keyframe `t`.
  PrimitiveGradient scale(double factor) => PrimitiveGradient._(
        colors
            .map<Color>((Color color) => Color.lerp(null, color, factor)!)
            .toList(growable: false),
        stops,
      );

  /// Linearally interpolate between `PrimitiveGradient`s [a] and [b] at any
  /// given keyframe (`double`) [t], generally `0.0 .. 1.0`.
  ///
  /// This method presumes the gradients have the same number of [colors].
  static PrimitiveGradient sameLengthLerp(
    PrimitiveGradient a,
    PrimitiveGradient b,
    double t,
  ) {
    assert(a.colors.length == b.colors.length, 'list lengths should be equal');
    final length = a.colors.length;
    final lerpedStops = _mergeListDouble(a.stops, b.stops, t);
    final lerpedColors = <Color>[
      for (int i = 0; i < length; i++) Color.lerp(a.colors[i], b.colors[i], t)!,
    ];
    return PrimitiveGradient._(lerpedColors, lerpedStops);
  }
}

/// If a list of colors and list of stops makes a [PrimitiveGradient],
/// does this [GradientPacket] constitute a supergradient?
@immutable
class GradientPacket {
  /// If a list of colors and list of stops makes a [PrimitiveGradient],
  /// does this [GradientPacket] constitute a supergradient?
  ///
  /// {@template gradientpacket}
  /// This `Packet` holds onto two `Gradient`s and a `t` keyframe.
  ///
  /// When requesting any potential `Gradient` property other than colors or
  /// stops, this `Packet` may be called upon and will provide the relevant
  /// lerp at [t].
  ///
  /// If either gradient does not have the requested property, a default value
  /// is provided as per [GradientUtils].
  /// {@endtemplate}
  const GradientPacket(this.a, this.b, this.t);

  /// A [Gradient] that this `GradientPacket` stores and represents.
  ///
  /// This packet's getters will consider [t] and use an appropriate `lerp()`
  /// method to interpolate between gradient `a` and gradient `b`.
  final Gradient a, b;

  /// The keyframe for this `GradientPacket` for retrieving the properties
  /// of these respective [a] & [b] `Gradient`s using an appropriate `lerp()`
  /// method.
  ///
  /// A value of `t == 0` means this packet will return the properties of
  /// `Gradient` [a], while `t == 1` has this packet return the properties
  /// of `Gradient` [b].
  ///
  /// A `t` somewhere between `0..1` returns properties via this
  /// `GradientPacket`'s getters that represent the mixture of the respective
  /// property from [a] & [b] at a ratio where `t` is interpreted as
  /// a percentage between `a..b`.
  final double t;

  Gradient get _a => a is IntermediateGradient
      ? (a as IntermediateGradient).packet.t < 0.5
          ? (a as IntermediateGradient).packet.a
          : (a as IntermediateGradient).packet.b
      // : a is Steps
      //     ? (a as Steps).asGradient
      : a;
  Gradient get _b => b is IntermediateGradient
      ? (b as IntermediateGradient).packet.t < 0.5
          ? (b as IntermediateGradient).packet.a
          : (b as IntermediateGradient).packet.b
      // : b is Steps
      //     ? (b as Steps).asGradient
      : b;

  bool get _areSame => _a.runtimeType == _b.runtimeType;

  /// If [a] & [b] are the same `Type` of [Gradient], returns [t].
  ///
  /// Otherwise doubles [t] to to return range `0..1` while `t<0.5` & doubles
  /// [t] after subtracting `0.5` to to return range `0..1` while `t>0.5`.
  double get _t => _areSame
      ? t
      : t < 0.5
          ? t * 2
          : (t - 0.5) * 2;

  bool get _shareLinearProps {
    final aType = _a.runtimeType;
    final bType = _b.runtimeType;
    return _areSame ||
        ((aType == LinearGradient ||
                aType == LinearSteps ||
                aType == LinearShadedSteps) &&
            (bType == LinearGradient ||
                bType == LinearSteps ||
                bType == LinearShadedSteps));
  }

  bool get _shareRadialProps {
    final aType = _a.runtimeType;
    final bType = _b.runtimeType;
    return _areSame ||
        ((aType == RadialGradient ||
                aType == RadialSteps ||
                aType == RadialShadedSteps) &&
            (bType == RadialGradient ||
                bType == RadialSteps ||
                bType == RadialShadedSteps));
  }

  bool get _shareSweepProps {
    final aType = _a.runtimeType;
    final bType = _b.runtimeType;
    return _areSame ||
        ((aType == SweepGradient ||
                aType == SweepSteps ||
                aType == SweepShadedSteps) &&
            (bType == SweepGradient ||
                bType == SweepSteps ||
                bType == SweepShadedSteps));
  }

  bool get _shareCenterProp {
    final aType = _a.runtimeType;
    final bType = _b.runtimeType;
    return _areSame ||
        ((aType == RadialGradient ||
                aType == RadialSteps ||
                aType == RadialShadedSteps ||
                aType == SweepGradient ||
                aType == SweepSteps ||
                aType == SweepShadedSteps) &&
            (bType == RadialGradient ||
                bType == RadialSteps ||
                bType == RadialShadedSteps ||
                bType == SweepGradient ||
                bType == SweepSteps ||
                bType == SweepShadedSteps));
  }

  //# UNIVERSAL

  /// {@template gradientpacket_getter}
  /// Returns the interpolation of this [Gradient] / `Gradient`-subclass
  /// property at keyframe [t] for gradients [a] and [b].
  ///
  /// See [GradientUtils] to understand how fallbacks are determined for
  /// subclasses that do not contain this property.
  /// {@endtemplate}
  Gradient get gradient => t < 0.5 ? _a : _b;

  /// {@macro gradientpacket_getter}
  GradientTransform? get transform => t < 0.5 ? _a.transform : _b.transform;

  /// {@macro gradientpacket_getter}
  TileMode get tileMode => t < 0.5 ? _a.tileMode : _b.tileMode;

  //# LINEAR

  /// {@macro gradientpacket_getter}
  AlignmentGeometry get begin =>
      AlignmentGeometry.lerp(_a.begin, _b.begin, _shareLinearProps ? t : _t)!;

  /// {@macro gradientpacket_getter}
  AlignmentGeometry get end =>
      AlignmentGeometry.lerp(_a.end, _b.end, _shareLinearProps ? t : _t)!;

  //# RADIAL or SWEEP

  /// {@macro gradientpacket_getter}
  AlignmentGeometry get center =>
      AlignmentGeometry.lerp(_a.center, _b.center, _shareCenterProp ? t : _t)!;

  //# RADIAL

  /// {@macro gradientpacket_getter}
  double get radius => math.max(
        0.0,
        ui.lerpDouble(_a.radius, _b.radius, _shareRadialProps ? t : _t)!,
      );

  /// {@macro gradientpacket_getter}
  AlignmentGeometry? get focal => AlignmentGeometry.lerp(
        _a.focal,
        _b.focal,
        _shareRadialProps ? t : _t,
      );

  /// {@macro gradientpacket_getter}
  double get focalRadius => math.max(
      0.0,
      ui.lerpDouble(
        _a.focalRadius,
        _b.focalRadius,
        _shareRadialProps ? t : _t,
      )!);

  //# SWEEP

  /// {@macro gradientpacket_getter}
  double get startAngle => math.max(
        0.0,
        ui.lerpDouble(_a.startAngle, _b.startAngle, _shareSweepProps ? t : _t)!,
      );

  /// {@macro gradientpacket_getter}
  double get endAngle => math.max(
        0.0,
        ui.lerpDouble(_a.endAngle, _b.endAngle, _shareSweepProps ? t : _t)!,
      );

  //# STEPS

  /// {@macro gradientpacket_getter}
  double get softness =>
      math.max(0.0, ui.lerpDouble(_a.softness, _b.softness, _t)!);

  //# SHADED STEPS

  /// {@macro gradientpacket_getter}
  ColorArithmetic get shadeFunction =>
      t < 0.5 ? _a.shadeFunction : _b.shadeFunction;

  /// {@macro gradientpacket_getter}
  double get shadeFactor =>
      math.max(0.0, ui.lerpDouble(a.shadeFactor, b.shadeFactor.toDouble(), t)!);

  /// {@macro gradientpacket_getter}
  double get distance =>
      math.max(0.0, ui.lerpDouble(_a.distance, _b.distance, _t)!);
}

// /// Incorporate a `List<Color>` [b] into list [a] over a period of time ranging
// /// from [t] == `0.0 .. 1.0`. See [_mergeListColor] which performs this
// /// functionality but accepts `List<Color>` instead of [Gradient].
// ///
// /// When `t` is `0.0`, the list will resemble [a]. \
// /// When `t` is `1.0`, the list will resemble [b].
// List<Color> lerpListColorFrom(Gradient? a, Gradient? b, double t) {
//   if (a == null && b == null) return [Colors.transparent,Colors.transparent];
//   if (b == null) return a!.colors;
//   if (a == null) return b.colors;
//   final commonLength = math.min(a.colors.length, b.colors.length);
//   final colorsA = a.colors;
//   final colorsB = b.colors;
//   final decalA = a.tileMode == TileMode.decal;
//   final decalB = b.tileMode == TileMode.decal;

//   Color lastOrTransparent(List<Color> colors, int index, bool isDecal) {
//     if (index == colors.length) {
//       return isDecal ? Colors.transparent : colors.last;
//     }
//     return colors[index];
//   }

//   return <Color>[
//     for (int i = 0; i < commonLength; i++)
//       // Color.lerp(lastOrTransparent(colorsA, i, decalA),
//       //   lastOrTransparent(colorsB, i, decalB), t)!,
//       Color.lerp(colorsA[i], colorsB[i], t)!,
//     // for (int i = commonLength; i < a.length; i++)
//     //   Color.lerp(a[i], b.last, t)!,
//     // for (int i = commonLength; i < b.length; i++)
//     //   Color.lerp(b[i], a.last, (1.0 - t))!,
//     for (int i = commonLength; i < colorsA.length; i++)
//       // Color.lerp(null, lastOrTransparent(colorsA, i, decalA), 1.0 - t)!,
//       // Color.lerp(null, colorsA[i], 1.0 - t)!,
//       colorsA[i].withOpacity((1.0 - t).clamp(0.0, 1.0)),
//     for (int i = commonLength; i < colorsB.length; i++)
//       // Color.lerp(lastOrTransparent(colorsB, i, decalB), null, 1.0 - t)!,
//       // Color.lerp(colorsB[i], null, 1.0 - t)!,
//       colorsB[i].withOpacity((t).clamp(0.0, 1.0)),
//   ];
// }

/// Defines [SwatchMode] for `MaterialColor` generation.
///
/// Bakes various `Color`-based functionalities into [Spectrum] and
/// [SpectrumUtils].
///
/// [MaterialColor] or [MaterialAccentColor] -> `List<Color>` by extensions
/// [MaterialColorToList] and [MaterialAccentToList].
library colors;

import 'common.dart';

/// Describes the methods that may be employed to derive a range of [Color]s.
enum SwatchMode {
  /// Implies the useage of [Shading]. See the `withWhite()` extension method
  /// for an example.
  ///
  /// A swatch range of colors could be derived such as:
  ///
  ///     c.withWhite(-r),
  ///     ...,
  ///     c.withWhite(-r/3),
  ///     c.withWhite(-r/4),
  ///     c,
  ///     c.withWhite(r/4),
  ///     c.withWhite(r/3),
  ///     ...,
  ///     c.withWhite(r)
  shade,

  /// Suggests the usage of [Color.alphaBlend], such as creating a swatch
  /// where the lower colors `alphaBlend` the original color with [Colors.white]
  /// with increasing degrees of color alpha strength, and the upper colors
  /// `alphaBlend` the original with [Colors.black] with decreasing degrees of
  /// color alpha strength.
  ///
  /// The lower values would progress toward white, regardless of original
  /// color, while the upper values progress toward black, regardless of
  /// original color. The medium value would resemble the original color.
  desaturate,

  /// For the generation of a color swatch that is comprised of equidistant
  /// complimentary colors.
  ///
  /// For a [MaterialColor], a 10-count complements `List<Color>` would mostly
  /// resemble a rainbow through the hues, but where `shade500` would be the
  /// original color and progress around the color wheel past `shade900` and
  /// looping back to `shade400` and every shade would have the same
  /// "saturation" and "lightness" as the original color.
  ///
  /// For a [MaterialAccentColor], a 5-count complements `List<Color>` looks
  /// less like a rainbow and more like a
  /// resemble a rainbow through the hues, but where `shade500` would be the
  /// original color and progress around the color wheel past `shade900` and
  /// looping back to `shade400` and every shade would have the same
  /// "saturation" and "lightness" as the original color.
  complements,

  /// Employ transparency in swatch development, such as fading from fully
  /// transparent and stepping up to fully opaque.
  ///
  /// In the above example, the original color would not be a generated swatch's
  /// medium, or default, value. The original color would exist at the very top
  /// of the range produced for the swatch.
  ///
  /// This differs from a standard [MaterialColor], for example, as the
  /// `shade500` or `materialColor[500]` value is equivalent to the value
  /// returned by `materialColor` used by itself as a `Color`,
  /// or `materialColor == materialColor[500]`.
  ///
  /// With this example, a generated `spectrumMaterialColor` using [fade]
  /// returns the equivalent `Color` as that of the one represented by
  /// `spectrumMaterialColor` used as itself when accessing its `shade900`,
  /// or `spectrumMaterialColor == spectrumMaterialColor[900]`.
  fade,
}

/// Abstract helper class for functionality provided by Spectrum.
///
/// Consider [alphaChannel], a method that will consider a `num? strength`
/// for usage as the alpha channel of a color, provided a `double` for opacity,
/// an `int` for alpha, or returning `null` otherwise.
abstract class Spectrum {
  /// Considers the provided number(?) [strength].
  ///
  /// If `strength` is between `0..1`, the return is an appropriate `int` for
  /// the alpha channel representing that strength as an opacity multiplied by
  /// the max channel value `0xFF`.
  ///
  /// After that check, if `strength` is an [int] or [double], the return is
  /// `strength`.
  ///
  /// If all else fails, the return is `null`; say, if provided `strength`
  /// itself is also `null`.
  static int? alphaChannel(num? strength) => alphaFromStrength(strength);

  /// Accepts a `Color` and returns a [MaterialColor] whose primary is the
  /// provided `color` and whose `swatch` is generated according to [mode]
  /// and [factor].
  static MaterialColor materialColor(
    Color color, {
    SwatchMode mode = SwatchMode.shade,
    double? factor,
  }) => materialPrimaryFrom(color, mode, factor);

  /// Accepts a `Color` and returns a [MaterialAccentColor] whose primary is the
  /// provided `color` and whose `swatch` is generated according to [mode]
  /// and [factor].
  static MaterialAccentColor materialAccent(
    Color color, {
    SwatchMode mode = SwatchMode.shade,
    double? factor,
  }) => materialAccentFrom(color, mode, factor);
}

/// [Spectrum]-branded [Color] extension methods and getters, namely for the
/// generation of complementary colors.
extension SpectrumUtils on Color {
  /// A shortcut for [Color.lerp].
  ///
  /// The first color is `this` and the second is [other]. The parameter [blend]
  /// corresponds to the `t` interpolation keyframe of the lerp and defaults to
  /// `0.5`.
  ///
  /// If this lerp is `null`, return falls back to `this`.
  Color blend(Color other, [double blend = 0.5]) =>
      Color.lerp(this, other, blend) ?? this;

  /// Returns `this` color as a [MaterialColor] via [materialPrimaryFrom]
  /// using [SwatchMode.shade] and a `factor` of `200`.
  MaterialColor get asMaterialColor
  // (Color color, {SwatchMode mode = SwatchMode.shade, double? factor, })
  =>
      // materialPrimaryFrom(this, mode, factor);
      materialPrimaryFrom(this, SwatchMode.shade, 200);

  /// Returns `this` color as a [MaterialAccentColor] via [materialAccentFrom]
  /// using [SwatchMode.shade] and a `factor` of `200`.
  MaterialAccentColor get asMaterialAccent
  // (Color color, {SwatchMode mode = SwatchMode.shade, double? factor,})
  =>
      // materialAccentFrom(color, mode, factor);
      materialAccentFrom(this, SwatchMode.shade, 200);

  /// Returns a two-entry `List<Color>` containing `this`
  /// and the inverse of `this`, resembling:
  ///
  ///     [this, -this]
  ///
  /// This getter is more optimized than `complementary(2)`.
  List<Color> get complementPair => [this, -this];

  /// Returns a three-entry `List<Color>` containing `this` and two versions of
  /// `this` with its components shifted, resembling:
  ///
  ///     [this == RGB, BRG, GBR]
  ///
  /// This getter is more optimized than `complementary(3)`.
  List<Color> get complementTriad => [
    this,
    Color.fromARGB(alpha, blue, red, green),
    Color.fromARGB(alpha, green, blue, red),
  ];

  // /// Returns a four-entry `List<Color>` containing `this` and the three
  // /// equidistant colors obtained by traveling the color wheel clockwise
  // /// starting with `this` and wrapping around the wheel back to `this`.
  // ///
  // /// Calls [complementary] with `count: 4`.
  // ///
  // /// (The final entry does not match `this`, it is the complement just
  // /// before it.)
  // List<Color> get complementTetrad => complementary(4);

  // /// Returns a five-entry `List<Color>` containing `this` and the four
  // /// equidistant colors obtained by traveling the color wheel clockwise
  // /// starting with `this` and wrapping around the wheel back to `this`.
  // ///
  // /// Calls [complementary] with `count: 5`.
  // ///
  // /// (The final entry does not match `this`, it is the complement just
  // /// before it.)
  // List<Color> get complementPentad => complementary(5);

  // /// Returns a ten-entry `List<Color>` containing `this` and the nine
  // /// equidistant colors obtained by traveling the color wheel clockwise
  // /// starting with `this` and wrapping around the wheel back to `this`.
  // ///
  // /// Calls [complementary] with `count: 10`. Could be used to generate
  // /// a rainbow swatch palette starting at a given color.
  // ///
  // /// (The final entry does not match `this`, it is the complement just
  // /// before it.)
  // List<Color> get complementDecad => complementary(10);

  /// The number of `Color`s returned in this `List` will match [count], and
  /// the original color `this` will be first amongst them.
  List<Color> complementary(int count, [double? distance]) {
    double wrap(double component, double d) {
      final sum = component + d;
      if (sum >= 0 && sum <= 360) return sum;
      return sum.remainder(360);
    }

    final shift = 360 / count;
    final hsl = HSLColor.fromColor(this);
    return List<Color>.generate(
      count,
      (int i) => HSLColor.fromAHSL(
        hsl.alpha,
        wrap(hsl.hue, shift * i),
        hsl.saturation,
        hsl.lightness,
      ).toColor(),
    );
  }
}

/// Offers methods [asList] and [toList] to convert a [MaterialColor] into a
/// boiled-down `List<Color>`.
extension MaterialColorToList on MaterialColor {
  /// Returns the `shade50 .. shade900` formed `List<Color>` from the
  /// [MaterialColor] provided as `this`.
  List<Color> get asList => [
    shade50,
    shade100,
    shade200,
    shade300,
    shade400,
    shade500,
    shade600,
    shade700,
    shade800,
    shade900,
  ];

  /// Returns the `shade50 .. shade900` formed `List<Color>` from the
  /// [MaterialColor] provided as `this`.
  ///
  /// If [includePrimary] is `true`, an additional entry located at the
  /// beginning will have the value of `this` itself. \
  /// Default is `true` to differentiate versatility from [asList].
  List<Color> toList({bool includePrimary = true}) => [
    if (includePrimary) this,
    shade50,
    shade100,
    shade200,
    shade300,
    shade400,
    shade500,
    shade600,
    shade700,
    shade800,
    shade900,
  ];
}

/// Offers methods [asList] and [toList] to convert a [MaterialAccentColor] into
/// a boiled-down `List<Color>`.
extension MaterialAccentToList on MaterialAccentColor {
  /// Returns the `shade50 .. shade700` formed `List<Color>` from the
  /// [MaterialAccentColor] provided as `this`.
  List<Color> get asList => [
    this[50]!,
    this[100]!,
    this[200]!,
    this[400]!,
    this[700]!,
  ];

  /// Returns the `shade50 .. shade700` formed `List<Color>` from the
  /// [MaterialAccentColor] provided as `this`.
  ///
  /// If [includePrimary] is `true`, an additional entry located at the
  /// beginning will have the value of `this` itself. \
  /// Default is `true` to differentiate versatility from [asList].
  List<Color> toList({bool includePrimary = true}) => [
    if (includePrimary) this,
    this[50]!,
    this[100]!,
    this[200]!,
    this[400]!,
    this[700]!,
  ];
}

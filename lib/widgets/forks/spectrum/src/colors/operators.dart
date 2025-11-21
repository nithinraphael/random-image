/// Provides `Color` operators with [ColorOperators].
///
/// Also exposes these operators through methods in [ColorOperatorsMethods] that
/// also introduce `strength` support to shortcut override opacity/alpha with a
/// single dynamic value, `0..1` or `2..255`.
library colors;

import 'common.dart';

/// `ColorOperators` extends `Color` with operators support.
///
/// - [-], to invert a `Color`
///
/// - [>] & [<], to compare the luminance of `Color`s
///
/// - [+] & [-], to add/subtract the RGB components to/from one another,
/// maintaining the [alpha] from the original color `this`
///
/// - [~/], to average all components of two colors together, including [alpha]
///
/// - [|], to randomly choose a `Color`, either `this` or `Color other`;
/// unless the operand on the right is a `List<Color>`, then the random choice
/// may come from the list or `this`.
extension ColorOperators on Color {
  /// ### [Color] Inversion Operator
  /// Invert the [red], [green], and [blue] channels of a `Color`, maintaining
  /// [alpha], by subtracting each of its components from the
  /// maximum value for a component, `255` or `0xFF`; such as:
  ///
  /// ```dart
  /// R=50 => 255-50=205, G=100 => 255-100=155, B=200 => 255-200=55
  /// RGB(50,100,200) => RGB(205,155,55)
  /// ```
  Color operator -() =>
      Color.fromARGB(alpha, 0xFF - red, 0xFF - green, 0xFF - blue);

  /// ### [Color] Greater Than Operator
  /// Returns `true` if `this Color` is "lighter" than `other` according to
  /// method [computeLuminance].
  ///
  // ignore: lines_longer_than_80_chars
  ///     bool operator >(Color other) => computeLuminance() > other.computeLuminance();
  ///
  /// ### [computeLuminance]:
  /// "Returns a brightness value between 0 for darkest and 1 for lightest.
  /// Represents the relative luminance of the color. \
  /// **This value is computationally expensive to calculate.**
  /// *See https://en.wikipedia.org/wiki/Relative_luminance.*"
  ///
  /// ### Nitty Gritty
  /// To compute luminance of a color, each component (first divided by `255`
  /// or `0xFF`) is linearized as such:
  ///
  ///     if (component <= 0.03928)
  ///       return component / 12.92;
  ///     return math.pow((component + 0.055) / 1.055, 2.4) as double;
  ///
  /// Then each component contributes itself as a different percentage of the
  /// output luminance as such:
  ///
  ///     return 0.2126 * R + 0.7152 * G + 0.0722 * B;
  bool operator >(Color other) => computeLuminance() > other.computeLuminance();

  /// ### [Color] Less Than Operator
  /// Returns `true` if `this Color` is "darker" than `other` according to
  /// method [computeLuminance].
  ///
  // ignore: lines_longer_than_80_chars
  ///     bool operator <(Color other) => computeLuminance() < other.computeLuminance();
  ///
  /// ### [computeLuminance]:
  /// "Returns a brightness value between 0 for darkest and 1 for lightest.
  /// Represents the relative luminance of the color. \
  /// **This value is computationally expensive to calculate.**
  /// *See https://en.wikipedia.org/wiki/Relative_luminance.*"
  ///
  /// ### Nitty Gritty
  /// To compute luminance of a color, each component (first divided by `255`
  /// or `0xFF`) is linearized as such:
  ///
  ///     if (component <= 0.03928)
  ///       return component / 12.92;
  ///     return math.pow((component + 0.055) / 1.055, 2.4) as double;
  ///
  /// Then each component contributes itself as a different percentage of the
  /// output luminance as such:
  ///
  ///     return 0.2126 * R + 0.7152 * G + 0.0722 * B;
  bool operator <(Color other) => computeLuminance() < other.computeLuminance();

  /// ### [Color] Addition Operator
  /// Add the [red], [green], and [blue] channels
  /// of `other` with those of `this Color`.
  ///
  /// The resultant [alpha] is maintained from `this`.
  ///
  // /// To *also add* the `alpha` from each `Color`, see [&].
  Color operator +(Color other) => Color.fromARGB(
        alpha,
        (red + other.red).restricted,
        (green + other.green).restricted,
        (blue + other.blue).restricted,
      );

  /// ### [Color] Subtraction Operator
  /// Subtract the [red], [green], and [blue] channels
  /// of `other` from those of `this Color`.
  ///
  /// The resultant [alpha] is maintained from `this`.
  ///
  // /// To *also subtract* the `alpha` from each `Color`, see [^].
  Color operator -(Color other) => Color.fromARGB(
        alpha,
        (red - other.red).restricted,
        (green - other.green).restricted,
        (blue - other.blue).restricted,
      );

  /// ### [Color] Average Operator
  /// Average the [alpha], [red], [green], and [blue] channels
  /// of a `Color` with another `other`.
  Color operator ~/(Color other) => Color.fromARGB(
        ((alpha + other.alpha) ~/ 2).restricted,
        ((red + other.red) ~/ 2).restricted,
        ((green + other.green) ~/ 2).restricted,
        ((blue + other.blue) ~/ 2).restricted,
      );

  /// ### [Color] Or Operator
  /// Random `Color` access.
  ///
  /// If `others is Color`, the return value is `this` *or* `others`.
  ///
  /// If `others is List<Color>`, the return value is `this` *or* one of the
  /// entries from `others`.
  Color operator |(dynamic others) => (others is Color)
      // Expanding first enables the mingling of Color-subtype objects,
      // like MaterialColors and MaterialAccentColors.
      ? (List.from([
          [others] + [this]
        ].expand((list) => list).toList())
            ..shuffle())
          .first
      : (others is List<Color>)
          ? (List.from([
              others,
              [this]
            ].expand((list) => list).toList())
                ..shuffle())
              .first
          : this;
}

/// - [inverted], for returning `-this`
/// - [compareLuminance], for returning the brighter or darker `Color`
///   utilizing `>`
/// - [or], for randomization by `Color | List<Color>`
///
/// The following methods resemble the operator counterparts but they have a
/// slot for provision of a `strength` or alpha/opacity override
/// (see [alphaFromStrength] for details):
/// - [add], to `+` one `Color` to another
/// - [subtract], to `-` one `Color` from another
/// - [average], to `~/` all channels of two `Color`s
extension ColorOperatorsMethods on Color {
  /// Invert [red], [green] and [blue] channels of `this`, maintaining [alpha].
  Color get inverted => -this;

  /// Exposure `method` for `>` operator.
  ///
  /// Parameter [returnBrighter] is `true` by default, and so `this` color will
  /// be returned if it is brighter than [other]. If `this` color is brighter
  /// than [other] and [returnBrighter] is `false`, then [other] is returned
  /// instead.
  ///
  /// The matter of being "brighter" is determined by the `>` operator, which
  /// compares the colors using [computeLuminance]. \
  /// "This value is computationally expensive to calculate."
  Color compareLuminance(Color other, {bool returnBrighter = true}) =>
      this > other
          ? returnBrighter
              ? this
              : other
          : returnBrighter
              ? other
              : this;

  /// Exposure `method` for `|` operator: random `Color` access.
  ///
  /// If `others is Color`, the return value is `this` or `others`.
  ///
  /// If `others is List<Color>`, the return value is `this` or one of the
  /// entries from `others`.
  Color or(dynamic others) => this | others;

  /// Add the `red`, `green`, and `blue` channels of `other` with
  /// those of `this Color`. The resultant [alpha] is maintained from `this`,
  /// unless a `strength` would be specified which is used instead.
  ///
  /// See [alphaFromStrength] for details on using a value between `0..1` or
  /// `2..255` as a shortcut for specifying alpha/opacity override.
  ///
  /// Exposure `method` for `+` operator, providing [strength].
  Color add(Color other, [dynamic strength]) =>
      withAlpha(alphaFromStrength(strength) ?? alpha) + other;

  // /// Consider [add] except the resultant [alpha]
  // /// is the sum of both `Color`s' `alpha`.
  // ///
  // /// Exposure `method` for [&] `operator`.
  // Color and(Color other) => this & other;

  /// Subtract the `red`, `green`, and `blue` channels of `other` from
  /// those of `this Color`. The resultant [alpha] is maintained from `this`,
  /// unless a `strength` would be specified which is used instead.
  ///
  /// See [alphaFromStrength] for details on using a value between `0..1` or
  /// `2..255` as a shortcut for specifying alpha/opacity override.
  ///
  /// Exposure `method` for `-` operator, providing [strength].
  Color subtract(Color other, [dynamic strength]) =>
      withAlpha(alphaFromStrength(strength) ?? alpha) - other;

  /// Average the `alpha`, `red`, `green`, and `blue` channels
  /// of a `Color` with another `other`.
  ///
  /// The resultant [alpha] may be overridden by providing a `strength`.
  ///
  /// See [alphaFromStrength] for details on using a value between `0..1` or
  /// `2..255` as a shortcut for specifying alpha/opacity override.
  ///
  /// Exposure `method` for `~/` operator, providing [strength].
  Color average(Color other, [dynamic strength]) =>
      withAlpha(alphaFromStrength(strength) ?? alpha) ~/ other;
}

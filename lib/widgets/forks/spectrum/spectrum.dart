// # spectrum
/// ![spectrum header image](https://raw.githubusercontent.com/Zabadam/spectrum/main/doc/img/spectrum_50.gif)
/// ## [pub.dev Listing](https://pub.dev/packages/spectrum) | [API Doc](https://pub.dev/documentation/spectrum/latest) | [GitHub](https://github.com/Zabadam/spectrum)
//
// A rainbow of `Color` and `Gradient` utilities such as [`GradientTween`](https://pub.dev/documentation/spectrum/latest/spectrum/GradientTween-class.html),
// gradient [`copyWith()`](https://pub.dev/documentation/spectrum/latest/spectrum/GradientUtils/copyWith.html)
// any potential parameters for the many types, [`complementary()`](https://pub.dev/documentation/spectrum/latest/spectrum/SpectrumUtils/complementary.html)
// for colors, [`AnimatedGradient`](https://pub.dev/documentation/spectrum/latest/spectrum/AnimatedGradient-class.html),
// [`MaterialColor` generation](https://pub.dev/documentation/spectrum/latest/spectrum/SpectrumUtils/materialColor.html),
// and more!
///
/// ---
/// This import is the all-in-one library and includes both `colors` and
/// `gradients`.
///
/// For only the functionality of either modular portion of `spectrum`:
///
///     import 'package:spectrum/colors.dart';
///     import 'package:spectrum/gradients.dart';
///
/// ##### Gradient API References:  [`GradientUtils`](https://pub.dev/documentation/spectrum/latest/gradients/GradientUtils.html) | [`GradientTween`](https://pub.dev/documentation/spectrum/latest/gradients/GradientTween-class.html) | [`Steps`](https://pub.dev/documentation/spectrum/latest/gradients/Steps-class.html) | [`FooShadedSteps`](https://pub.dev/documentation/spectrum/latest/gradients/RadialShadedSteps-class.html) | [`AnimatedGradient`](https://pub.dev/documentation/spectrum/latest/gradients/AnimatedGradient-class.html)
/// ##### Color API References: [`Shading`](https://pub.dev/documentation/spectrum/latest/colors/Shading.html) | [`ColorOperators`](https://pub.dev/documentation/spectrum/latest/colors/ColorOperators.html) | [`ColorOperatorsMethods`](https://pub.dev/documentation/spectrum/latest/colors/ColorOperatorsMethods.html) | [`Spectrum`](https://pub.dev/documentation/spectrum/latest/colors/Spectrum-class.html) | [`SpectrumUtils`](https://pub.dev/documentation/spectrum/latest/colors/SpectrumUtils.html)
/// ###### More:  [`ColorArithmetic` `Shades`](https://pub.dev/documentation/spectrum/latest/gradients/Shades-class.html) | [`StopsArithmetic` `Maths`](https://pub.dev/documentation/spectrum/latest/gradients/Maths-class.html) | [`SwatchMode`](https://pub.dev/documentation/spectrum/latest/colors/SwatchMode-class.html) | [`GradientStoryboard`](https://pub.dev/documentation/spectrum/latest/gradients/AnimatedGradient/storyboard.html) | [`NillGradients`](https://pub.dev/documentation/spectrum/latest/gradients/NillGradients.html) | [`MaterialColorToList`](https://pub.dev/documentation/spectrum/latest/colors/MaterialColorToList.html)
/// ##### [🐸 Zaba.app ― simple packages, simple names.](https://pub.dev/publishers/zaba.app/packages)
library spectrum;

export 'colors.dart';
export 'gradients.dart';

/// Offers an `AnimatedGradient` specification driven by an instantiated
/// `Listenable` (more like `FooTransition` than an `AnimatedFoo`).
///
/// Also provides `Steps` and `ShadedSteps` type gradients.
///
/// Gradient utilities include `copyWith()` many potential properties for a
/// variety of types, but also a `GradientCopyWith` template to override the
/// default in this library, as well as other extension methods.
///
/// `NillGradients` is an extension that maintains the concept of `nillify()`ing
/// a gradient.
///
/// Finally, the origin of `package:spectrum`, the realized `GradientTween`,
/// not just by `Gradient.lerp`, but by bespoke `IntermediateGradient`s.
///
/// ---
/// This import is a module library for `package:spectrum`.
///
/// For `colors` functionality:
///
///     import 'package:spectrum/colors.dart';
///
/// Or for the all-in-one library:
///
///     import 'package:spectrum/spectrum.dart';
///
/// ##### Gradient API References:  [`GradientUtils`](https://pub.dev/documentation/spectrum/latest/spectrum/GradientUtils.html) | [`GradientTween`](https://pub.dev/documentation/spectrum/latest/spectrum/GradientTween-class.html) | [`Steps`](https://pub.dev/documentation/spectrum/latest/spectrum/Steps-class.html) | [`FooShadedSteps`](https://pub.dev/documentation/spectrum/latest/spectrum/RadialShadedSteps-class.html) | [`AnimatedGradient`](https://pub.dev/documentation/spectrum/latest/spectrum/AnimatedGradient-class.html)
/// ##### [🐸 Zaba.app ― simple packages, simple names.](https://pub.dev/publishers/zaba.app/packages)
library gradients;

export 'src/gradients/animation.dart';
export 'src/gradients/interpolation.dart'; // testing
export 'src/gradients/models.dart';
export 'src/gradients/nill.dart';
export 'src/gradients/steps/shaded.dart';
export 'src/gradients/steps/steps.dart';
export 'src/gradients/tween.dart';
export 'src/gradients/utils.dart';

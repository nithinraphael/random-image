import 'dart:async';
import 'dart:ui';
import 'package:aurora/api/api.dart';
import 'package:aurora/models/all.dart';
import 'package:aurora/signals/theme.dart';
import 'package:aurora/widgets/basic/all.dart';
import 'package:aurora/widgets/basic/bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:signals/signals_flutter.dart';

const kSize = 340.0;
const kCardRadius = 24.0;
const kAnimDuration = Duration(milliseconds: 1000);

class _ImageCard extends StatelessWidget {
  final String url;
  const _ImageCard(this.url);

  @override
  Widget build(BuildContext context) {
    // TODO this placeholder does not really exist
    final fallback = const AssetImage('assets/r.png');
    final radius = BorderRadius.circular(kCardRadius);

    return Semantics(
      label: 'Resume image',
      image: true,
      child: RepaintBoundary(
        child: Card(
          elevation: 10,
          shadowColor: Colors.black45,
          shape: RoundedRectangleBorder(borderRadius: radius),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: 0.7,
                child: Transform.scale(
                  scale: 1.5,
                  child: SizedBox(
                    width: kSize,
                    height: kSize,
                    child: ClipRSuperellipse(
                      borderRadius: radius,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          BFadeInImageFallback.withImageFallback(
                            key: ValueKey('${url}_bg'),
                            fit: BoxFit.cover,
                            url: url,
                            fallBackImage: fallback,
                          ),
                          if (theme$.value == ThemeMode.dark)
                            Container(
                              color: Colors.black.withValues(alpha: 0.6),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                  child: const SizedBox.expand(),
                ),
              ),
              SizedBox(
                width: kSize,
                height: kSize,
                child: ClipRSuperellipse(
                  borderRadius: radius,
                  child: BFadeInImageFallback.withImageFallback(
                    key: ValueKey(url),
                    fit: BoxFit.cover,
                    url: url,
                    fallBackImage: fallback,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends HookWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final front = useState<String?>(null);
    final back = useState<String?>(null);
    final loading = useState(false);
    final ctrl = useAnimationController(duration: kAnimDuration);

    final anims = useMemoized(() {
      final curve = CurvedAnimation(parent: ctrl, curve: Curves.easeInOutCubic);
      return (
        fall: Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0, 1000),
        ).animate(CurvedAnimation(parent: ctrl, curve: Curves.easeInBack)),
        rot: Tween<double>(
          begin: 0.0,
          end: 0.15,
        ).animate(CurvedAnimation(parent: ctrl, curve: Curves.easeInCubic)),
        scaleF: Tween<double>(begin: 1.0, end: 0.9).animate(curve),
        scaleB: Tween<double>(
          begin: 0.85,
        ).animate(CurvedAnimation(parent: ctrl, curve: Curves.easeOutBack)),
        fadeB: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: ctrl,
            curve: const Interval(0.1, 0.8, curve: Curves.easeOutQuad),
          ),
        ),
      );
    }, [ctrl]);

    Future<void> fetchNext() async {
      if (loading.value) return;
      loading.value = true;

      final res = await Api.getRandomImage();

      if (res.isErr) {
        loading.value = false;
        showBSnackbar(res.e.message);
        return;
      }

      final newUrl = res.v;

      if (front.value == null) {
        front.value = newUrl;
      } else {
        back.value = newUrl;
        await ctrl.forward(from: 0.0);
        front.value = back.value;
        back.value = null;
        ctrl.reset();
      }
      loading.value = false;
    }

    useEffect(() {
      fetchNext();
      return null;
    }, const []);

    return Scaffold(
      bottomNavigationBar: BBottomNavigatorWrapper(
        child: BButton.dynamicWB(
          context: context,
          text: 'Another one',
          onPressed: fetchNext,
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Semantics(
                container: true,
                label: 'Resume image area',
                child: SizedBox(
                  width: kSize,
                  height: kSize,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      if (front.value == null && back.value != null)
                        AnimatedBuilder(
                          animation: ctrl,
                          builder: (_, child) => Opacity(
                            opacity: anims.fadeB.value,
                            child: Transform.scale(
                              scale: anims.scaleB.value,
                              child: child,
                            ),
                          ),
                          child: _ImageCard(back.value!),
                        ),
                      if (front.value != null)
                        AnimatedBuilder(
                          animation: ctrl,
                          builder: (_, __) => Transform.translate(
                            offset: anims.fall.value,
                            child: Transform.rotate(
                              angle: anims.rot.value,
                              child: Transform.scale(
                                scale: anims.scaleF.value,
                                child: Stack(
                                  children: [
                                    _ImageCard(front.value!),
                                    if (loading.value)
                                      const Positioned(
                                        bottom: 10,
                                        left: 20,
                                        child: _Loader(),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (loading.value && front.value == null)
                        const Positioned.fill(child: Center(child: _Loader())),
                    ],
                  ),
                ),
              ),
            ),
            const Positioned(top: 10, right: 20, child: _ThemeSwitcher()),
            Positioned(
              top: 0,
              left: 10,
              child: SizedBox(
                width: 100,
                height: 100,
                child: Semantics(
                  button: true,
                  label: 'Show welcome sheet',
                  child: BZoomTap(
                    onTap: () => BWelcomeSheet.showSheet(context),
                    child: BFadeInAssetImage(
                      image: const AssetImage('assets/icons/i.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeSwitcher extends HookWidget {
  const _ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return Watch.builder(
      builder: (context) {
        final isDark = theme$.value == ThemeMode.dark;
        final icon = isDark
            ? const AssetImage('assets/icons/sun.png')
            : const AssetImage('assets/icons/moon.png');
        return Semantics(
          button: true,
          label: isDark ? 'Switch to light mode' : 'Switch to dark mode',
          child: BZoomTap(
            onTap: () {
              theme$.value = isDark ? ThemeMode.light : ThemeMode.dark;
            },
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, anim) => AnimatedBuilder(
                animation: anim,
                builder: (context, child) => Transform.scale(
                  scale: 0.8 + 0.2 * anim.value,
                  child: Transform.rotate(
                    angle: (1 - anim.value) * 0.5 * (isDark ? -1 : 1),
                    child: Opacity(
                      opacity: anim.value.clamp(0.0, 1.0),
                      child: child,
                    ),
                  ),
                ),
                child: child,
              ),
              child: SizedBox(
                key: ValueKey(isDark),
                width: 75,
                height: 75,
                child: BFadeInAssetImage(image: icon, fit: BoxFit.contain),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Loader extends StatelessWidget {
  const _Loader();
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Loading',
    child: LoadingAnimationWidget.waveDots(color: Colors.white, size: 50),
  );
}

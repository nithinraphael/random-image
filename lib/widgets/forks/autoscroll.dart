/*
IMPORTANT: This is a fork of the original package with some modification, code quality is not guaranteed.
https://pub.dev/packages/scroll_loop_auto_scroll, MIT License
*/

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ScrollLoopAutoScroll extends HookWidget {
  const ScrollLoopAutoScroll({
    super.key,
    required this.child,
    required this.scrollDirection,
    this.speed = 30, // pixels per second, default slower than before
    this.gap = 25,
    this.reverseScroll = false,
    this.duplicateChild = 25,
    this.enableScrollInput = true,
    this.delay = const Duration(seconds: 1),
    this.delayAfterScrollInput = const Duration(seconds: 1),
  });

  final Widget child;
  final Axis scrollDirection;
  final double speed; // pixels per second
  final double gap;
  final bool reverseScroll;
  final int duplicateChild;
  final bool enableScrollInput;
  final Duration delay;
  final Duration delayAfterScrollInput;

  @override
  Widget build(BuildContext context) {
    final scrollController = useScrollController();
    final animationController = useAnimationController();
    final shouldScroll = useState(false);
    final totalDistance = useState<double?>(null);

    // Measure child size & calculate duration based on speed
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!scrollController.hasClients) return;

        final renderBox =
            scrollController.position.context.storageContext.findRenderObject()
                as RenderBox?;
        if (renderBox == null) return;

        final size = renderBox.size;
        final double distance =
            (scrollDirection == Axis.horizontal ? size.width : size.height) *
            duplicateChild;

        totalDistance.value = distance;

        if (distance > 0 && speed > 0) {
          final durationSeconds = distance / speed;
          animationController.duration = Duration(
            milliseconds: (durationSeconds * 1000).round(),
          );

          animationController.forward();
          shouldScroll.value = true;
        }
      });

      return null;
    }, [scrollController, scrollDirection, duplicateChild, speed]);

    final offset = useMemoized(() {
      final dx = scrollDirection == Axis.horizontal
          ? (reverseScroll ? 0.5 : -0.5)
          : 0.0;
      final dy = scrollDirection == Axis.vertical
          ? (reverseScroll ? 0.5 : -0.5)
          : 0.0;

      return Tween<Offset>(begin: Offset.zero, end: Offset(dx, dy)).animate(
        CurvedAnimation(parent: animationController, curve: Curves.linear),
      );
    }, [scrollDirection, reverseScroll]);

    useEffect(() {
      Future<void> onUserScroll() async {
        if (!enableScrollInput) return;

        shouldScroll.value = false;
        animationController.stop();
        await Future<void>.delayed(delayAfterScrollInput);
        if (scrollController.hasClients && context.mounted) {
          await animationController.forward();
          shouldScroll.value = true;
        }
      }

      scrollController.addListener(onUserScroll);

      return () {
        scrollController.removeListener(onUserScroll);
      };
    }, [scrollController, animationController, enableScrollInput]);

    return SingleChildScrollView(
      clipBehavior: Clip.none,
      controller: scrollController,
      scrollDirection: scrollDirection,
      reverse: reverseScroll,
      physics: enableScrollInput
          ? const BouncingScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      child: SlideTransition(
        position: offset,
        child: scrollDirection == Axis.horizontal
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  duplicateChild,
                  (index) => Padding(
                    padding: EdgeInsets.only(
                      left: reverseScroll ? gap : 0,
                      right: !reverseScroll ? gap : 0,
                    ),
                    child: child,
                  ),
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  duplicateChild,
                  (index) => Padding(
                    padding: EdgeInsets.only(
                      top: reverseScroll ? gap : 0,
                      bottom: !reverseScroll ? gap : 0,
                    ),
                    child: child,
                  ),
                ),
              ),
      ),
    );
  }
}

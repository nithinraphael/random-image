// ignore_for_file: unused_element_parameter

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

const _kDebounceMs = 300;

class BZoomTap extends StatelessWidget {
  const BZoomTap({
    super.key,
    required this.child,
    this.onTap,
    this.onDoubleTap,
    this.enableDebounce = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final bool enableDebounce;

  @override
  Widget build(BuildContext context) => _ZoomTapAnimation(
    onTap: onTap,
    onDoubleTap: onDoubleTap,
    enableDebounce: enableDebounce,
    end: 0.95,
    beginDuration: const Duration(milliseconds: 80),
    endDuration: const Duration(milliseconds: 250),
    beginCurve: Curves.easeOutCubic,
    endCurve: Curves.easeInOutBack,
    child: child,
  );
}

class _ZoomTapAnimation extends HookWidget {
  const _ZoomTapAnimation({
    super.key,
    required this.child,
    this.onTap,
    this.onDoubleTap,
    this.begin = 1.0,
    this.end = 0.93,
    this.beginDuration = const Duration(milliseconds: 20),
    this.endDuration = const Duration(milliseconds: 120),
    this.longTapRepeatDuration = const Duration(milliseconds: 100),
    this.beginCurve = Curves.decelerate,
    this.endCurve = Curves.fastOutSlowIn,
    this.onLongTap,
    this.enableLongTapRepeatEvent = false,
    this.enableDebounce = true,
  });

  final Widget child;
  final double begin, end;
  final Duration beginDuration, endDuration, longTapRepeatDuration;
  final VoidCallback? onTap, onLongTap, onDoubleTap;
  final bool enableLongTapRepeatEvent;
  final Curve beginCurve, endCurve;
  final bool enableDebounce;

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: endDuration,
      reverseDuration: beginDuration,
      initialValue: 1,
    );
    final animation = useMemoized(
      () => Tween<double>(begin: end, end: begin).animate(
        CurvedAnimation(
          parent: controller,
          curve: beginCurve,
          reverseCurve: endCurve,
        ),
      ),
      [controller, begin, end, beginCurve, endCurve],
    );
    final isOnTap = useRef(true);
    final lastTap = useRef<DateTime?>(null);

    useEffect(() {
      controller.forward();
      return null;
    }, []);

    Future<void> onLongPress() async {
      await controller.forward();
      onLongTap?.call();
    }

    Future<void> handlePointerDown(_) async {
      isOnTap.value = true;
      await controller.reverse();
      if (enableLongTapRepeatEvent) {
        await Future<void>.delayed(longTapRepeatDuration);
        while (isOnTap.value) {
          await Future.delayed(longTapRepeatDuration, () async {
            (onLongTap ?? onTap)?.call();
          });
        }
      }
    }

    Future<void> handlePointerUp(_) async {
      isOnTap.value = false;
      await controller.forward();
    }

    void handleTap() {
      if (!enableDebounce) return onTap?.call();
      final now = DateTime.now();
      if (lastTap.value != null &&
          now.difference(lastTap.value!).inMilliseconds < _kDebounceMs) {
        return;
      }
      lastTap.value = now;
      onTap?.call();
    }

    void handleDoubleTap() {
      onDoubleTap?.call();
    }

    return GestureDetector(
      onTap: onTap != null ? handleTap : null,
      onDoubleTap: onDoubleTap != null ? handleDoubleTap : null,
      onLongPress: onLongTap != null && !enableLongTapRepeatEvent
          ? onLongPress
          : null,
      child: Listener(
        onPointerDown: handlePointerDown,
        onPointerUp: handlePointerUp,
        child: ScaleTransition(scale: animation, child: child),
      ),
    );
  }
}

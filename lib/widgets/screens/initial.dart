import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:aurora/widgets/all.dart';
import 'package:aurora/config/config.dart' as config;

class SignUpPromo extends HookWidget {
  const SignUpPromo({super.key});

  @override
  Widget build(BuildContext c) {
    final ambience = useAnimationController(
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
    final entrance = useAnimationController(
      duration: const Duration(milliseconds: 1200),
    );
    useEffect(() {
      entrance.forward();
      return null;
    }, []);
    final fadeSlide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: entrance, curve: Curves.easeOutQuint));
    final opacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: entrance, curve: Curves.easeOut));
    final tiltX = useState(0.0);
    final tiltY = useState(0.0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: ambience,
              builder: (_, __) =>
                  CustomPaint(painter: _AmbientLightPainter(ambience.value)),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(color: Colors.white.wAlpha(0.1)),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: opacity,
              child: SlideTransition(
                position: fadeSlide,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MouseRegion(
                      onExit: (_) {
                        tiltX.value = 0;
                        tiltY.value = 0;
                      },
                      onHover: (d) {
                        final s = MediaQuery.of(c).size;
                        tiltX.value =
                            -(((d.position.dy / s.height) * 2 - 1) * 0.1);
                        tiltY.value = ((d.position.dx / s.width) * 2 - 1) * 0.1;
                      },
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 300),
                        builder: (_, __, ___) => Transform(
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateX(tiltX.value)
                            ..rotateY(tiltY.value),
                          alignment: Alignment.center,
                          child: _FloatingImage(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    BRotatingBorderButton(
                      onTap: () => Navigator.pushReplacement(
                        c,
                        MaterialPageRoute(builder: (_) => HomePage()),
                      ),
                      size: 120,
                      borderText: 'AURORA',
                      innerCircleColor: const Color(0xFF1A1A1A),
                      child: const Icon(
                        CupertinoIcons.arrow_right,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingImage extends StatelessWidget {
  @override
  Widget build(BuildContext c) => Container(
    margin: config.Spacing.screenPaddingX,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 50,
          offset: const Offset(0, 30),
          spreadRadius: -10,
        ),
      ],
    ),
    child: BZoomTap(
      onTap: () => Navigator.pushReplacement(
        c,
        MaterialPageRoute(builder: (_) => HomePage()),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: const BFadeInAssetImage(
          image: config.Images.initialScreen,
          fit: BoxFit.cover,
        ),
      ),
    ),
  );
}

class _AmbientLightPainter extends CustomPainter {
  final double progress;
  const _AmbientLightPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint();
    final o1 = Offset(
      size.width * 0.8,
      size.height * 0.2 + 60 * sin(progress * 2 * pi),
    );
    final o2 = Offset(
      size.width * 0.2,
      size.height * 0.8 - 60 * cos(progress * 2 * pi),
    );
    p.shader = RadialGradient(
      colors: [Colors.orangeAccent.withOpacity(0.6), Colors.transparent],
    ).createShader(Rect.fromCircle(center: o1, radius: size.width * 0.8));
    canvas.drawCircle(o1, size.width * 0.8, p);
    p.shader = RadialGradient(
      colors: [Colors.blueAccent.withOpacity(0.5), Colors.transparent],
    ).createShader(Rect.fromCircle(center: o2, radius: size.width * 0.7));
    canvas.drawCircle(o2, size.width * 0.7, p);
  }

  @override
  bool shouldRepaint(covariant _AmbientLightPainter old) =>
      old.progress != progress;
}

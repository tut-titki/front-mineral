import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mineral/core/theme/app_theme.dart';
import 'package:mineral/l10n/ui_localization.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.nextScreen, this.onFinished});

  final Widget nextScreen;
  final VoidCallback? onFinished;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;
  late final Animation<Offset> _logoSlide;
  late final Animation<double> _sloganOpacity;
  late final Animation<Offset> _sloganSlide;
  late final Animation<double> _shine;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.35, curve: Curves.easeOut),
    );
    _scale = Tween<double>(begin: 0.88, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.45, curve: Curves.easeOutCubic),
      ),
    );
    _logoSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0, 0.45, curve: Curves.easeOutCubic),
          ),
        );
    _sloganOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.42, 0.8, curve: Curves.easeOut),
    );
    _sloganSlide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.42, 0.85, curve: Curves.easeOutCubic),
          ),
        );
    _shine = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.25, 0.7, curve: Curves.easeInOutCubic),
    );

    _controller.forward();
    _openNextScreen();
  }

  Future<void> _openNextScreen() async {
    await Future<void>.delayed(const Duration(seconds: 5));
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => widget.nextScreen,
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
    widget.onFinished?.call();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final logo = Image.asset(
      'assets/logo_naryadAi.png',
      width: 380,
      fit: BoxFit.contain,
      semanticLabel: 'НарядAI',
    );
    final slogan = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Text(
        strings(context).appSlogan,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 18,
          height: 1.45,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.15),
              radius: 0.85,
              colors: [Color(0xFFEAF3FF), Colors.white],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (reduceMotion)
                        logo
                      else
                        FadeTransition(
                          opacity: _opacity,
                          child: SlideTransition(
                            position: _logoSlide,
                            child: ScaleTransition(
                              scale: _scale,
                              child: AnimatedBuilder(
                                animation: _shine,
                                child: logo,
                                builder: (context, child) => ShaderMask(
                                  blendMode: BlendMode.srcATop,
                                  shaderCallback: (bounds) {
                                    final x = -3 + 6 * _shine.value;
                                    return LinearGradient(
                                      begin: Alignment(x - 1, -0.4),
                                      end: Alignment(x + 1, 0.4),
                                      colors: const [
                                        Color(0x00FFFFFF),
                                        Color(0x88FFFFFF),
                                        Color(0x00FFFFFF),
                                      ],
                                      stops: const [0.35, 0.5, 0.65],
                                    ).createShader(bounds);
                                  },
                                  child: child,
                                ),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      if (reduceMotion)
                        slogan
                      else
                        FadeTransition(
                          opacity: _sloganOpacity,
                          child: SlideTransition(
                            position: _sloganSlide,
                            child: slogan,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

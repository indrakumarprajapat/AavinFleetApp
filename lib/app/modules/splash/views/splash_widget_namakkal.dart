import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/app_colors.dart';
import '../controllers/splash_controller.dart';
import 'package:lottie/lottie.dart';
enum SplashStep { logo, animation, text }

class SplashViewNamakkal extends StatefulWidget {
  const SplashViewNamakkal({Key? key}) : super(key: key);

  @override
  State<SplashViewNamakkal> createState() => _SplashViewState();
}


class _SplashViewState extends State<SplashViewNamakkal>
    with TickerProviderStateMixin {

  late final SplashController controller;

  SplashStep step = SplashStep.logo;

  late AnimationController _logoController;
  late AnimationController _lottieController;
  late AnimationController _textController;

  late Animation<double> _logoOpacity;
  late Animation<double> _logoTranslate;
  late Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();

    controller = Get.find<SplashController>();

    /// LOGO
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _logoOpacity = Tween(begin: 0.0, end: 1.0).animate(_logoController);
    _logoTranslate = Tween(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOut),
    );

    /// LOTTIE
    _lottieController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    /// TEXT
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _textOpacity = Tween(begin: 0.0, end: 1.0).animate(_textController);

    _startSequence();
  }

  Future<void> _startSequence() async {
    /// STEP 1 – LOGO
    await _logoController.forward();

    /// STEP 2 – LOTTIE (FULL SCREEN)
    setState(() => step = SplashStep.animation);
    await _lottieController.forward();

    /// STEP 3 – TEXT
    setState(() => step = SplashStep.text);
    await _textController.forward();

    /// START EXISTING FLOW
    controller.startSplashFlow();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _lottieController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: _buildStep(),
      ),
    );
  }

  Widget _buildStep() {
    switch (step) {

    /// 1️⃣ LOGO ONLY
      case SplashStep.logo:
        return Center(
          key: const ValueKey('logo'),
          child: AnimatedBuilder(
            animation: _logoController,
            builder: (_, __) {
              return Opacity(
                opacity: _logoOpacity.value,
                child: Transform.translate(
                  offset: Offset(0, _logoTranslate.value),
                  child: Hero(
                    tag: 'aavin_logo',
                    child: Image.asset(
                      'assets/images/tamilnadulogo.png',
                      width: 180,
                    ),
                  ),
                ),
              );
            },
          ),
        );

    /// 2️⃣ LOTTIE FULL SCREEN
      case SplashStep.animation:
        return Center(
          key: const ValueKey('lottie'),
          child: Lottie.asset(
            'assets/lottie/namakkalanimation.json',
            controller: _lottieController,
            fit: BoxFit.cover,
            repeat: false,
          ),
        );

    /// 3️⃣ TEXT ONLY
      case SplashStep.text:
        return Stack(
          key: const ValueKey('text'),
          children: [

            /// CENTER TEXT
            Center(
              child: FadeTransition(
                opacity: _textOpacity,
                child: const Text(
                  'Procure.Ai',
                  style: TextStyle(
                    fontSize: 56,                // BIG
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF00ADD9),
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),

            /// BOTTOM TEXT
            Positioned(
              bottom: 80,                       // SPACE FROM BOTTOM
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _textOpacity,
                child: const Text(
                  'Society. Supply. System.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    // fontWeight: FontWeight.w500,
                    color: Colors.black54,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ],
        );
    }
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final String _selectedLottie;

  @override
  void initState() {
    super.initState();

    // Select a random lottie between the actual one and rocket_man
    final lotties = [
      'assets/lottie/completing_tasks.json',
      'assets/lottie/rocket_man.json',
    ];
    _selectedLottie = lotties[Random().nextInt(lotties.length)];

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);

    _controller.forward();

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8fafc),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Habitus+Faith',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: Color(0xff6366f1),
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: Lottie.asset(_selectedLottie),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Develop',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          letterSpacing: 1,
                          shadows: [
                            const Shadow(
                              offset: Offset(2.0, 2.0),
                              blurRadius: 8.0,
                              color: Colors.black45,
                            ),
                            const Shadow(
                              offset: Offset(0, 0),
                              blurRadius: 15.0,
                              color: Colors.white24,
                            ),
                            Shadow(
                              offset: const Offset(0, 0),
                              blurRadius: 8.0,
                              color: Colors.white.withAlpha(
                                200,
                              ), // Sombra blanca más intensa
                            ),
                          ],
                        ),
                      ),
                      TextSpan(
                        text: '4',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF32CD32),
                          letterSpacing: 1,
                          shadows: [
                            const Shadow(
                              offset: Offset(2.0, 2.0),
                              blurRadius: 4.0,
                              color: Colors.black45,
                            ),
                            const Shadow(
                              offset: Offset(0, 0),
                              blurRadius: 10.0,
                              color: Color(0xFF32CD32),
                            ),
                            Shadow(
                              offset: const Offset(0, 0),
                              blurRadius: 3.0,
                              color: Colors.white.withAlpha(
                                128,
                              ), // Sombra blanca suave
                            ),
                            Shadow(
                              offset: const Offset(0, 0),
                              blurRadius: 7.0,
                              color: Colors.black.withAlpha(
                                100,
                              ), // Sombra oscura sutil igual que en 'God'
                            ),
                          ],
                        ),
                      ),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              Color(0xFFE0B04F), // Dorado claro
                              Color(0xFFB8860B), // Dorado oscuro
                              Color(0xFFE0B04F), // Dorado claro
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: Text(
                            'God',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              letterSpacing: 1.2,
                              shadows: [
                                const Shadow(
                                  offset: Offset(2.0, 2.0),
                                  blurRadius: 3.0,
                                  color: Colors.black45,
                                ),
                                const Shadow(
                                  offset: Offset(0, 0),
                                  blurRadius: 3.0,
                                  color: Color(0xFFFFD700),
                                ),
                                Shadow(
                                  offset: const Offset(0, 0),
                                  blurRadius: 3.0,
                                  color: Colors.black.withAlpha(
                                    100,
                                  ), // Sombra oscura más sutil
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

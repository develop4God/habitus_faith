import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 7), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });
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
                SizedBox(
                  height: 220,
                  child: Lottie.asset('assets/lottie/completing_tasks.json'),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Habitus+Faith',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: Color(0xff6366f1), // tono más espiritual
                    fontFamily: 'Montserrat', // fuente moderna y amigable
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 64, // Un poco más arriba
            left: 0,
            right: 0,
            child: Center(
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    colors: [Color(0xff6366f1), Color(0xffa5b4fc)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds);
                },
                blendMode: BlendMode.srcIn,
                child: const Text(
                  'Develop4God',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    fontFamily: 'Montserrat', // Fuente moderna y agradable
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

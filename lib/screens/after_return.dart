import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AfterReturnScreen extends StatefulWidget {
  const AfterReturnScreen({super.key});

  @override
  State<AfterReturnScreen> createState() => _AfterReturnScreenState();
}

class _AfterReturnScreenState extends State<AfterReturnScreen> {
  bool showExtras = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) context.go('/');
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          showExtras = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const redColor = Color.fromARGB(255, 255, 73, 73);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'selected-slot',
              child: Image.asset(
                'assets/locked.gif',
                width: 300,
                height: 300,
              ),
            ),
            const SizedBox(height: 30),
            const Hero(
              tag: 'return-title',
              child: Material(
                color: Colors.transparent,
                child: Text(
                  '반납이 완료되었습니다',
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 30),
            AnimatedOpacity(
              opacity: showExtras ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 700),
              child: Column(
                children: [
                  SizedBox(
                    height: 80,
                    width: 80,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(seconds: 10),
                      builder: (context, progress, child) {
                        return CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 6,
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            redColor,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => context.go('/'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: redColor,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.fromLTRB(0, 5, 0, 10),
                      child: Text(
                        '홈으로',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AfterRentScreen extends StatefulWidget {
  const AfterRentScreen({super.key});

  @override
  State<AfterRentScreen> createState() => _AfterRentScreenState();
}

class _AfterRentScreenState extends State<AfterRentScreen> {
  bool showExtras = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) context.go('/');
    });

    // ⏳ 1초 후 인디케이터 + 버튼 서서히 등장
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          showExtras = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'selected-slot',
              child: Image.asset(
                'assets/unlocked.gif',
                width: 300,
                height: 300,
              ),
            ),
            const SizedBox(height: 30),
            const Hero(
              tag: 'rent-title',
              child: Material(
                color: Colors.transparent,
                child: Text(
                  '잠금이 해제되었습니다',
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
                      duration: const Duration(seconds: 10), // ⏱️ 10초로 변경
                      builder: (context, progress, child) {
                        return CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 6,
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF73BE76), // ✅ 버튼과 동일한 색상
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => context.go('/'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF73BE76), // ✅ 일치
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

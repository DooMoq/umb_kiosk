import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StandbyScreen extends StatelessWidget {
  const StandbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFEFF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // GIF 이미지 클릭 시 /rent 이동
            GestureDetector(
              onTap: () => context.go('/rent'),
              child: Image.asset(
                'assets/main.gif',
                width: 600,
                height: 600,
              ),
            ),
            const SizedBox(height: 20),
            // 텍스트 클릭 시 /drying 이동
            GestureDetector(
              onTap: () => context.go('/drying'),
              child: const Text(
                '이용하시려면 태그해주세요',
                style: TextStyle(fontSize: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StandbyScreen extends StatefulWidget {
  const StandbyScreen({super.key});

  @override
  State<StandbyScreen> createState() => _StandbyScreenState();
}

class _StandbyScreenState extends State<StandbyScreen> {
  @override
  void initState() {
    super.initState();
    turnOffAllLeds(); // 화면 진입 시 모든 LED OFF 요청
  }

  Future<void> turnOffAllLeds() async {
    try {
      final response = await http.post(
        Uri.parse('http://YOUR_SERVER_IP:5000/slot'), // ← 서버 주소 수정 필요
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'slot': -1}),
      );
      if (response.statusCode == 200) {
        print('✅ 모든 LED OFF 요청 성공');
      } else {
        print('❌ LED OFF 요청 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 예외 발생: $e');
    }
  }

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

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
    turnOffAllLeds(); // ✅ LED OFF
    turnOffAllRelays(); // ✅ 릴레이 OFF
  }

  Future<void> turnOffAllLeds() async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/slot'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'led': -1, 'relay': -1}), // ✅ 구조 변경
      );
      if (response.statusCode == 200) {
        print('✅ 모든 LED OFF 요청 성공');
      } else {
        print('❌ LED OFF 요청 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ LED OFF 예외 발생: $e');
    }
  }

  Future<void> turnOffAllRelays() async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/relay_off'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        print('✅ 릴레이 전체 OFF 요청 성공');
      } else {
        print('❌ 릴레이 OFF 요청 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 릴레이 OFF 예외 발생: $e');
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
            GestureDetector(
              onTap: () => context.go('/rent'),
              child: Image.asset(
                'assets/main.gif',
                width: 600,
                height: 600,
              ),
            ),
            const SizedBox(height: 20),
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

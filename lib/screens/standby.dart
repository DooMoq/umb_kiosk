import 'package:display/tilt.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'dart:convert';

class StandbyScreen extends StatefulWidget {
  const StandbyScreen({super.key});

  @override
  State<StandbyScreen> createState() => _StandbyScreenState();
}

class _StandbyScreenState extends State<StandbyScreen> {
  late WebSocketChannel _channel;

  @override
  void initState() {
    super.initState();
    turnOffAllLeds(); // ✅ LED OFF
    turnOffAllRelays(); // ✅ 릴레이 OFF
    _connectWebSocket(); // ✅ 웹소켓 연결
  }

  void _connectWebSocket() {
    _channel = WebSocketChannel.connect(
      Uri.parse(
          'ws://121.124.228.202:10000/ws/locker-updates?lockerId=A01'), // ✅ WebSocket 서버 주소 (수정 가능)
    );

    _channel.stream.listen(
      (message) {
        print('📩 WebSocket 수신 메시지: $message');

        if (message == 'rent') {
          context.go('/rent');
        } else if (message == 'return') {
          context.go('/drying');
        }
      },
      onDone: () => print('🛑 WebSocket 연결 종료'),
      onError: (error) => print('❌ WebSocket 오류 발생: $error'),
    );
  }

  @override
  void dispose() {
    _channel.sink.close(status.normalClosure);
    super.dispose();
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
      backgroundColor: Colors.white,
      body: Transform.translate(
        offset: const Offset(0, 100),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => context.go('/rent'),
                child: Transform.translate(
                  offset: const Offset(0, -100),
                  child: Transform.scale(
                    scale: 2,
                    child: const TiltingPhoneIcon(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => context.go('/drying'),
                child: const Text(
                  '이용하시려면 태그해주세요',
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReturnScreen extends StatefulWidget {
  const ReturnScreen({super.key});

  @override
  State<ReturnScreen> createState() => _ReturnScreenState();
}

class _ReturnScreenState extends State<ReturnScreen> {
  int? selectedSlot;

  Future<void> sendSlotToServer(int slot) async {
    final url = Uri.parse('http://localhost:5000/slot');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'slot': slot + 44}), // 🔴 +44로 보냄
      );
      if (response.statusCode == 200) {
        print('[RETURN] 서버 전송 성공: 슬롯 $slot (+44)');
      } else {
        print('[RETURN] 서버 전송 실패: ${response.body}');
      }
    } catch (e) {
      print('[RETURN] 서버 요청 오류: $e');
    }
  }

  void handleReturn() {
    if (selectedSlot != null) {
      sendSlotToServer(selectedSlot!);
      context.go('/after_return');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(400, 30, 400, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const Center(
              child: Hero(
                tag: 'return-title',
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    '반납할 우산 슬롯을 선택해주세요',
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: selectedSlot != null ? handleReturn : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedSlot != null
                    ? const Color.fromARGB(255, 255, 73, 73)
                    : Colors.green[200],
              ),
              child: const Padding(
                padding: EdgeInsets.fromLTRB(0, 5, 0, 10),
                child: Text(
                  '반납',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                itemCount: 45,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 16 / 9,
                ),
                itemBuilder: (context, index) {
                  if (index == 4) return const SizedBox.shrink();
                  int visibleIndex = index > 4 ? index - 1 : index;
                  int displayNumber = visibleIndex + 1;
                  final isSelected = selectedSlot == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedSlot = index;
                      });
                    },
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double fontSize = constraints.maxWidth * 0.15;
                        final slot =
                            buildSlot(displayNumber, fontSize, isSelected);
                        return isSelected
                            ? Hero(tag: 'selected-slot', child: slot)
                            : slot;
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSlot(int displayNumber, double fontSize, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 197, 197, 197),
          border: isSelected ? Border.all(color: Colors.black, width: 3) : null,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Stack(
          children: [
            Positioned(
              right: 6,
              bottom: 4,
              child: Padding(
                padding: const EdgeInsets.all(7.0),
                child: Text(
                  '$displayNumber',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RentScreen extends StatefulWidget {
  const RentScreen({super.key});

  @override
  State<RentScreen> createState() => _RentScreenState();
}

class _RentScreenState extends State<RentScreen> {
  int? selectedSlot;

  Future<void> sendSlotIndex(int index) async {
    try {
      final res = await http.post(
        Uri.parse('http://localhost:5000/slot'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'slot': index}),
      );
      if (res.statusCode != 200) {
        print('Flask 서버 오류: ${res.body}');
      }
    } catch (e) {
      print('Flask 서버 통신 실패: $e');
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
                tag: 'rent-title',
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    '대여할 우산 슬롯을 선택해주세요',
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
              onPressed:
                  selectedSlot != null ? () => context.go('/after_rent') : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedSlot != null
                    ? const Color(0xFF73BE76)
                    : Colors.green[200],
              ),
              child: const Padding(
                padding: EdgeInsets.fromLTRB(0, 5, 0, 10),
                child: Text(
                  '대여',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
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
                  if (index == 4) {
                    return const SizedBox.shrink();
                  }

                  int visibleIndex = index > 4 ? index - 1 : index;
                  int displayNumber = visibleIndex + 1;
                  final isSelected = selectedSlot == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedSlot = index;
                      });

                      int slotToSend = index > 4 ? index - 1 : index; // ✅ 보정
                      sendSlotIndex(slotToSend); // ✅ 전송
                    },
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double fontSize = constraints.maxWidth * 0.15;
                        final slot = buildSlotContainer(
                            displayNumber, fontSize, isSelected);

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

  Widget buildSlotContainer(
      int displayNumber, double fontSize, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue,
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

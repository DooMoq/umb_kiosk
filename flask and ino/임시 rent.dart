import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

class RentScreen extends StatefulWidget {
  const RentScreen({super.key});

  @override
  State<RentScreen> createState() => _RentScreenState();
}

class _RentScreenState extends State<RentScreen> {
  int? selectedSlot;
  int? relaySlotIndex;
  Set<int> disabledSlots = {};

  @override
  void initState() {
    super.initState();
    generateDisabledSlots();
  }

  void generateDisabledSlots() {
    final List<int> candidates = List.generate(45, (i) => i)
      ..remove(4); // index 4 제거
    candidates.shuffle(Random());
    disabledSlots = candidates.take(20).toSet();
  }

  Future<void> sendSlotData({required int led, required int relay}) async {
    try {
      final res = await http.post(
        Uri.parse('http://localhost:5000/slot'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'led': led, 'relay': relay}),
      );
      if (res.statusCode != 200) {
        print('Flask 서버 오류: ${res.body}');
      }
    } catch (e) {
      print('Flask 서버 통신 실패: $e');
    }
  }

  Future<void> unlockSlot() async {
    if (relaySlotIndex == null) return;
    try {
      final res = await http.post(
        Uri.parse('http://localhost:5000/unlock'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'relay': relaySlotIndex}),
      );
      if (res.statusCode != 200) {
        print('릴레이 제어 실패: ${res.body}');
      }
    } catch (e) {
      print('릴레이 전송 에러: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          const int columns = 5;
          const int totalSlots = 44;
          const double spacing = 12;
          int rows = (totalSlots / columns).ceil();

          double maxGridHeight = constraints.maxHeight - 260;
          double slotSize = (maxGridHeight - spacing * (rows - 1)) / rows;
          double totalGridWidth = slotSize * columns + spacing * (columns - 1);

          return Center(
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Hero(
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
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: selectedSlot != null
                      ? () async {
                          await unlockSlot();
                          context.go('/after_rent');
                        }
                      : null,
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
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Center(
                    child: SizedBox(
                      width: totalGridWidth,
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: 45,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: spacing,
                          mainAxisSpacing: spacing,
                          childAspectRatio: 1.0,
                        ),
                        itemBuilder: (context, index) {
                          if (index == 4) return const SizedBox.shrink();

                          final isDisabled = disabledSlots.contains(index);
                          final isSelected = selectedSlot == index;
                          int visibleIndex = index > 4 ? index - 1 : index;
                          int displayNumber = visibleIndex + 1;

                          final slotWidget = Container(
                            width: slotSize,
                            height: slotSize,
                            decoration: BoxDecoration(
                              color: isDisabled
                                  ? const Color.fromARGB(255, 199, 199, 199)
                                  : const Color(0xFF73BE76),
                              border: isSelected && !isDisabled
                                  ? Border.all(color: Colors.black, width: 3)
                                  : null,
                              borderRadius: BorderRadius.circular(15),
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
                                        fontSize: slotSize * 0.25,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );

                          return GestureDetector(
                            onTap: () {
                              if (isDisabled) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      '다른 슬롯을 선택해주세요',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                return;
                              }

                              setState(() {
                                selectedSlot = index;
                              });
                              int ledIndex = index > 4 ? index - 1 : index;
                              int relayIndex = ledIndex + 1;
                              relaySlotIndex = relayIndex;

                              sendSlotData(led: ledIndex, relay: relayIndex);
                            },
                            child: isSelected && !isDisabled
                                ? Hero(tag: 'selected-slot', child: slotWidget)
                                : slotWidget,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

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
  Set<int> occupiedSet = {}; // 사용 중인 슬롯 번호들 (1부터 시작)

  @override
  void initState() {
    super.initState();
    fetchOccupiedSlots();
  }

  Future<void> fetchOccupiedSlots() async {
    try {
      final res = await http.get(
        Uri.parse(
            'http://121.124.228.202:10000/umbrella/rent/slots?lockerId=lockerA'),
      );
      if (res.statusCode == 200) {
        final List<dynamic> occupied = json.decode(res.body);
        setState(() {
          occupiedSet = occupied.cast<int>().toSet(); // displayNumber 기준
        });
      } else {
        print('[RETURN] 사용 중 슬롯 불러오기 실패: ${res.body}');
      }
    } catch (e) {
      print('[RETURN] 슬롯 정보 요청 실패: $e');
    }
  }

  Future<void> sendSlotIndex(int index) async {
    try {
      final res = await http.post(
        Uri.parse('http://localhost:5000/slot'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'led': index + 44, 'relay': -1}),
      );
      if (res.statusCode != 200) {
        print('[RETURN] 서버 오류: ${res.body}');
      }
    } catch (e) {
      print('[RETURN] 서버 통신 실패: $e');
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
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: selectedSlot != null
                      ? () => context.go('/after_return')
                      : null,
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

                          int slotNumber = index > 4 ? index - 1 : index;
                          int displayNumber = slotNumber + 1;

                          final isDisabled =
                              occupiedSet.contains(displayNumber);
                          final isSelected = selectedSlot == index;

                          final slotWidget = Container(
                            width: slotSize,
                            height: slotSize,
                            decoration: BoxDecoration(
                              color: isDisabled
                                  ? const Color.fromARGB(255, 199, 199, 199)
                                  : const Color.fromARGB(255, 255, 73, 73),
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
                                      '비어 있는 슬롯만 선택해주세요',
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

                              int slotToSend = slotNumber;
                              sendSlotIndex(slotToSend);
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

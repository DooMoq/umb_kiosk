import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DryingScreen extends StatefulWidget {
  const DryingScreen({super.key});

  @override
  State<DryingScreen> createState() => _DryingScreenState();
}

enum DryingState { idle, drying, done }

class _DryingScreenState extends State<DryingScreen> {
  DryingState dryingState = DryingState.idle;

  void startDrying() {
    setState(() {
      dryingState = DryingState.drying;
    });
  }

  @override
  Widget build(BuildContext context) {
    String titleText;
    switch (dryingState) {
      case DryingState.idle:
        titleText = '건조를 위해 건조 슬롯에 우산을 삽입해주세요';
        break;
      case DryingState.drying:
        titleText = '건조 중...';
        break;
      case DryingState.done:
        titleText = '건조 완료';
        break;
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(400, 30, 400, 30),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Text(
                titleText,
                style: const TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              if (dryingState == DryingState.idle)
                ElevatedButton(
                  onPressed: startDrying,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0099E5),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(0, 5, 0, 10),
                    child: Text(
                      '건조',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              if (dryingState == DryingState.drying)
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(seconds: 10),
                  onEnd: () => setState(() => dryingState = DryingState.done),
                  builder: (context, progress, child) {
                    return SizedBox(
                      height: 400,
                      width: 400,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/wind.gif',
                            height: 200,
                            width: 200,
                          ),
                          SizedBox(
                            height: 320,
                            width: 320,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 8,
                              backgroundColor: Colors.grey[300],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              if (dryingState == DryingState.done)
                ElevatedButton(
                  onPressed: () {
                    context.go('/return'); // ✅ 반납 슬롯 선택 페이지로 이동
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 73, 73),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(0, 5, 0, 10),
                    child: Text(
                      '반납 슬롯 선택',
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
      ),
    );
  }
}

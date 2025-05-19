const int relayPins[8] = {13, 12, 11, 10, 9, 8, 7, 6};

void setup() {
  for (int i = 0; i < 8; i++) {
    pinMode(relayPins[i], OUTPUT);
    digitalWrite(relayPins[i], HIGH); // 초기 상태: 잠금 (HIGH)
  }

  Serial.begin(9600);
  while (!Serial); // USB 연결 안정화 대기
}

void loop() {
  if (Serial.available()) {
    String input = Serial.readStringUntil('\n');
    input.trim();

    if (input == "ALL_OFF") {
      for (int i = 0; i < 8; i++) {
        digitalWrite(relayPins[i], HIGH);
      }
      Serial.println("[GIGA] ALL_OFF: 모든 릴레이 HIGH");
    } else {
      int relayIndex = input.toInt();  // 1~8
      if (relayIndex >= 1 && relayIndex <= 8) {
        digitalWrite(relayPins[relayIndex - 1], LOW);
        Serial.print("[GIGA] 릴레이 ");
        Serial.print(relayIndex);
        Serial.println(" → LOW (잠금 해제)");
      } else {
        Serial.print("[GIGA] 잘못된 입력: ");
        Serial.println(input);
      }
    }
  }
}

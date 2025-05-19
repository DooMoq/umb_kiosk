from flask import Flask, request, jsonify
from flask_cors import CORS
import serial
import time

app = Flask(__name__)
CORS(app)

# RPi ↔︎ LED 제어용 아두이노 (ttyACM0)
try:
    ser = serial.Serial('/dev/ttyACM0', 9600, timeout=1)
    time.sleep(2)
except serial.SerialException as e:
    ser = None
    print(f"[ERROR] 시리얼 연결 실패: {e}")

# ✅ Giga (릴레이 제어용) 연결 함수
def send_to_giga(command: str):
    try:
        with serial.Serial('/dev/ttyACM1', 9600, timeout=1) as giga:
            time.sleep(2)
            giga.write(f"{command}\n".encode())
            giga.flush()
            print(f"[GIGA] '{command}' 명령 전송됨")
    except Exception as e:
        print(f"[ERROR] Giga 전송 실패: {e}")

# ✅ 마지막 선택된 슬롯 저장 변수
last_selected_slot = None

@app.route('/slot', methods=['POST'])
def handle_slot():
    global last_selected_slot
    data = request.get_json()
    slot = data.get('slot')

    if slot is None or not isinstance(slot, int):
        return jsonify({'error': 'Invalid slot type'}), 400

    if ser is None:
        return jsonify({'error': 'Serial not connected'}), 500

    try:
        # ✅ 선택 슬롯 저장 (릴레이 제어용)
        last_selected_slot = slot

        if slot == -1:
            ser.write(b"ALL_OFF\n")
            print("[INFO] 모든 LED OFF 전송됨")
        elif 0 <= slot <= 87:
            encoded = f"{slot}\n".encode()
            repeat = 10 if 68 <= slot <= 77 else 1

            for _ in range(repeat):
                ser.write(encoded)
                ser.flush()
                time.sleep(0.01)

            print(f"[INFO] 슬롯 {slot} 전송됨 ({repeat}회)")
        else:
            return jsonify({'error': 'Invalid slot range'}), 400

        return jsonify({'status': 'ok'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# ✅ 릴레이 잠금 해제용 unlock 엔드포인트
@app.route('/unlock', methods=['POST'])
def handle_unlock():
    global last_selected_slot
    if last_selected_slot is None or not (1 <= last_selected_slot <= 8):
        return jsonify({'error': 'No valid slot selected'}), 400

    try:
        send_to_giga(str(last_selected_slot))  # 해당 릴레이만 LOW
        return jsonify({'status': 'ok'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# ✅ standby 진입 시 전체 릴레이 OFF
@app.route('/relay_off', methods=['POST'])
def handle_relay_off():
    try:
        send_to_giga("ALL_OFF")  # 전체 HIGH
        return jsonify({'status': 'ok'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

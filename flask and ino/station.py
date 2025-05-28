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

@app.route('/slot', methods=['POST'])
def handle_slot():
    data = request.get_json()
    led_index = data.get('led')
    relay_index = data.get('relay')

    if led_index is None or not isinstance(led_index, int):
        return jsonify({'error': 'Missing or invalid LED index'}), 400
    if relay_index is None or not isinstance(relay_index, int):
        return jsonify({'error': 'Missing or invalid relay index'}), 400

    if ser is None:
        return jsonify({'error': 'Serial not connected'}), 500

    try:
        # 🔹 LED 제어 (UNO)
        if led_index == -1:
            ser.write(b"ALL_OFF\n")
            print("[INFO] 모든 LED OFF 전송됨")
        elif 0 <= led_index <= 88:
            encoded = f"{led_index}\n".encode()
            repeat = 10 if 68 <= led_index <= 77 else 1

            for _ in range(repeat):
                ser.write(encoded)
                ser.flush()
                time.sleep(0.01)

            print(f"[INFO] LED 슬롯 {led_index} 전송됨 ({repeat}회)")
        else:
            return jsonify({'error': 'Invalid LED index range'}), 400

        # 🔹 릴레이 인덱스 저장용 로그만 남김 (전송은 unlock에서 함)
        print(f"[INFO] 릴레이 슬롯 {relay_index} 준비 완료 (저장 X)")

        return jsonify({'status': 'ok'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/unlock', methods=['POST'])
def handle_unlock():
    data = request.get_json()
    relay_index = data.get('relay')

    if relay_index is None or not isinstance(relay_index, int) or not (1 <= relay_index <= 8):
        return jsonify({'error': 'Invalid relay index'}), 400

    try:
        send_to_giga(str(relay_index))
        return jsonify({'status': 'ok'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/relay_off', methods=['POST'])
def handle_relay_off():
    try:
        send_to_giga("ALL_OFF")  # 전체 HIGH
        return jsonify({'status': 'ok'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

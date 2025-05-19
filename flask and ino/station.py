from flask import Flask, request, jsonify
from flask_cors import CORS
import serial
import time

app = Flask(__name__)
CORS(app)  # ✅ 모든 출처(origin)에 대해 CORS 허용

# 아두이노 시리얼 포트 연결
ser = serial.Serial('/dev/ttyACM0', 9600, timeout=1)
time.sleep(2)  # 아두이노 초기화 대기

@app.route('/slot', methods=['POST'])
def handle_slot():
    data = request.get_json()
    slot = data.get('slot')

    if slot is None or not isinstance(slot, int):
        return jsonify({'error': 'Invalid slot type'}), 400

    try:
        if slot == -1:
            # 모든 LED OFF 명령 전송
            ser.write(b"ALL_OFF\n")
            print("[INFO] 모든 LED OFF 전송됨")
        elif 0 <= slot <= 43:
            ser.write(f"{slot}\n".encode())
            print(f"[INFO] 슬롯 {slot} 전송됨 (from /slot)")
        else:
            return jsonify({'error': 'Invalid slot range'}), 400

        return jsonify({'status': 'ok'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

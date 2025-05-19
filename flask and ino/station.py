from flask import Flask, request, jsonify
from flask_cors import CORS
import serial
import time

app = Flask(__name__)
CORS(app)

# 시리얼 포트 연결
try:
    ser = serial.Serial('/dev/ttyACM0', 9600, timeout=1)
    time.sleep(2)
except serial.SerialException as e:
    ser = None
    print(f"[ERROR] 시리얼 연결 실패: {e}")

@app.route('/slot', methods=['POST'])
def handle_slot():
    data = request.get_json()
    slot = data.get('slot')

    if slot is None or not isinstance(slot, int):
        return jsonify({'error': 'Invalid slot type'}), 400

    if ser is None:
        return jsonify({'error': 'Serial not connected'}), 500

    try:
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

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
from flask import Flask, request, jsonify
import firebase_admin
from firebase_admin import credentials, firestore
import requests
import json

app = Flask(__name__)

# Firebase ayarları
cred = credentials.Certificate(r"C:\Users\furkanevzat\fineitune\fineitune-c6fea-firebase-adminsdk-klqyf-98d2bbe4c7.json")
if not firebase_admin._apps:
    firebase_admin.initialize_app(cred)

# Firestore veritabanını başlatma
db = firestore.client()

def convert_to_special_format(system_prompt, user_inputs):
    output = "<|begin_of_text|>"
    output += f'<|start_header_id|>system<|end_header_id|>\n\n{system_prompt}<|eot_id|>'

    for idx, entry in enumerate(user_inputs):
        output += f'\n<|start_header_id|>user<|end_header_id|>\n\n{entry}<|eot_id|>'
        if idx != len(user_inputs) - 1:
            output += f'\n<|start_header_id|>assistant<|end_header_id|>\n\n'

    output += "\n<|start_header_id|>assistant<|end_header_id|>"
    return output

def llm2_invoke(user_inputs):
    if isinstance(user_inputs, str):
        user_inputs = [user_inputs]

    system_prompt = "Sen yardımcı bir asistansın ve sana verilen talimatlar doğrultusunda en iyi cevabı üretmeye çalışacaksın..."

    special_format_output = convert_to_special_format(system_prompt, user_inputs)

    url = "https://inference2.t3ai.org/v1/completions"
    payload = json.dumps({
        "model": "/home/ubuntu/hackathon_model_2/",
        "prompt": special_format_output,
        "temperature": 0.3,
        "top_p": 0.95,
        "max_tokens": 1024,
        "repetition_penalty": 1.1,
        "stop_token_ids": [
            128001,
            128009
        ],
        "skip_special_tokens": True
    })
    headers = {
        'Content-Type': 'application/json',
    }

    try:
        response = requests.post(url, headers=headers, data=payload)
        response.raise_for_status()
        pretty_response = response.json()
        return pretty_response['choices'][0]['text']
    except requests.exceptions.RequestException as e:
        return f"API hatası: {e}"

@app.route('/chat', methods=['POST'])
def chat():
    data = request.json
    user_input = data.get('user_input')

    if not user_input:
        return jsonify({"error": "Lütfen bir mesaj gönderin."}), 400

    model_response = llm2_invoke(user_input)

    # Firebase'e kaydet
    doc_ref = db.collection('chat_sessions').document()
    doc_ref.set({
        'user_input': user_input,
        'response': model_response
    })

    return jsonify({"response": model_response})

if __name__ == "__main__":
    app.run(debug=True)

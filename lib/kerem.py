from flask import Flask, request, jsonify
import firebase_admin
from firebase_admin import credentials, firestore
import requests
import json
from flask_cors import CORS
from utils import convert_to_special_format, llm2_invoke  # Importing functions from utils.py

app = Flask(__name__)
CORS(app, resources={r"/chat": {"origins": "*"}})

# Firebase credentials and initialization
cred = credentials.Certificate(r"C:\Users\furkanevzat\fineitune\fineitune-c6fea-firebase-adminsdk-klqyf-98d2bbe4c7.json")
if not firebase_admin._apps:
    firebase_admin.initialize_app(cred)

# Initialize Firestore database
db = firestore.client()

# Chat API Endpoint
@app.route('/chat', methods=['POST'])
def chat():
    data = request.json
    user_input = data.get('user_input')

    if not user_input:
        return jsonify({"error": "Lütfen bir mesaj gönderin."}), 400

    # Invoke the language model
    model_response = llm2_invoke(user_input)

    # Save the chat session to Firebase Firestore
    doc_ref = db.collection('chat_sessions').document()
    doc_ref.set({
        'user_input': user_input,
        'response': model_response
    })

    # Return the model's response to the client
    return jsonify({"response": model_response})

if __name__ == "__main__":
    app.run(debug=False)

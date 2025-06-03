# -*- coding: latin-1 -*-
import os
import numpy as np
from flask import Flask, request, jsonify
from tensorflow.keras.models import load_model
from PIL import Image
import io

app = Flask(__name__)

# Construye la ruta absoluta al modelo
BASE_DIR = os.path.dirname(os.path.abspath(__file__))  # Carpeta donde est� main.py
MODEL_PATH = os.path.join(BASE_DIR, "modelo_cnn_oreganoV2.h5")

# Umbral ajustable para clasificaci�n binaria
THRESHOLD = 0.5

# Cargar el modelo CNN
try:
    model = load_model(MODEL_PATH)
    print("? Modelo cargado correctamente.")
except Exception as e:
    print(f"? Error al cargar el modelo: {e}")
    raise e

@app.route('/predict', methods=['POST'])
def predict():
    if 'file' not in request.files:
        return jsonify({"error": "No file provided"}), 400

    file = request.files['file']
    if file.filename == '':
        return jsonify({"error": "No selected file"}), 400

    try:
        # Cargar y procesar imagen
        img = Image.open(io.BytesIO(file.read())).convert("RGB")
        img = img.resize((224, 224))  # Ajustar tama�o seg�n modelo
        img_array = np.array(img) / 255.0
        img_array = np.expand_dims(img_array, axis=0)

        # Predicci�n
        prediction = model.predict(img_array)
        proba = float(prediction[0][0])  # Asumimos salida binaria [0..1]

        # Clasificaci�n con umbral
        if proba > THRESHOLD:
            resultado = {
                "clasificacion": "ES OR�GANO",
                "confianza": f"{proba * 100:.2f}%"
            }
        else:
            resultado = {
                "clasificacion": "NO ES OR�GANO",
                "confianza": f"{(1 - proba) * 100:.2f}%"
            }

        return jsonify(resultado)

    except Exception as e:
        return jsonify({"error": str(e)}), 500


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
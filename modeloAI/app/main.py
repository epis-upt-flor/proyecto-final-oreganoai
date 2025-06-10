# -*- coding: latin-1 -*-
import os
import numpy as np
from flask import Flask, request, jsonify
from tensorflow.keras.models import load_model
from PIL import Image
import io

app = Flask(__name__)

# Construye la ruta absoluta al modelo
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH = os.path.join(BASE_DIR, "modelo_cnn_oreganoV2.h5")
DISEASE_MODEL_PATH = os.path.join(BASE_DIR, "modelo_cnn_oregano_ligero.keras")
DISEASE_CLASS_NAMES = ['ALTERNARIA', 'OIDIO', 'OREGANO SANO', 'ROYA']

# Umbral ajustable para clasificación binaria
THRESHOLD = 0.5

# Cargar el modelo CNN
try:
    model = load_model(MODEL_PATH)
    print("Modelo cargado correctamente.")
except Exception as e:
    print(f"Error al cargar el modelo: {e}")
    raise e

@app.route('/predict', methods=['POST'])
def predict():
    # Verificar si se proporcionó un archivo
    if 'file' not in request.files:
        return jsonify({"error": "No file provided"}), 400

    file = request.files['file']
    if file.filename == '':
        return jsonify({"error": "No selected file"}), 400

    try:
        # Procesar la imagen
        img = Image.open(file).convert('RGB')
        img = img.resize((224, 224))  # Ajusta al tamaño esperado por el modelo
        img_array = np.array(img) / 255.0  # Normalizar
        img_array = np.expand_dims(img_array, axis=0)  # Añadir dimensión para batch

        # Predicción del modelo binario (¿es orégano?)
        proba = model.predict(img_array)[0][0]
        is_oregano = proba >= THRESHOLD
        resultado = {
            "clasificacion": "ORÉGANO" if is_oregano else "NO ES ORÉGANO",
            "confianza": f"{proba * 100:.2f}%" if is_oregano else f"{(1 - proba) * 100:.2f}%"
        }

        # Si es orégano, proceder con la detección de enfermedades
        if is_oregano:
            try:
                disease_model = load_model(DISEASE_MODEL_PATH)
                disease_pred = disease_model.predict(img_array)
                disease_idx = int(np.argmax(disease_pred))
                disease_conf = float(np.max(disease_pred))

                if disease_idx < 0 or disease_idx >= len(DISEASE_CLASS_NAMES):
                    resultado["plaga"] = "Advertencia: El modelo de enfermedades predijo una clase fuera de rango."
                else:
                    resultado["plaga"] = f"Enfermedad detectada: {DISEASE_CLASS_NAMES[disease_idx]} (Confianza: {disease_conf * 100:.2f}%)"
            except FileNotFoundError:
                resultado["plaga"] = f"Error: El archivo del modelo de detección de enfermedades no se encontró en '{DISEASE_MODEL_PATH}'."
            except ImportError:
                resultado["plaga"] = "Error al cargar el modelo de detección de enfermedades: Asegúrate de que TensorFlow/Keras estén instalados y sean compatibles."
            except ValueError as e:
                resultado["plaga"] = f"Error de valor al cargar el modelo de detección de enfermedades (posiblemente un archivo corrupto o formato incorrecto): {e}"
            except Exception as e:
                resultado["plaga"] = f"Error inesperado al cargar el modelo de detección de enfermedades: {e}"

        return jsonify(resultado)

    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

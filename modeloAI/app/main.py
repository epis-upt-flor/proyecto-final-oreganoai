# -*- coding: latin-1 -*-
import os
import numpy as np
from flask import Flask, request, jsonify
from tensorflow.keras.models import load_model
from PIL import Image
import io

# Importar YOLO de ultralytics
from ultralytics import YOLO

app = Flask(__name__)

# --- Rutas a los modelos ---
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# Ruta al modelo YOLO (debe ser .pt)
YOLO_MODEL_PATH = os.path.join(BASE_DIR, "ModeloDetectorEnfermedadesYOLO.pt")

# Ruta al modelo de clasificación de enfermedades (Keras .h5)
DISEASE_MODEL_PATH = os.path.join(BASE_DIR, "modelo_cnn_oreganoV2.h5")
DISEASE_CLASS_NAMES = ['ALTERNARIA', 'MOSAICO', 'OIDIO', 'ROYA']

# --- Cargar los modelos ---
yolo_model = None
disease_model = None
OREGANO_CLASS_ID = -1

try:
    # Especificar explícitamente la tarea como 'detect'
    yolo_model = YOLO(YOLO_MODEL_PATH, task='detect', verbose=False)
    if 'oregano' in yolo_model.names.values():
        for k, v in yolo_model.names.items():
            if v == 'oregano':
                OREGANO_CLASS_ID = k
                break
    print(f"Modelo YOLO cargado correctamente desde: {YOLO_MODEL_PATH}")
    if OREGANO_CLASS_ID == -1:
        print("Advertencia: La clase 'oregano' no se encontró en las etiquetas del modelo YOLO.")
except Exception as e:
    print(f"Error al cargar el modelo YOLO: {e}")
    exit(1)

try:
    disease_model = load_model(DISEASE_MODEL_PATH)
    print(f"Modelo de clasificación de enfermedades cargado correctamente desde: {DISEASE_MODEL_PATH}")
except Exception as e:
    print(f"Error al cargar el modelo de clasificación de enfermedades: {e}")
    disease_model = None

# --- Parámetros de Inferencia ---
YOLO_CONF_THRESHOLD = 0.5
DISEASE_MODEL_IMG_SIZE = (224, 224)

@app.route('/predict', methods=['POST'])
def predict():
    if 'file' not in request.files:
        return jsonify({"error": "No file provided"}), 400

    file = request.files['file']
    if file.filename == '':
        return jsonify({"error": "No selected file"}), 400

    try:
        # Leer la imagen
        img_pil = Image.open(io.BytesIO(file.read())).convert('RGB')
        
        # 1. Ejecutar el modelo YOLO para detección de orégano
        yolo_results = yolo_model(img_pil)

        oregano_detected = False
        confidence = 0.0
        for r in yolo_results:
            for box in r.boxes:
                conf = float(box.conf[0])
                class_id = int(box.cls[0])
                if conf >= YOLO_CONF_THRESHOLD and class_id == OREGANO_CLASS_ID:
                    oregano_detected = True
                    confidence = conf
                    break
            if oregano_detected:
                break

        if not oregano_detected:
            return jsonify({"message": "No oregano detected in the image with the specified confidence.", "detecciones": []}), 200

        # 2. Si se detecta orégano, ejecutar el modelo de enfermedades en la imagen completa
        disease_status = "No clasificado (modelo de enfermedad no cargado)"
        disease_confidence = 0.0

        if disease_model:
            # Preprocesar la imagen completa
            img_resized = img_pil.resize(DISEASE_MODEL_IMG_SIZE)
            img_array = np.array(img_resized) / 255.0
            img_array = np.expand_dims(img_array, axis=0)

            # Clasificar la enfermedad
            disease_pred = disease_model.predict(img_array, verbose=0)
            disease_confidence = float(np.max(disease_pred))
            disease_idx = int(np.argmax(disease_pred))

            # Umbral de confianza para enfermedades
            if disease_confidence >= 0.8 and 0 <= disease_idx < len(DISEASE_CLASS_NAMES):
                disease_status = DISEASE_CLASS_NAMES[disease_idx]
            else:
                disease_status = "Oregano sano o enfermedad desconocida"

        # Retornar los resultados
        return jsonify({
            "message": "Detección y clasificación exitosas",
            "detecciones": [{
                "object": "oregano",
                "detection_confidence_yolo": round(confidence, 4),
                "disease_status": disease_status,
                "disease_confidence": round(disease_confidence, 4)
            }]
        }), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)

# -*- coding: latin-1 -*-
import os
import numpy as np
from flask import Flask, request, jsonify
from tensorflow.keras.models import load_model
from PIL import Image
import io
from ultralytics import YOLO
import logging

# Configurar logging para suprimir mensajes de TensorFlow


# Crear la aplicación Flask
app = Flask(__name__)

# --- Configuración de rutas ---
BASE_DIR = "./app"

# Rutas de modelos
YOLO_MODEL_PATH = os.path.join(BASE_DIR, "DetectorEnfermedadesYOLO.pt")
DISEASE_MODEL_PATH = os.path.join(BASE_DIR, "modelo_cnn_oreganoV2.h5")
DISEASE_CLASS_NAMES = ['ALTERNARIA', 'MOSAICO', 'OIDIO', 'ROYA']

# --- Inicialización de modelos ---
yolo_model = None
disease_model = None
OREGANO_CLASS_ID = -1

def load_models():
    global yolo_model, disease_model, OREGANO_CLASS_ID
    
    print("⏳ Cargando modelos...")
    
    # Cargar modelo YOLO
    try:
        if os.path.exists(YOLO_MODEL_PATH):
            yolo_model = YOLO(YOLO_MODEL_PATH, task='detect')
            
            # Buscar ID de clase 'oregano'
            if yolo_model.names:
                for class_id, class_name in yolo_model.names.items():
                    if class_name == 'oregano':
                        OREGANO_CLASS_ID = class_id
                        break
            
            print(f"✅ Modelo YOLO cargado | Clase oregano ID: {OREGANO_CLASS_ID}")
        else:
            print(f"❌ Archivo YOLO no encontrado: {YOLO_MODEL_PATH}")
    except Exception as e:
        print(f"🚨 Error cargando YOLO: {str(e)}")
    
    # Cargar modelo de enfermedades
    try:
        if os.path.exists(DISEASE_MODEL_PATH):
            disease_model = load_model(DISEASE_MODEL_PATH)
            print("✅ Modelo de enfermedades cargado")
        else:
            print(f"❌ Archivo de modelo de enfermedades no encontrado: {DISEASE_MODEL_PATH}")
    except Exception as e:
        print(f"🚨 Error cargando modelo de enfermedades: {str(e)}")

# Cargar modelos al iniciar la aplicación
load_models()

# --- Parámetros ---
YOLO_CONF_THRESHOLD = 0.5
DISEASE_MODEL_IMG_SIZE = (224, 224)

@app.route('/predict', methods=['POST'])
def predict():
    if 'file' not in request.files:
        return jsonify({"error": "No se proporcionó archivo"}), 400
    
    file = request.files['file']
    if not file or file.filename == '':
        return jsonify({"error": "Nombre de archivo vacío"}), 400
    
    try:
        # Leer imagen
        img = Image.open(io.BytesIO(file.read())).convert('RGB')
        
        # 1. Verificar si el modelo YOLO está cargado
        if not yolo_model:
            return jsonify({"error": "Modelo YOLO no cargado"}), 500
        
        # 2. Detección de orégano con YOLO
        results = yolo_model(img)
        oregano_detected = False
        confianza = 0.0
        
        for r in results:
            for box in r.boxes:
                conf = float(box.conf[0])
                class_id = int(box.cls[0])
                if conf >= YOLO_CONF_THRESHOLD and class_id == OREGANO_CLASS_ID:
                    oregano_detected = True
                    confianza = conf
                    break
            if oregano_detected:
                break
        
        if not oregano_detected:
            return jsonify({
                "message": "No se detectó orégano en la imagen",
                "detections": []
            }), 200
        
        # 3. Clasificación de enfermedades
        enfermedad = "Modelo no cargado"
        conf_enfermedad = 0.0
        
        if disease_model:
            # Preprocesamiento
            img_processed = img.resize(DISEASE_MODEL_IMG_SIZE)
            img_array = np.array(img_processed) / 255.0
            img_array = np.expand_dims(img_array, axis=0)
            
            # Predicción
            preds = disease_model.predict(img_array, verbose=0)
            conf_enfermedad = float(np.max(preds))
            idx_enfermedad = int(np.argmax(preds))
            
            # Aplicar umbral
            if conf_enfermedad >= 0.8 and 0 <= idx_enfermedad < len(DISEASE_CLASS_NAMES):
                enfermedad = DISEASE_CLASS_NAMES[idx_enfermedad]
            else:
                enfermedad = "Oregano sano o enfermedad desconocida"
        
        # Respuesta
        return jsonify({
            "message": "Análisis completado",
            "detections": [{
                "objeto": "oregano",
                "confianza_deteccion": round(confianza, 4),
                "estado_enfermedad": enfermedad,
                "confianza_enfermedad": round(conf_enfermedad, 4)
            }]
        }), 200
    
    except Exception as e:
        return jsonify({"error": f"Error interno: {str(e)}"}), 500

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({
        "status": "ok",
        "yolo_loaded": yolo_model is not None,
        "disease_model_loaded": disease_model is not None
    }), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)

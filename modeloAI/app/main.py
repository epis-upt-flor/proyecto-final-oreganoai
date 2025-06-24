# -*- coding: latin-1 -*-
import os
import numpy as np
from flask import Flask, request, jsonify
from tensorflow.keras.models import load_model
from PIL import Image
import io
from ultralytics import YOLO
import logging

# Configurar logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)

# --- Configuración de rutas ---
BASE_DIR = "./app"  # Usar ruta absoluta en contenedor

# Rutas de modelos
OREGANO_DETECTOR_PATH = os.path.join(BASE_DIR, "modelo_cnn_oreganoV2.h5")
DISEASE_DETECTOR_PATH = os.path.join(BASE_DIR, "DetectorEnfermedadesYOLO.pt")
DISEASE_CLASS_NAMES = ['ALTERNARIA', 'MOSAICO', 'OIDIO', 'ROYA']

# --- Inicialización de modelos ---
oregano_detector = None  # Modelo CNN para detectar orégano
disease_detector = None  # Modelo YOLO para detectar enfermedades

def load_models():
    global oregano_detector, disease_detector
    
    logger.info("⏳ Cargando modelos...")
    
    # 1. Cargar modelo detector de orégano (CNN)
    try:
        if os.path.exists(OREGANO_DETECTOR_PATH):
            oregano_detector = load_model(OREGANO_DETECTOR_PATH)
            logger.info("✅ Modelo detector de orégano (CNN) cargado")
        else:
            logger.error(f"❌ Archivo de detector de orégano no encontrado: {OREGANO_DETECTOR_PATH}")
    except Exception as e:
        logger.error(f"🚨 Error cargando detector de orégano: {str(e)}")
    
    # 2. Cargar modelo detector de enfermedades (YOLO)
    try:
        if os.path.exists(DISEASE_DETECTOR_PATH):
            disease_detector = YOLO(DISEASE_DETECTOR_PATH, task='detect')
            logger.info("✅ Modelo detector de enfermedades (YOLO) cargado")
        else:
            logger.error(f"❌ Archivo de detector de enfermedades no encontrado: {DISEASE_DETECTOR_PATH}")
    except Exception as e:
        logger.error(f"🚨 Error cargando detector de enfermedades: {str(e)}")

# Cargar modelos al iniciar
load_models()

# --- Parámetros ---
OREGANO_CONF_THRESHOLD = 0.5  # Umbral para considerar que se detecta orégano
DISEASE_CONF_THRESHOLD = 0.8  # Umbral para considerar enfermedad
OREGANO_MODEL_IMG_SIZE = (224, 224)  # Tamaño para el modelo de orégano

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
        
        # 1. Verificar si el modelo detector de orégano está cargado
        if oregano_detector is None:
            return jsonify({"error": "Modelo detector de orégano no cargado"}), 500
        
        # Preprocesar imagen para el modelo de orégano
        img_oregano = img.resize(OREGANO_MODEL_IMG_SIZE)
        img_array = np.array(img_oregano) / 255.0
        img_array = np.expand_dims(img_array, axis=0)
        
        # Predecir si es orégano
        pred_oregano = oregano_detector.predict(img_array, verbose=0)
        conf_oregano = float(pred_oregano[0][0])  # Probabilidad de ser orégano
        
        # Si no es orégano, retornar inmediatamente
        if conf_oregano < OREGANO_CONF_THRESHOLD:
            return jsonify({
                "message": "No se detectó orégano en la imagen",
                "confianza_oregano": round(conf_oregano, 4),
                "detections": []
            }), 200
        
        # 2. Detección de enfermedades con YOLO
        enfermedad = "Oregano sano o enfermedad desconocida"
        conf_enfermedad = 0.0
        
        if disease_detector:
            # Ejecutar el modelo YOLO en la imagen original
            results = disease_detector(img)
            
            # Buscar la enfermedad con mayor confianza
            for r in results:
                for box in r.boxes:
                    conf = float(box.conf[0])
                    class_id = int(box.cls[0])
                    
                    # Actualizar si encontramos una enfermedad con mayor confianza
                    if conf > conf_enfermedad:
                        conf_enfermedad = conf
                        if class_id < len(DISEASE_CLASS_NAMES):
                            enfermedad = DISEASE_CLASS_NAMES[class_id]
            
            # Aplicar umbral de confianza
            if conf_enfermedad < DISEASE_CONF_THRESHOLD:
                enfermedad = "Oregano sano o enfermedad desconocida"
        
        # Respuesta
        return jsonify({
            "message": "Análisis completado",
            "confianza_oregano": round(conf_oregano, 4),
            "detections": [{
                "enfermedad": enfermedad,
                "confianza_enfermedad": round(conf_enfermedad, 4)
            }]
        }), 200
    
    except Exception as e:
        logger.exception("Error durante la predicción")
        return jsonify({"error": f"Error interno: {str(e)}"}), 500

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({
        "status": "ok",
        "oregano_detector_loaded": oregano_detector is not None,
        "disease_detector_loaded": disease_detector is not None
    }), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)

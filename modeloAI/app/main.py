# -*- coding: latin-1 -*-
import os
import numpy as np
from flask import Flask, request, jsonify
from tensorflow.keras.models import load_model
from PIL import Image
import io
from ultralytics import YOLO

app = Flask(__name__)

# --- Rutas a los modelos ---
# Usa el directorio raíz de la aplicación en el contenedor
BASE_DIR = "/app"  # Directorio raíz del contenedor

# Ruta al modelo YOLO (.pt)
YOLO_MODEL_PATH = os.path.join(BASE_DIR, "ModeloDetectorEnfermedadesYOLO.pt")

# Ruta al modelo de clasificación de enfermedades (.h5)
DISEASE_MODEL_PATH = os.path.join(BASE_DIR, "modelo_cnn_oreganoV2.h5")
DISEASE_CLASS_NAMES = ['ALTERNARIA', 'MOSAICO', 'OIDIO', 'ROYA']

# --- Cargar los modelos ---
yolo_model = None
disease_model = None
OREGANO_CLASS_ID = -1

try:
    # Verifica si el archivo existe antes de cargarlo
    if not os.path.exists(YOLO_MODEL_PATH):
        raise FileNotFoundError(f"Archivo YOLO no encontrado: {YOLO_MODEL_PATH}")
    
    yolo_model = YOLO(YOLO_MODEL_PATH, task='detect', verbose=False)
    
    # Verificar si la clase 'oregano' está en el modelo
    if yolo_model.names is not None and 'oregano' in yolo_model.names.values():
        for k, v in yolo_model.names.items():
            if v == 'oregano':
                OREGANO_CLASS_ID = k
                break
    
    print(f"Modelo YOLO cargado correctamente desde: {YOLO_MODEL_PATH}")
    
    if OREGANO_CLASS_ID == -1:
        print("Advertencia: La clase 'oregano' no se encontró en las etiquetas del modelo YOLO.")

except Exception as e:
    print(f"Error al cargar el modelo YOLO: {str(e)}")
    # Imprime el directorio actual y su contenido para depuración
    print(f"Directorio actual: {os.getcwd()}")
    print(f"Contenido del directorio: {os.listdir('/app')}")
    exit(1)

try:
    # Verifica si el archivo existe antes de cargarlo
    if not os.path.exists(DISEASE_MODEL_PATH):
        raise FileNotFoundError(f"Archivo de enfermedad no encontrado: {DISEASE_MODEL_PATH}")
    
    disease_model = load_model(DISEASE_MODEL_PATH)
    print(f"Modelo de clasificación de enfermedades cargado correctamente desde: {DISEASE_MODEL_PATH}")
    
except Exception as e:
    print(f"Error al cargar el modelo de clasificación de enfermedades: {str(e)}")
    # Imprime el directorio actual y su contenido para depuración
    print(f"Directorio actual: {os.getcwd()}")
    print(f"Contenido del directorio: {os.listdir('/app')}")
    disease_model = None

# --- Parámetros de Inferencia ---
YOLO_CONF_THRESHOLD = 0.5
DISEASE_MODEL_IMG_SIZE = (224, 224)

@app.route('/predict', methods=['POST'])
def predict():
    # ... (el resto del código permanece igual) ...

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)

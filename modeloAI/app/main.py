# -*- coding: latin-1 -*-
import os
import numpy as np
from flask import Flask, request, jsonify
from tensorflow.keras.models import load_model # Para tu modelo de clasificación de enfermedades
from PIL import Image
import io
 # Necesario para procesar imágenes con YOLO y recortar

# Importar YOLO de ultralytics
from ultralytics import YOLO

app = Flask(__name__)

# --- Rutas a los modelos ---
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# Ruta a tu modelo YOLOv8n (debe ser un archivo .pt)
# ASUMIMOS que este es tu verdadero modelo YOLO entrenado para detectar 'oregano'
# Si tu modelo YOLOv8n se llama diferente, ajusta esta ruta.
YOLO_MODEL_PATH = os.path.join(BASE_DIR, "oreganoDetectorYOLOv1.pt") # Ejemplo: ruta típica de un modelo YOLOv8n entrenado

# Ruta a tu modelo de clasificación de enfermedades (Keras .keras o .h5)
DISEASE_MODEL_PATH = os.path.join(BASE_DIR, "modelo_cnn_oregano_ligero.keras")
DISEASE_CLASS_NAMES = ['ALTERNARIA', 'OIDIO', 'OREGANO SANO', 'ROYA']

# --- Cargar los modelos ---
yolo_model = None
disease_model = None

try:
    # Cargar el modelo YOLO
    # 'verbose=False' para no imprimir los mensajes de carga de YOLO al iniciar la API
    yolo_model = YOLO(YOLO_MODEL_PATH, verbose=False)
    print(f"Modelo YOLO cargado correctamente desde: {YOLO_MODEL_PATH}")
except Exception as e:
    print(f"Error al cargar el modelo YOLO: {e}")
    # Es crucial que el modelo YOLO se cargue para que la API funcione
    exit(1) # Salir si el modelo principal no carga

try:
    # Cargar el modelo de clasificación de enfermedades
    disease_model = load_model(DISEASE_MODEL_PATH)
    print(f"Modelo de clasificación de enfermedades cargado correctamente desde: {DISEASE_MODEL_PATH}")
except Exception as e:
    print(f"Error al cargar el modelo de clasificación de enfermedades: {e}")
    # Si este modelo falla, la API aún puede detectar, pero no clasificar enfermedades
    disease_model = None # Asegurarse de que sea None si falla la carga

# --- Parámetros de Inferencia ---
# Umbral de confianza para las detecciones de YOLO (ej: solo mostrar si YOLO está 50% seguro)
YOLO_CONF_THRESHOLD = 0.5
# Tamaño de imagen esperado por tu modelo de clasificación de enfermedades
DISEASE_MODEL_IMG_SIZE = (224, 224)

@app.route('/detect_oregano_diseases', methods=['POST'])
def detect_oregano_diseases():
    # Verificar si se proporcionó un archivo
    if 'file' not in request.files:
        return jsonify({"error": "No file provided"}), 400

    file = request.files['file']
    if file.filename == '':
        return jsonify({"error": "No selected file"}), 400

    try:
        # Leer la imagen
        # Usamos PIL para abrir y luego convertir a un array numpy para YOLO
        # YOLO puede tomar PIL.Image directamente, pero cv2.imread + cv2.cvtColor es robusto
        img_pil = Image.open(io.BytesIO(file.read())).convert('RGB')
        
        # Opcional: Convertir a formato CV2 si prefieres usarlo para recortes/visualización antes de PIL
        # img_cv2 = np.array(img_pil) # Esto será RGB
        # img_cv2 = cv2.cvtColor(img_cv2, cv2.COLOR_RGB2BGR) # Si necesitas BGR para algunas ops de cv2

        # 1. Ejecutar el modelo YOLO para detección de orégano
        # YOLOv8 puede tomar una imagen PIL directamente
        yolo_results = yolo_model(img_pil) # Esto ejecuta la inferencia de YOLO

        all_detections = []

        # Procesar los resultados de YOLO
        for r in yolo_results: # 'r' es un objeto de resultados para una imagen (habrá solo uno aquí)
            for box in r.boxes: # 'r.boxes' contiene todas las detecciones (bounding boxes)
                x1, y1, x2, y2 = map(int, box.xyxy[0].tolist()) # Coordenadas del bounding box
                confidence = float(box.conf[0]) # Confianza de la detección de YOLO
                class_id = int(box.cls[0]) # ID de la clase detectada (ej: 0 para 'oregano')

                # Filtrar por un umbral de confianza de YOLO
                if confidence < YOLO_CONF_THRESHOLD:
                    continue
                
                # Asegurarse de que las coordenadas sean válidas para el recorte
                # Es importante para evitar errores si los bounding boxes se extienden fuera
                x1 = max(0, x1)
                y1 = max(0, y1)
                x2 = min(img_pil.width, x2)
                y2 = min(img_pil.height, y2)

                # Si la detección es de la clase 'oregano' (ajusta el ID si es necesario)
                # Asumimos que tu modelo YOLOv8n solo detecta 'oregano' o que la clase 'oregano' tiene ID 0
                # Puedes usar `yolo_model.names[class_id]` para obtener el nombre de la clase
                # Por ejemplo, si 'oregano' es la clase ID 0:
                if yolo_model.names[class_id] == 'oregano': # Asegúrate que 'oregano' sea el nombre de tu clase
                    # 2. Recortar la Región de Interés (ROI) para el clasificador de enfermedades
                    # `img_pil.crop()` toma una tupla (left, upper, right, lower)
                    roi_pil = img_pil.crop((x1, y1, x2, y2))
                    
                    disease_status = "No clasificado (modelo de enfermedad no cargado)"
                    disease_confidence = 0.0

                    if disease_model:
                        # 3. Preprocesar la ROI para el modelo de clasificación de enfermedades
                        # Tu modelo espera 224x224, normalizado y con dimensión de batch
                        roi_resized_pil = roi_pil.resize(DISEASE_MODEL_IMG_SIZE)
                        roi_array = np.array(roi_resized_pil) / 255.0 # Normalizar
                        roi_array = np.expand_dims(roi_array, axis=0) # Añadir dimensión de batch

                        # 4. Clasificar la enfermedad de la hoja recortada
                        disease_pred = disease_model.predict(roi_array, verbose=0) # verbose=0 para no imprimir en cada predicción
                        disease_idx = int(np.argmax(disease_pred))
                        disease_conf = float(np.max(disease_pred))

                        if 0 <= disease_idx < len(DISEASE_CLASS_NAMES):
                            disease_status = DISEASE_CLASS_NAMES[disease_idx]
                        else:
                            disease_status = "Clase de enfermedad desconocida"
                    
                    # Agregar los resultados de esta detección a la lista
                    all_detections.append({
                        "object": yolo_model.names[class_id],
                        "detection_confidence_yolo": round(confidence, 4),
                        "bounding_box": {"x1": x1, "y1": y1, "x2": x2, "y2": y2},
                        "disease_status": disease_status,
                        "disease_confidence": round(disease_conf, 4)
                    })
        
        if not all_detections:
            return jsonify({"message": "No oregano detected in the image with the specified confidence.", "detections": []}), 200

        return jsonify({"message": "Detections and classifications successful", "detections": all_detections}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    # Cuando ejecutas Flask en un entorno como Colab o en un servidor,
    # el host '0.0.0.0' permite que sea accesible desde fuera del contenedor/máquina virtual.
    app.run(host='0.0.0.0', port=5000, debug=False) # debug=True es bueno para desarrollo
# Usar imagen base de Python 3.10
FROM python:3.10-slim

# Instalar dependencias
RUN apt-get update && apt-get install -y \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxrender1 \
    libxext6 \
    && rm -rf /var/lib/apt/lists/*

# Crear directorio para la aplicación
WORKDIR /app

# Copiar archivos necesarios
COPY requirements.txt .
COPY app/ ./app

# Instalar dependencias
RUN pip install --no-cache-dir -r requirements.txt

# Ejecutar la aplicación
CMD ["python", "/app/app/main.py"]
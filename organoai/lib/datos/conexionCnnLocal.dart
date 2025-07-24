import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class ModeloOregano {
  late Interpreter _detectorInterpreter;
  late Interpreter _classifierInterpreter;

  final List<String> classNames = ['ALTERNARIA', 'MOSAICO', 'OIDIO', 'ROYA'];
  final double oreganoThreshold = 0.6;
  final double diseaseThreshold = 0.4;

  Future<void> cargarModelos() async {
    _detectorInterpreter =
        await Interpreter.fromAsset('CNNmodels/oregano_detector.tflite');
    _classifierInterpreter =
        await Interpreter.fromAsset('CNNmodels/desease_classifier.tflite');
  }

  Future<List<Map<String, dynamic>>> analizarImagen(
      img.Image imageOriginal) async {
    final List<Map<String, dynamic>> resultados = [];

    // Paso 1: Redimensionar imagen si es necesario
    final img.Image resized =
        img.copyResize(imageOriginal, width: 224, height: 224);

    // Paso 2: Preprocesar imagen para detector
    var input = imageToByteListFloat32(resized, 224); // formato esperado
    var output =
        List.generate(1, (_) => List.filled(4 + classNames.length, 0.0))
            .toList();

    // Paso 3: Ejecutar modelo de detección
    _detectorInterpreter.run(input, output);

    // Paso 4: Extraer detecciones
    for (var pred in output) {
      double score = pred[0];
      if (score >= oreganoThreshold) {
        // Obtener coordenadas
        final x = pred[1];
        final y = pred[2];
        final w = pred[3];
        final h = pred[4];

        // Recortar región
        int left = (x - w / 2).clamp(0, resized.width).toInt();
        int top = (y - h / 2).clamp(0, resized.height).toInt();
        int right = (x + w / 2).clamp(0, resized.width).toInt();
        int bottom = (y + h / 2).clamp(0, resized.height).toInt();

        final img.Image recorte =
            img.copyCrop(resized, left, top, right - left, bottom - top);
        final img.Image redim =
            img.copyResize(recorte, width: 224, height: 224);

        // Paso 5: Clasificar enfermedad
        var entradaClasificador = imageToByteListFloat32(redim, 224);
        var salidaClasificador =
            List.filled(classNames.length, 0.0).reshape([1, classNames.length]);
        _classifierInterpreter.run(entradaClasificador, salidaClasificador);

        final confidencias = salidaClasificador[0];
        final indiceMax =
            confidencias.indexWhere((e) => e == confidencias.reduce(max));
        final confianza = confidencias[indiceMax];

        resultados.add({
          'confianza': confianza,
          'enfermedad': confianza >= diseaseThreshold
              ? classNames[indiceMax]
              : 'Oregano sano',
          'coordenadas': {
            'left': left,
            'top': top,
            'right': right,
            'bottom': bottom
          },
        });
      }
    }

    return resultados;
  }

  TensorImage imageToByteListFloat32(img.Image image, int inputSize) {
    final TensorImage tensorImage = TensorImage.fromImage(image);
    final ImageProcessor imageProcessor = ImageProcessorBuilder()
        .add(ResizeOp(inputSize, inputSize, ResizeMethod.BILINEAR))
        .add(NormalizeOp(127.5, 127.5))
        .build();
    return imageProcessor.process(tensorImage);
  }

  void dispose() {
    _detectorInterpreter.close();
    _classifierInterpreter.close();
  }
}

//ConexionCNNlocal

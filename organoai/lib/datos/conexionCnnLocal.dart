import 'dart:math';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class ModeloOregano {
  late final Interpreter _detector;
  late final Interpreter _classifier;

  final List<String> _classNames = ['ALTERNARIA', 'MOSAICO', 'OIDIO', 'ROYA'];
  final double _oreganoThreshold = 0.6;
  final double _diseaseThreshold = 0.4;

  /// Carga ambos modelos `.tflite` desde la carpeta assets
  Future<void> inicializar() async {
    _detector = await Interpreter.fromAsset('CNNmodels/oregano_detector.tflite');
    _classifier = await Interpreter.fromAsset('CNNmodels/desease_classifier.tflite');
  }

  /// Analiza una imagen y devuelve una lista de resultados con:
  /// enfermedad detectada, confianza y coordenadas del recorte
  Future<List<Map<String, dynamic>>> analizar(img.Image original) async {
    final resultados = <Map<String, dynamic>>[];

    final tensorImage = _preprocesarImagen(original, size: 224);
    final input = tensorImage.buffer;
    final output = List.generate(1, (_) => List.filled(5, 0.0)); // [score, x, y, w, h]

    _detector.run(input, output);

    for (final pred in output) {
      final score = pred[0];
      if (score < _oreganoThreshold) continue;

      final recorte = _recortarRegion(original, pred[1], pred[2], pred[3], pred[4]);
      if (recorte == null) continue;

      final resultado = _clasificarEnfermedad(recorte);
      resultados.add(resultado..addAll({'coordenadas': _coordenadas(pred, original)}));
    }

    return resultados;
  }

  /// Libera recursos del modelo
  void cerrar() {
    _detector.close();
    _classifier.close();
  }

  /// Preprocesa una imagen para adaptarla al modelo
/// Preprocesa una imagen para adaptarla al modelo
    TensorImage _preprocesarImagen(img.Image imagen, {int size = 224}) {
      final processor = ImageProcessorBuilder()
          .add(ResizeOp(size, size, ResizeMethod.NEAREST_NEIGHBOUR))
          .add(NormalizeOp(127.5, 127.5))
          .build();
      return processor.process(TensorImage.fromImage(imagen));
    }

  /// Realiza la clasificaci贸n de la enfermedad sobre una regi贸n recortada
  Map<String, dynamic> _clasificarEnfermedad(img.Image region) {
    final tensor = _preprocesarImagen(region);
    final entrada = tensor.buffer;
    final salida = List.filled(_classNames.length, 0.0).reshape([1, _classNames.length]);
    _classifier.run(entrada, salida);

    final confianzas = salida[0];
    final maxScore = confianzas.reduce(max);
    final indice = confianzas.indexOf(maxScore);

    return {
      'confianza': maxScore,
      'enfermedad': maxScore >= _diseaseThreshold ? _classNames[indice] : 'Oregano sano',
    };
  }

  /// Recorta una regi贸n detectada en la imagen original
  img.Image? _recortarRegion(img.Image original, double x, double y, double w, double h) {
    final left = max((x - w / 2).toInt(), 0);
    final top = max((y - h / 2).toInt(), 0);
    final right = min((x + w / 2).toInt(), original.width);
    final bottom = min((y + h / 2).toInt(), original.height);

    if (right <= left || bottom <= top) return null;

    return img.copyCrop(original, left, top, right - left, bottom - top);
  }

  /// Convierte los valores de predicci贸n a coordenadas entendibles
  Map<String, int> _coordenadas(List<double> pred, img.Image imgOriginal) {
    final x = pred[1], y = pred[2], w = pred[3], h = pred[4];

    return {
      'left': max((x - w / 2).toInt(), 0),
      'top': max((y - h / 2).toInt(), 0),
      'right': min((x + w / 2).toInt(), imgOriginal.width),
      'bottom': min((y + h / 2).toInt(), imgOriginal.height),
    };
  }
}
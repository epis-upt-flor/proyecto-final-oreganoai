import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

void main() {
  group('Segmentación - Prueba de Sobrecarga API', () {
    test('Múltiples solicitudes concurrentes a la API', () async {
      final int concurrentRequests = 10; // Puedes ajustar este número
      final uri =
          Uri.parse('https://flask-cnn-api-latest.onrender.com/predict');
      final imagePath =
          'test/segmentation/test.jfif'; // Cambia la ruta si es necesario

      final List<Future<http.StreamedResponse>> requests = [];

      for (int i = 0; i < concurrentRequests; i++) {
        final request = http.MultipartRequest('POST', uri)
          ..files.add(await http.MultipartFile.fromPath('file', imagePath));
        requests.add(request.send());
      }

      final responses = await Future.wait(requests);

      for (var response in responses) {
        expect(response.statusCode, equals(200),
            reason: 'Respuesta no exitosa');
      }
    });
  });
}

import 'package:test/test.dart';
import 'package:http/http.dart' as http;

void main() {
  group('Segmentación - Prueba de Sobrecarga API', () {
    test('Múltiples solicitudes concurrentes a la API', () async {
      final int concurrentRequests = 50;
      final uri = Uri.parse('https://flask-cnn-api-latest.onrender.com/predict');
      final List<Future<http.Response>> requests = [];

      for (int i = 0; i < concurrentRequests; i++) {
        requests.add(http.get(uri));
      }

      final responses = await Future.wait(requests);

      for (var response in responses) {
        expect(response.statusCode, equals(200), reason: 'Respuesta no exitosa');
      }
    });
  });
}
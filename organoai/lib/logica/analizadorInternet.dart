import 'package:flutter/material.dart';
import 'package:flutter_speed_test_plus/flutter_speed_test_plus.dart';

class SpeedTestScreen extends StatefulWidget {
  const SpeedTestScreen({Key? key}) : super(key: key);

  @override
  State<SpeedTestScreen> createState() => _SpeedTestScreenState();
}

class _SpeedTestScreenState extends State<SpeedTestScreen> {
  final FlutterInternetSpeedTest _speedTest = FlutterInternetSpeedTest();
  String _downloadSpeed = "0.0";
  String _uploadSpeed = "0.0";
  String _ping = "0.0";
  String _status = "Listo para iniciar...";
  bool _isRunning = false;

  void _startSpeedTest() {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
      _status = "Iniciando prueba...";
      _downloadSpeed = "0.0";
      _uploadSpeed = "0.0";
      _ping = "0.0";
    });

    _speedTest.startTesting(
      useFastApi: true,
      onStarted: () {
        setState(() {
          _status = "Prueba iniciada...";
        });
        print("✅ Prueba de velocidad iniciada.");
      },
      onCompleted: (download, upload) {
        final dSpeed =
            "${download.transferRate.toStringAsFixed(2)} ${download.unit.name}";
        final uSpeed =
            "${upload.transferRate.toStringAsFixed(2)} ${upload.unit.name}";

        setState(() {
          _downloadSpeed = dSpeed;
          _uploadSpeed = uSpeed;
          _ping = "N/A"; // Ping no disponible en este paquete
          _status = "✅ Prueba completada";
          _isRunning = false;
        });

        print("🟢 Resultado final:");
        print("🔽 Velocidad de descarga: $dSpeed");
        print("🔼 Velocidad de subida: $uSpeed");
        print("📡 Ping: N/A");
      },
      onProgress: (percent, data) {
        setState(() {
          _status = "Progreso: ${percent.toStringAsFixed(0)}%";
          if (data.type == TestType.download) {
            _downloadSpeed =
                "${data.transferRate.toStringAsFixed(2)} ${data.unit.name}";
          } else if (data.type == TestType.upload) {
            _uploadSpeed =
                "${data.transferRate.toStringAsFixed(2)} ${data.unit.name}";
          }
        });
      },
      onError: (errorMessage, speedTestError) {
        setState(() {
          _status = "❌ Error: $errorMessage - $speedTestError";
          _isRunning = false;
        });
        print("❌ Error durante la prueba: $errorMessage ($speedTestError)");
      },
      onDefaultServerSelectionDone: (servers) {
        // Primero verificamos que servers no sea null y que sea iterable
        if (servers != null) {
          try {
            // Intentamos obtener la longitud si es iterable
            final count = (servers as dynamic).length;
            print("🌐 Servidores seleccionados automáticamente: $count");
          } catch (e) {
            // Si no tiene .length o da error, imprimimos el contenido directamente
            print(
                "🌐 Servidores seleccionados (no iterable o sin longitud): $servers");
          }
        } else {
          print("🌐 No se recibieron servidores.");
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prueba de Velocidad de Internet'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                _status,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              _buildResultRow("🔽 Descarga:", _downloadSpeed),
              const SizedBox(height: 15),
              _buildResultRow("🔼 Subida:", _uploadSpeed),
              const SizedBox(height: 15),
              _buildResultRow("📡 Ping:", "$_ping ms"),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _startSpeedTest,
                child: const Text('Iniciar Prueba de Velocidad'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 18)),
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

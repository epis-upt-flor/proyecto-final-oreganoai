import 'package:flutter_speed_test_plus/flutter_speed_test_plus.dart';


class AnalizadorInternet {
  static Future<bool> testConexion() async {
    final FlutterInternetSpeedTest speedTest = FlutterInternetSpeedTest();
    bool exito = false;
    try {
      await speedTest.startTesting(
        useFastApi: true,
        onStarted: () {
          print("✅ Prueba de velocidad iniciada.");
        },
        onCompleted: (download, upload) {
          final dSpeed = "${download.transferRate.toStringAsFixed(2)} ${download.unit.name}";
          final uSpeed = "${upload.transferRate.toStringAsFixed(2)} ${upload.unit.name}";
          print("🟢 Resultado final:");
          print("🔽 Velocidad de descarga: $dSpeed");
          print("🔼 Velocidad de subida: $uSpeed");
          exito = true;
        },
        onProgress: (percent, data) {
          print("Progreso: ${percent.toStringAsFixed(0)}%");
        },
        onError: (errorMessage, speedTestError) {
          print("❌ Error durante la prueba: $errorMessage ($speedTestError)");
          exito = false;
        },
        onDefaultServerSelectionDone: (servers) {
          print("🌐 Servidores seleccionados: $servers");
        },
      );
    } catch (e) {
      print("❌ Error inesperado: $e");
      exito = false;
    }
    return exito;
  }
}
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../datos/conexionApi.dart';
import '../logica/logicaEscaneo.dart';
import '../logica/logicaNotificaciones.dart';
import '../vista/perfil.dart';
import '../vista/historial.dart';
import '../vista/configuracion.dart';

class LogicaFoto with ChangeNotifier {
  final List<File> _images = [];
  bool esInvitado = false;
  final ImagePicker _picker = ImagePicker();

  List<File> get images => _images;

  void eliminarImagen(int index) {
    _images.removeAt(index);
    notifyListeners();
  }

  Future<void> takePhoto(BuildContext context) async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      images.add(File(pickedFile.path));
      notifyListeners();
    }
  }

  Future<void> pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      _images.addAll(pickedFiles.map((file) => File(file.path)));
      notifyListeners();
    }
  }

  Future<void> scanImages(BuildContext context) async {
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No hay imágenes para escanear")),
      );
      return;
    }

    final notiService = NotificacionesService.instance;
    await notiService.showNotification(
      title: 'Escaneo iniciado',
      body: 'Procesando imágenes...',
    );

    final logicaEscaneo = LogicaEscaneo();
    final List<Map<String, dynamic>> resultados = [];

    for (final image in _images) {
      try {
        final response = await ConexionApi().predictImage(image.path);
        resultados.add({'image': image, 'response': response});
      } catch (e) {
        resultados.add({
          'image': image,
          'response': {'error': e.toString()}
        });
      }
    }

    await notiService.showNotification(
      title: 'Escaneo completo',
      body: 'Se analizaron todas las imágenes.',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => logicaEscaneo.buildScanResults(resultados, context),
      ),
    );
  }

  Future<void> onItemTapped(BuildContext context, int index) async {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HistorialPage()),
        );
        break;
      case 1:
        await takePhoto(context); // ← Aquí ahora sí puedes usar await
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PerfilPage()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
        break;
    }
  }
}

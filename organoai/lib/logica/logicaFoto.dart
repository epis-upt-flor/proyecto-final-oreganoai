import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../datos/conexionApi.dart';
import '../logica/logicaEscaneo.dart';
import '../logica/logicaNotificaciones.dart';
import '../vista/perfil.dart';
import '../vista/historial.dart';
import '../vista/configuracion.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImagenConUbicacion {
  final File imagen;
  final Position? ubicacion;

  ImagenConUbicacion({required this.imagen, this.ubicacion});

  double? get latitud => ubicacion?.latitude;
  double? get longitud => ubicacion?.longitude;
}

class LogicaFoto with ChangeNotifier {
  final List<ImagenConUbicacion> _imagenesConUbicacion = [];
  List<ImagenConUbicacion> get imagenesConUbicacion => _imagenesConUbicacion;
  bool esInvitado = false;
  final ImagePicker _picker = ImagePicker();

  void eliminarImagen(int index) {
    _imagenesConUbicacion.removeAt(index);
    notifyListeners();
  }

  Future<void> takePhoto(BuildContext context) async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      Position? posicion;
      try {
        LocationPermission permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse) {
          posicion = await Geolocator.getCurrentPosition();
        }
      } catch (e) {
        posicion = null;
      }
      _imagenesConUbicacion.add(ImagenConUbicacion(
          imagen: File(pickedFile.path), ubicacion: posicion));
      notifyListeners();
    }
  }

  Future<void> pickImages() async {
    // Código para seleccionar imágenes desde la galería
    final pickedFiles = await ImagePicker().pickMultiImage();
    for (var file in pickedFiles) {
      final compressedImage = await _compressImage(File(file.path));
      imagenesConUbicacion.add(ImagenConUbicacion(imagen: compressedImage));
    }
    notifyListeners();
    }

  // ...existing code...
  Future<void> scanImages(BuildContext context) async {
    if (_imagenesConUbicacion.isEmpty) {
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

    for (final image in _imagenesConUbicacion) {
      try {
        final compressedImage = await _compressImage(image.imagen);

        final response = await ConexionApi().predictImage(compressedImage.path);
        // Incluye la ubicación en los resultados
        resultados.add({
          'image': image,
          'response': response,
          'latitud': image.ubicacion?.latitude,
          'longitud': image.ubicacion?.longitude,
        });
      } catch (e) {
        resultados.add({
          'image': image,
          'response': {'error': e.toString()},
          'latitud': image.ubicacion?.latitude,
          'longitud': image.ubicacion?.longitude,
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

  Future<File> _compressImage(File imageFile) async {
    final imageBytes = await imageFile.readAsBytes();
    final originalImage = img.decodeImage(imageBytes);

    if (originalImage != null) {
      // Comprimir la imagen
      final resizedImage = img.copyResize(originalImage,
          width: 512, height: 512); // Ajusta el tamaño según tus necesidades
      final compressedBytes = img.encodeJpg(resizedImage,
          quality: 85); // Ajusta la calidad según tus necesidades

      // Guardar la imagen comprimida en un archivo temporal
      final tempDir = await getTemporaryDirectory();
      final compressedFile =
          File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await compressedFile.writeAsBytes(compressedBytes);

      return compressedFile;
    } else {
      throw Exception("Error al procesar la imagen");
    }
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

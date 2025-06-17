import 'dart:io';
import 'dart:convert'; // Para codificar a Base64
import 'package:http/http.dart'
    as http; // Asegúrate de tener el paquete http en tu pubspec.yml
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ScanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Guarda un escaneo en Firestore asociado al usuario actual
  Future<void> guardarEscaneo({
    required String tipoEnfermedad,
    required String descripcion,
    required String tratamiento,
    required DateTime fechaEscaneo,
    required String urlImagen, // URL de la imagen subida a ImgBB
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('escaneos')
          .add({
        'tipoEnfermedad': tipoEnfermedad,
        'descripcion': descripcion,
        'tratamiento': tratamiento,
        'fechaEscaneo': Timestamp.fromDate(fechaEscaneo),
        'urlImagen': urlImagen,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error al guardar el escaneo: ${e.toString()}');
    }
  }

  /// Obtiene los escaneos del usuario actual
  Future<List<Map<String, dynamic>>> obtenerEscaneos() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('escaneos')
          .orderBy('fechaEscaneo', descending: true)
          .get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Error al obtener los escaneos: ${e.toString()}');
    }
  }
}

class LogicaEscaneo {
  final ScanService _scanService = ScanService();
  // Clave API de ImgBB y URL de subida
  static const String _apiKey = "a2cf28f997aaa0388316413335a4a969";
  static const String _uploadUrl =
      "https://api.imgbb.com/1/upload?expiration=600&key=$_apiKey";

  /// Sube la imagen a ImgBB y regresa la URL resultante
  Future<String> _uploadImageToImgbb(File image) async {
    try {
      final bytes = await image.readAsBytes();
      final String base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse(_uploadUrl),
        body: {'image': base64Image},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          final imageUrl = jsonResponse['data']['url'];
          return imageUrl;
        } else {
          throw Exception(
              "Error al subir la imagen: ${jsonResponse['error']['message']}");
        }
      } else {
        throw Exception("Error HTTP: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error al subir la imagen a ImgBB: ${e.toString()}");
    }
  }

  /// Guarda el escaneo subiendo la imagen a ImgBB y registrando la URL resultante en Firestore.
  Future<void> guardarEscaneo(BuildContext context, List<File> images,
      Map<String, dynamic> apiResponse) async {
    if (images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No hay imágenes para guardar.")),
      );
      return;
    }

    try {
      final DateTime now = DateTime.now();
      final File image = images.first;

      // 1. Subir imagen a ImgBB
      final String downloadUrl = await _uploadImageToImgbb(image);

      // 2. Extraer tipo de enfermedad desde el texto de la API
      final rawTipo =
          (apiResponse['plaga'] ?? 'Desconocida').toString().toLowerCase();

      // Método para extraer la enfermedad del texto
      final RegExp exp =
          RegExp(r'enfermedad detectada:\s*([\w\s]+)', caseSensitive: false);
      final match = exp.firstMatch(rawTipo);
      final String tipo =
          match != null ? match.group(1)!.trim().toLowerCase() : 'desconocida';

      // 3. Buscar la enfermedad en Firestore
      String descripcion = "No disponible";
      String tratamiento = "No disponible";

      final querySnapshot = await FirebaseFirestore.instance
          .collection('enfermedad')
          .where('nombre', isGreaterThanOrEqualTo: tipo)
          .where('nombre',
              isLessThan: '${tipo}z') // ← Aquí se usa interpolación
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        descripcion = data['descripcion'] ?? descripcion;
        tratamiento = data['tratamiento'] ?? tratamiento;
      }

      // 4. Guardar escaneo
      await _scanService.guardarEscaneo(
        tipoEnfermedad: tipo,
        descripcion: descripcion,
        tratamiento: tratamiento,
        fechaEscaneo: now,
        urlImagen: downloadUrl,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Escaneo guardado exitosamente.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al guardar escaneo: ${e.toString()}")),
      );
    }
  }
}

import 'dart:io'; // Needed for the File class
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; // Needed for BuildContext and SnackBar

class ScanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Guarda un escaneo en Firestore asociado al usuario actual
  Future<void> guardarEscaneo({
    required String tipoEnfermedad,
    required String descripcion,
    required DateTime fechaEscaneo,
    required String urlImagen, // URL de la imagen (asumimos que ya está subida)
  }) async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      // Crea un nuevo documento dentro de la colección del usuario
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('escaneos')
          .add({
        'tipoEnfermedad': tipoEnfermedad,
        'descripcion': descripcion,
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
  // FirebaseStorage _storage ya no es necesario aquí por ahora.

  /// Guarda los escaneos, esperando que la URL de la imagen ya esté disponible.
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

      // Se toma la primera imagen. En esta versión, no se sube a Firebase Storage aquí.
      // Asumimos que `urlImagen` vendrá de otro proceso o se manejará después.
      // Por ahora, usaremos un placeholder o esperarás a que se suba externamente.
      // Si la URL de la imagen no está disponible aquí, necesitarías decidir
      // cómo obtenerla antes de llamar a _scanService.guardarEscaneo.
      final String downloadUrl = "placeholder_url_o_manejar_subida_externamente";

      // Extraer datos de la respuesta de la API
      final String tipo = apiResponse['tipo'] ?? 'Desconocida';
      final String descripcion = apiResponse['descripcion'] ?? 'No disponible';

      // Guardar el escaneo en Firestore a través de ScanService
      await _scanService.guardarEscaneo(
        tipoEnfermedad: tipo,
        descripcion: descripcion,
        fechaEscaneo: now,
        urlImagen: downloadUrl, // Usando la URL placeholder
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
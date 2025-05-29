import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Guarda un escaneo en Firestore asociado al usuario actual
  Future<void> guardarEscaneo({
    required String tipoEnfermedad,
    required String descripcion,
    required DateTime fechaEscaneo,
    required String urlImagen, // URL de la imagen subida a Firebase Storage
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

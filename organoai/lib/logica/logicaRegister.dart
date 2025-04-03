import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Registro con email y contraseña
  Future<User?> registerWithEmail(String email, String password) async {
    try {
      // 1. Crear usuario en Firebase Auth
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Guardar datos adicionales en Firestore (opcional)
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(
          e.code, e.message)); // Manejo específico de errores de Firebase Auth
    } catch (e) {
      throw Exception(
          'Error inesperado: ${e.toString()}'); // Manejo de otros errores inesperados
    }
  }

  // Manejo de errores de Firebase Auth
  String _handleAuthError(String code, String? message) {
    switch (code) {
      case 'weak-password':
        return 'La contraseña es muy débil.';
      case 'email-already-in-use':
        return 'El correo ya está registrado.';
      case 'invalid-email':
        return 'Correo electrónico inválido.';
      case 'operation-not-allowed':
        return 'Operación no permitida. Contacte con soporte.';
      case 'network-request-failed':
        return 'Error de red. Verifique su conexión a internet.';
      default:
        return 'Error desconocido: $message';
    }
  }
}

import 'package:firebase_auth/firebase_auth.dart';

// Registro con email y contraseña
Future<User?> registerWithEmail(String email, String password) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    return userCredential.user;
  } on FirebaseAuthException catch (e) {
    print('Error de registro: ${e.message}');
    return null;
  }
}

// Inicio de sesión
Future<User?> signInWithEmail(String email, String password) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    return userCredential.user;
  } on FirebaseAuthException catch (e) {
    print('Error de inicio de sesión: ${e.message}');
    return null;
  }
}
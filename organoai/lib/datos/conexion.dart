import 'package:cloud_firestore/cloud_firestore.dart';

// Escribir datos
Future<void> addUser(String name, String email) async {
  await FirebaseFirestore.instance.collection('users').add({
    'name': name,
    'email': email,
    'createdAt': FieldValue.serverTimestamp(),
  });
}

// Leer datos
Stream<QuerySnapshot> getUsers() {
  return FirebaseFirestore.instance.collection('users').snapshots();
}

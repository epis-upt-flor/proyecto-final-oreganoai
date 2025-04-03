import 'package:flutter/material.dart';
import 'package:organoai/vista/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'vista/foto.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
      routes: {
        '/foto': (context) => PhotoGallery(), // Asegúrate de importar foto.dart
      },
    );
  }
}

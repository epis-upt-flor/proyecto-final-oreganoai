import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'foto.dart';
import 'historial.dart';
import 'configuracion.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _nuevaContrasenaController =
      TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    cargarDatosUsuario();
  }

  Future<void> cargarDatosUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        setState(() {
          _nombreController.text = doc['nombre'] ?? '';
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _guardarCambios() async {
    final nuevoNombre = _nombreController.text.trim();
    final nuevaContrasena = _nuevaContrasenaController.text.trim();
    final user = FirebaseAuth.instance.currentUser;

    try {
      if (nuevoNombre.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user!.uid)
            .update({
          'nombre': nuevoNombre,
        });
      }

      if (nuevaContrasena.isNotEmpty) {
        await user!.updatePassword(nuevaContrasena);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cambios guardados exitosamente.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _nuevaContrasenaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Mi Perfil'),
        backgroundColor: Colors.green[700],
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nombre:', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nombreController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Ingresa tu nombre',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Nueva Contraseña:',
                      style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nuevaContrasenaController,
                    obscureText: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Ingresa nueva contraseña',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 12),
                      ),
                      onPressed: _guardarCambios,
                      child: const Text('Guardar Cambios'),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // Cambia el índice si es necesario
        onTap: (index) {
          switch (index) {
            case 0:
              // Navegar a la página Historial
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HistorialPage()),
              );
              break;
            case 1:
              // Navegar a la página de Tomar Foto
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const PhotoGallery()),
              );
              break;
            case 2:
              // Navegar a la página de Perfil
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const PerfilPage()),
              );
              break;
            case 3:
              // Navegar a la página de Configuración
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
              break;
          }
        },
        backgroundColor: Colors.white,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.history), label: "Historial"),
          BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt), label: "Tomar Foto"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: "Configuración"),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../logica/logicaSesion.dart'; // Importa la clase AuthService
import '../logica/logicaNotificaciones.dart'; // Importa NotificacionesService
import 'foto.dart';
import 'historial.dart';
import 'perfil.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  final AuthService _authService = AuthService.instance; // Usando Singleton
  final NotificacionesService _notificacionesService =
      NotificacionesService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title:
            const Text('Configuración', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.green[700],
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Notificaciones',
                style: TextStyle(color: Colors.black)),
            value: _notificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                _notificationsEnabled = value;
                _notificacionesService.setNotificationsEnabled(value);
              });
            },
            activeColor: Colors.black54,
          ),
          ListTile(
            title:
                const Text('Contacto', style: TextStyle(color: Colors.black)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Eliminar cuenta',
                style: TextStyle(color: Colors.black)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black),
            onTap: () => _authService.handleDeleteAccount(context),
          ),
          ListTile(
            title: const Text('Cerrar sesión',
                style: TextStyle(color: Colors.black)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black),
            onTap: () => _authService.handleLogout(context),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3, // Cambia el índice si es necesario
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

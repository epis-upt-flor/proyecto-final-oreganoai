// configuracion.dart
import 'package:flutter/material.dart';
import '../logica/logicaSesion.dart'; // Importa la clase AuthService

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  final AuthService _authService = AuthService(); // Instancia de AuthService

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración', style: TextStyle(color: Colors.black)),
        backgroundColor: const Color(0xFFF5F5DC),
        elevation: 0,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Notificaciones', style: TextStyle(color: Colors.black)),
            value: _notificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
            activeColor: Colors.black54,
          ),
          ListTile(
            title: const Text('Contacto', style: TextStyle(color: Colors.black)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Eliminar cuenta', style: TextStyle(color: Colors.black)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black),
            onTap: () => _authService.handleDeleteAccount(context),
          ),
          ListTile(
            title: const Text('Cerrar sesión', style: TextStyle(color: Colors.black)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black),
            onTap: () => _authService.handleLogout(context),
          ),
        ],
      ),
    );
  }
}
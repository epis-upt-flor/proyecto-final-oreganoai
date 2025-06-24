import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:organoai/logica/logicaConfiguracion.dart';
import 'foto.dart';
import 'historial.dart';
import 'perfil.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsViewModel(),
      child: Consumer<SettingsViewModel>(
        builder: (context, viewModel, _) => Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('Configuración',
                style: TextStyle(color: Colors.black)),
            backgroundColor: Colors.green[700],
            centerTitle: true,
            elevation: 0,
          ),
          body: ListView(
            children: [
              SwitchListTile(
                title: const Text('Notificaciones',
                    style: TextStyle(color: Colors.black)),
                value: viewModel.notificationsEnabled,
                onChanged: viewModel.toggleNotifications,
                activeColor: Colors.black54,
              ),
              ListTile(
                title: const Text('Contacto',
                    style: TextStyle(color: Colors.black)),
                trailing:
                    const Icon(Icons.arrow_forward_ios, color: Colors.black),
                onTap: () {},
              ),
              ListTile(
                title: const Text('Eliminar cuenta',
                    style: TextStyle(color: Colors.black)),
                trailing:
                    const Icon(Icons.arrow_forward_ios, color: Colors.black),
                onTap: () => viewModel.deleteAccount(context),
              ),
              ListTile(
                title: const Text('Cerrar sesión',
                    style: TextStyle(color: Colors.black)),
                trailing:
                    const Icon(Icons.arrow_forward_ios, color: Colors.black),
                onTap: () => viewModel.logout(context),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 3,
            onTap: (index) {
              Widget? destination;
              switch (index) {
                case 0:
                  destination = const HistorialPage();
                  break;
                case 1:
                  destination = const PhotoGallery();
                  break;
                case 2:
                  destination = const PerfilPage();
                  break;
                case 3:
                  destination = const SettingsScreen();
                  break;
              }
              if (destination != null) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => destination!),
                );
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
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: "Perfil"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings), label: "Configuración"),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'configuracion.dart';

import '../logica/logicaNotificaciones.dart'; // ajusta el path según tu proyecto

final NotiService notiService = NotiService();

class PhotoGallery extends StatefulWidget {
  const PhotoGallery({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _PhotoGalleryState createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends State<PhotoGallery> {
  final List<File> _images = []; // Lista para almacenar múltiples imágenes
  final ImagePicker _picker = ImagePicker();

  // Método para seleccionar imágenes desde la galería
  Future<void> _pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _images.addAll(pickedFiles.map((file) => File(file.path)));
      });
    }
  }

  // Método para tomar una foto con la cámara
  Future<void> _takePhoto() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  // Método para redirigir a la vista de escaneo
  void _scanImages() {
    if (_images.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScanResultsPage(images: _images),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No hay imágenes para escanear")),
      );
    }
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Lógica para Historial
        break;
      case 1:
        _takePhoto();
        break;
      case 2:
        // Lógica para Perfil
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Galería"),
        backgroundColor: Colors.green[700],
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green[400]!, Colors.green[900]!],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: _images.isEmpty
                  ? Center(
                      child: Text("No hay imágenes seleccionadas",
                          style: TextStyle(color: Colors.black)),
                    )
                  : GridView.builder(
                      padding: EdgeInsets.all(10),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Muestra 2 imágenes por fila
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _images.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Image.file(_images[index], fit: BoxFit.cover),
                            Positioned(
                              top: 5,
                              right: 5,
                              child: IconButton(
                                icon: Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _images.removeAt(index);
                                  });
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImages,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green[700],
              ),
              child: Text("Subir Imágenes"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                _scanImages(); // tu lógica original

                // Mostrar notificación
                await notiService.showNotification(
                  title: 'Escaneo iniciado',
                  body: 'Estamos analizando las imágenes...',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text("Escanear"),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(color: Colors.black),
        unselectedLabelStyle: const TextStyle(color: Colors.black),
        currentIndex: _selectedIndex,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.history), label: 'Historial'),
          BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt), label: 'Tomar Foto'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Configuración'),
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}

// Pantalla para mostrar los resultados del escaneo
class ScanResultsPage extends StatelessWidget {
  final List<File> images;

  const ScanResultsPage({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Resultados del Escaneo")),
      body: ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(vertical: 10),
            elevation: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.file(images[index]),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Nombre de la enfermedad: Roya",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      Text("Fecha de captura: 03/04/2025"),
                      SizedBox(height: 5),
                      Text(
                          "Descripción: La roya en las hojas de orégano es causada por un hongo llamado Puccinia menthae. Este hongo se desarrolla en condiciones húmedas y calurosas, como en la primavera, el verano y el otoño."),
                      SizedBox(height: 5),
                      Text(
                          "Tratamiento: Para tratar la roya en las hojas de orégano, se pueden usar fungicidas, purín de ortiga, cola de caballo, o aceites de neem."),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

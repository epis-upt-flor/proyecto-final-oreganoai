import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'perfil.dart';
import 'configuracion.dart';
import 'historial.dart';
import '../datos/escaneos_memoria.dart';

class PhotoGallery extends StatefulWidget {
  const PhotoGallery({super.key});

  @override
  State<PhotoGallery> createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends State<PhotoGallery> {
  final List<File> _images = [];
  final ImagePicker _picker = ImagePicker();
  int _selectedIndex = 1; // Empieza en "Tomar Foto"

  // Método para tomar una foto
  Future<void> _takePhoto() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  // Método para seleccionar imágenes de la galería
  Future<void> _pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _images.addAll(pickedFiles.map((file) => File(file.path)));
      });
    }
  }

  // Método para escanear imágenes
  // Modificación del método _scanImages
  void _scanImages() {
    if (_images.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text("Resultados del Escaneo")),
            body: ScanResultsPage(images: _images),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No hay imágenes para escanear")),
      );
    }
  }

  // Navegación inferior
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HistorialPage()),
        );
        break;
      case 1:
        // Se queda aquí y abre la cámara
        _takePhoto(); // Aquí se abre la cámara al seleccionar "Tomar Foto"
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const PerfilPage(nombreUsuario: 'Marcelo')),
        );
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
        automaticallyImplyLeading: false,
        title: const Text("Tomar Foto"),
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
                  ? const Center(
                      child: Text("No hay imágenes aún",
                          style: TextStyle(color: Colors.black)),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(10),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
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
                                icon:
                                    const Icon(Icons.close, color: Colors.red),
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImages,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green[700],
              ),
              child: const Text("Subir desde galería"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _scanImages,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text("Escanear"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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

// Página vacía para Historial
class EmptyHistorialPage extends StatelessWidget {
  const EmptyHistorialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historial"),
        backgroundColor: Colors.green[700],
      ),
      body: const Center(
        child: Text("No hay historial aún."),
      ),
    );
  }
}

// Página para mostrar resultados de escaneo
class ScanResultsPage extends StatelessWidget {
  final List<File> images;

  const ScanResultsPage({super.key, required this.images});

  String _obtenerFechaActual() {
    final ahora = DateTime.now();
    return "${ahora.day.toString().padLeft(2, '0')}/${ahora.month.toString().padLeft(2, '0')}/${ahora.year}";
  }

  void _guardarEscaneos(BuildContext context) {
    final fecha = _obtenerFechaActual();

    for (var image in images) {
      listaEscaneos.add(
        Escaneo(
          imagen: image,
          enfermedad: 'Roya',
          fecha: fecha,
          descripcion: 'Hongo Puccinia menthae...',
          tratamiento: 'Fungicidas, ortiga, neem...',
        ),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Escaneos guardados en el historial.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  elevation: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.file(images[index]),
                      const Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Nombre de la enfermedad: Roya",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 5),
                            Text("Fecha de captura: Ahora mismo"),
                            SizedBox(height: 5),
                            Text("Descripción: Hongo Puccinia menthae..."),
                            SizedBox(height: 5),
                            Text("Tratamiento: Fungicidas, ortiga, neem..."),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton.icon(
              onPressed: () => _guardarEscaneos(context),
              label: const Text("Guardar"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

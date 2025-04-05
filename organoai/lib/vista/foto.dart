
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PhotoGallery extends StatefulWidget {
  const PhotoGallery({super.key});
  @override
  _PhotoGalleryState createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends State<PhotoGallery> {
  List<File> _images = []; // Lista para almacenar múltiples imágenes
  final ImagePicker _picker = ImagePicker();

  // Método para seleccionar imágenes desde la galería
  Future<void> _pickImages() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
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
              child: Text("Subir Imágenes"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green[700],
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _scanImages,
              child: Text("Escanear"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
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
        selectedLabelStyle: TextStyle(color: Colors.black),
        unselectedLabelStyle: TextStyle(color: Colors.black),
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.history), label: 'Historial'),
          BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt), label: 'Tomar Foto'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Configuración'),
        ],
        onTap: (index) {
          if (index == 1) {
            _takePhoto();
          }
        },
      ),
    );
  }
}

// Pantalla para mostrar los resultados del escaneo
class ScanResultsPage extends StatelessWidget {
  final List<File> images;

  ScanResultsPage({required this.images});

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
=======
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PhotoGallery extends StatefulWidget {
  const PhotoGallery({super.key});

  @override
  _PhotoGalleryState createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends State<PhotoGallery> {
  final List<File> _images = []; // Lista para almacenar múltiples imágenes
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages(ImageSource source) async {
    final pickedFile =
        await _picker.pickImage(source: source); // Abre cámara o galería

    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path)); // Agrega la imagen a la lista
      });
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
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                    )
                  : GridView.builder(
                      padding: EdgeInsets.all(10),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // Número de imágenes por fila
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _images.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                _images[index],
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              right: 5,
                              top: 5,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _images.removeAt(index);
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black54,
                                  ),
                                  padding: EdgeInsets.all(5),
                                  child: Icon(Icons.close,
                                      color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
            ElevatedButton(
              onPressed: () => _pickImages(ImageSource.gallery),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green[700],
              ),
              child: Text("Subir Imágenes"),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(color: Colors.black),
        unselectedLabelStyle: TextStyle(color: Colors.black),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Escaneos'),
          BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt), label: 'Tomar Foto'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Configuración'),
        ],
        onTap: (index) {
          if (index == 1) {
            // Si presiona "Tomar Foto"
            _pickImages(ImageSource.camera); // Abre la cámara
          }
        },
      ),
    );
  }
}


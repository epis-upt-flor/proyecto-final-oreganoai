import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PhotoGallery extends StatefulWidget {
  @override
  _PhotoGalleryState createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends State<PhotoGallery> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _image == null
                  ? Text(
                    "No hay imagen seleccionada",
                    style: TextStyle(color: Colors.black),
                  )
                  : Image.file(_image!),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _pickImage(ImageSource.gallery),
                child: Text("Subir Imagen"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green[700],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton:
          _image != null
              ? FloatingActionButton(
                backgroundColor: Colors.black54,
                child: Icon(Icons.close, color: Colors.black),
                onPressed: () {
                  setState(() {
                    _image = null;
                  });
                },
              )
              : null,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          color: Colors.black,
        ), // Texto seleccionado en negro
        unselectedLabelStyle: TextStyle(color: Colors.black),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Escaneos'),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Tomar Foto',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configuración',
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            _pickImage(ImageSource.camera);
          }
        },
      ),
    );
  }
}

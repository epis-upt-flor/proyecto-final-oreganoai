// lib/vista/foto.dart (VISTA)
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../logica/logicaFoto.dart';
import 'historial.dart';
import 'perfil.dart';
import 'configuracion.dart';

class PhotoGallery extends StatelessWidget {
  const PhotoGallery({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LogicaFoto>(context);

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
              child: viewModel.images.isEmpty
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
                      itemCount: viewModel.images.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Image.file(viewModel.images[index],
                                fit: BoxFit.cover),
                            Positioned(
                              top: 5,
                              right: 5,
                              child: IconButton(
                                icon:
                                    const Icon(Icons.close, color: Colors.red),
                                onPressed: () =>
                                    viewModel.eliminarImagen(index),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: viewModel.pickImages,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green[700],
              ),
              child: const Text("Subir desde galería"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => viewModel.scanImages(context),
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
        currentIndex: 1,
        onTap: (index) => viewModel.onItemTapped(context, index),
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

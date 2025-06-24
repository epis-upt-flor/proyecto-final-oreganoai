import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logica/logicaHistorial.dart';
import 'foto.dart';
import 'perfil.dart';
import 'configuracion.dart';
import 'detalle_escaneo.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:organoai/datos/modeloDetalle_Escaneo.dart';

class HistorialPage extends StatelessWidget {
  const HistorialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HistorialViewModel(),
      child: Consumer<HistorialViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: const Text("Historial de Escaneos"),
              backgroundColor: Colors.green[700],
              centerTitle: true,
            ),
            body: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Buscar por fecha (dd/mm/aaaa)',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: viewModel.actualizarFiltroFecha,
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: DropdownButtonFormField<String>(
                    value: viewModel.filtroEnfermedad,
                    decoration: InputDecoration(
                      labelText: 'Filtrar por enfermedad',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: viewModel.enfermedades
                        .map((enf) =>
                            DropdownMenuItem(value: enf, child: Text(enf)))
                        .toList(),
                    onChanged: viewModel.actualizarFiltroEnfermedad,
                  ),
                ),
                Expanded(
                  child: StreamBuilder<Map<String, List<Map<String, dynamic>>>>(
                    stream: viewModel.escaneosAgrupadosStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                            child: Text("No hay escaneos registrados."));
                      }
                      final agrupado = snapshot.data!;
                      return agrupado.isEmpty
                          ? const Center(
                              child: Text("No hay escaneos que coincidan."))
                          : ListView(
                              padding: const EdgeInsets.all(10),
                              children: agrupado.entries.map((entry) {
                                final fecha = entry.key;
                                final escaneos = entry.value;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      fecha,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    ...escaneos.map((e) => Card(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          elevation: 4,
                                          child: ListTile(
                                            contentPadding:
                                                const EdgeInsets.all(10),
                                            leading: e['urlImagen'] != null &&
                                                    (e['urlImagen'] as String)
                                                        .isNotEmpty
                                                ? NetworkImageByHttp(
                                                    url: e['urlImagen'],
                                                    width: 70,
                                                    height: 70,
                                                  )
                                                : const Icon(
                                                    Icons.image_not_supported),
                                            title: Text(
                                              e['tipoEnfermedad'] ?? '',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text("Fecha: $fecha"),
                                                Text(
                                                  "Descripción: ${e['descripcion'] ?? ''}",
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                    "Tratamiento: ${e['tratamiento'] ?? 'No disponible'}"),
                                              ],
                                            ),
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      DetalleEscaneoPage(
                                                    escaneo: EscaneoDetalle(
                                                      tipoEnfermedad:
                                                          e['tipoEnfermedad'] ??
                                                              '',
                                                      descripcion:
                                                          e['descripcion'] ??
                                                              '',
                                                      tratamiento:
                                                          e['tratamiento'] ??
                                                              'No disponible',
                                                      urlImagen:
                                                          e['urlImagen'] ?? '',
                                                      fecha: fecha,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        )),
                                    const SizedBox(height: 20),
                                  ],
                                );
                              }).toList(),
                            );
                    },
                  ),
                ),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: 0,
              onTap: (index) {
                switch (index) {
                  case 0:
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HistorialPage()),
                    );
                    break;
                  case 1:
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PhotoGallery()),
                    );
                    break;
                  case 2:
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PerfilPage()),
                    );
                    break;
                  case 3:
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsScreen()),
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
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), label: "Perfil"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.settings), label: "Configuración"),
              ],
            ),
          );
        },
      ),
    );
  }
}

class NetworkImageByHttp extends StatelessWidget {
  final String url;
  final double width;
  final double height;

  const NetworkImageByHttp({
    required this.url,
    this.width = 70,
    this.height = 70,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _fetchImageBytes(url),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            width: width,
            height: height,
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Icon(Icons.broken_image, size: width, color: Colors.red);
        }
        return Image.memory(
          snapshot.data!,
          width: width,
          height: height,
          fit: BoxFit.cover,
        );
      },
    );
  }

  Future<Uint8List> _fetchImageBytes(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Error al cargar la imagen');
    }
  }
}

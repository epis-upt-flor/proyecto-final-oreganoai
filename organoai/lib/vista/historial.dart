import 'package:flutter/material.dart';
import 'dart:io';
import '../datos/escaneos_memoria.dart';
import 'package:organoai/vista/foto.dart';
import 'package:organoai/vista/perfil.dart';
import 'package:organoai/vista/configuracion.dart';

class HistorialPage extends StatefulWidget {
  const HistorialPage({super.key});

  @override
  State<HistorialPage> createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialPage> {
  String _filtroFecha = '';
  String _filtroEnfermedad = 'Todas';

  final List<String> enfermedades = [
    'Todas',
    'Roya',
    'Mosca blanca',
    'Trips',
    'Araña Roja',
  ];

  @override
  Widget build(BuildContext context) {
    // Agrupar escaneos por fecha con filtros
    final Map<String, List<Escaneo>> escaneosPorFecha = {};
    for (var escaneo in listaEscaneos) {
      final cumpleFecha =
          _filtroFecha.isEmpty || escaneo.fecha.contains(_filtroFecha);
      final cumpleEnfermedad = _filtroEnfermedad == 'Todas' ||
          escaneo.enfermedad == _filtroEnfermedad;

      if (cumpleFecha && cumpleEnfermedad) {
        escaneosPorFecha.putIfAbsent(escaneo.fecha, () => []).add(escaneo);
      }
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Historial de Escaneos'),
        backgroundColor: Colors.green[700],
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _filtroFecha = '';
                _filtroEnfermedad = 'Todas';
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtro por fecha
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
              onChanged: (value) {
                setState(() {
                  _filtroFecha = value.trim();
                });
              },
            ),
          ),

          // Filtro por enfermedad
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: DropdownButtonFormField<String>(
              value: _filtroEnfermedad,
              decoration: InputDecoration(
                labelText: 'Filtrar por enfermedad',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              items: enfermedades
                  .map((enf) => DropdownMenuItem(value: enf, child: Text(enf)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _filtroEnfermedad = value!;
                });
              },
            ),
          ),

          // Lista de escaneos
          Expanded(
            child: escaneosPorFecha.isEmpty
                ? const Center(child: Text("No hay escaneos que coincidan."))
                : ListView(
                    padding: const EdgeInsets.all(10),
                    children: escaneosPorFecha.entries.map((entry) {
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
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                elevation: 4,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(10),
                                  leading: Image.file(
                                    e.imagen,
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                  ),
                                  title: Text(
                                    e.enfermedad,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Fecha: ${e.fecha}"),
                                      Text("Descripción: ${e.descripcion}"),
                                      Text("Tratamiento: ${e.tratamiento}"),
                                    ],
                                  ),
                                ),
                              )),
                          const SizedBox(height: 20),
                        ],
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Cambia el índice si es necesario
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
                MaterialPageRoute(
                    builder: (context) =>
                        const PerfilPage(nombreUsuario: 'Marcelo')),
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

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'foto.dart';
import 'perfil.dart';
import 'configuracion.dart';

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
    'Desconocida',
    'Oidium',
    'Royas',
    'Manchas foliares'
  ];

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Center(child: Text("Usuario no autenticado."));
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Historial de Escaneos"),
        backgroundColor: Colors.green[700],
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('escaneos')
            .orderBy('fechaEscaneo', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No hay escaneos registrados."));
          }

          // Filtrar y agrupar escaneos
          final docsFiltrados = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final fecha = (data['fechaEscaneo'] as Timestamp).toDate();
            final fechaStr =
                "${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}";
            final tipoEnfermedad = data['tipoEnfermedad'] ?? '';

            final cumpleFecha =
                _filtroFecha.isEmpty || fechaStr.contains(_filtroFecha);
            final cumpleEnfermedad = _filtroEnfermedad == 'Todas' ||
                tipoEnfermedad == _filtroEnfermedad;

            return cumpleFecha && cumpleEnfermedad;
          }).toList();

          // Agrupar por fecha
          final Map<String, List<Map<String, dynamic>>> agrupado = {};
          for (var doc in docsFiltrados) {
            final data = doc.data() as Map<String, dynamic>;
            final fecha = (data['fechaEscaneo'] as Timestamp).toDate();
            final fechaStr =
                "${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}";

            agrupado.putIfAbsent(fechaStr, () => []).add(data);
          }

          return Column(
            children: [
              // Filtro por fecha
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
                  onChanged: (value) {
                    setState(() {
                      _filtroFecha = value.trim();
                    });
                  },
                ),
              ),

              // Filtro por enfermedad
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                      .map((enf) =>
                          DropdownMenuItem(value: enf, child: Text(enf)))
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
                child: agrupado.isEmpty
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
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    elevation: 4,
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.all(10),
                                      leading: e['urlImagen'] != null
                                          ? NetworkImageByHttp(
                                              url: e['urlImagen'] ?? '',
                                              width: 70,
                                              height: 70,
                                            )
                                          : const Icon(
                                              Icons.image_not_supported),
                                      title: Text(
                                        e['tipoEnfermedad'] ?? '',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("Fecha: $fecha"),
                                          Text(
                                              "Descripción: ${e['descripcion'] ?? ''}"),
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
          );
        },
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

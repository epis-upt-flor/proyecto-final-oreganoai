import 'package:flutter/material.dart';
import 'foto.dart';
import 'historial.dart';
import 'perfil.dart';
import 'configuracion.dart';

class DetalleEscaneoPage extends StatelessWidget {
  final String tipoEnfermedad;
  final String descripcion;
  final String urlImagen;
  final String fecha;
  final String tratamiento;

  const DetalleEscaneoPage({
    super.key,
    required this.tipoEnfermedad,
    required this.descripcion,
    required this.urlImagen,
    required this.fecha,
    required this.tratamiento,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Escaneo'),
        backgroundColor: Colors.green[700],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(urlImagen, height: 250),
            ),
            const SizedBox(height: 20),
            Text("Fecha: $fecha", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text("Tipo de Enfermedad:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(tipoEnfermedad, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text("Descripción:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(descripcion, style: const TextStyle(fontSize: 16)),
            Text("Tratamiento:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(tratamiento, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

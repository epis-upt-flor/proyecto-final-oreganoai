import 'package:flutter/material.dart';
import 'package:organoai/datos/modeloDetalle_Escaneo.dart';

class DetalleEscaneoPage extends StatelessWidget {
  final EscaneoDetalle escaneo;

  const DetalleEscaneoPage({super.key, required this.escaneo});

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
            Center(child: Image.network(escaneo.urlImagen, height: 250)),
            const SizedBox(height: 20),
            Text("Fecha: ${escaneo.fecha}",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text("Tipo de Enfermedad:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(escaneo.tipoEnfermedad, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text("Descripción:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(escaneo.descripcion, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text("Tratamiento:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(escaneo.tratamiento, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

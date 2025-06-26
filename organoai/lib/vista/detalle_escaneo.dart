import 'package:flutter/material.dart';
import 'package:organoai/datos/modeloDetalle_Escaneo.dart';

class DetalleEscaneoPage extends StatelessWidget {
  final EscaneoDetalle escaneo;

  const DetalleEscaneoPage({super.key, required this.escaneo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: const Column(
          children: [
            Icon(Icons.eco, size: 30, color: Color(0xFF1DB954)),
            SizedBox(height: 2),
            Text(
              'OreganoAI',
              style: TextStyle(
                color: Color(0xFF1DB954),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  escaneo.urlImagen,
                  height: 230,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSection("Fecha:", escaneo.fecha),
            const SizedBox(height: 12),
            _buildSection("Tipo de Enfermedad:", escaneo.tipoEnfermedad),
            const SizedBox(height: 12),
            _buildSection("Descripción:", escaneo.descripcion),
            const SizedBox(height: 12),
            _buildSection("Tratamiento:", escaneo.tratamiento),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }
}

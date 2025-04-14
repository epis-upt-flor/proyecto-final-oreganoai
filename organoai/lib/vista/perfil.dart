import 'package:flutter/material.dart';

class PerfilPage extends StatefulWidget {
  final String nombreUsuario;

  const PerfilPage({super.key, required this.nombreUsuario});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  late TextEditingController _nombreController;
  late TextEditingController _nuevaContrasenaController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.nombreUsuario);
    _nuevaContrasenaController = TextEditingController();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _nuevaContrasenaController.dispose();
    super.dispose();
  }

  void _guardarCambios() {
    final nuevoNombre = _nombreController.text.trim();
    final nuevaContrasena = _nuevaContrasenaController.text.trim();

    // Aquí podrías guardar estos datos en Firebase o tu base de datos
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cambios guardados.')),
    );

    // Aquí podrías hacer algo como:
    // await FirebaseAuth.instance.currentUser!.updatePassword(nuevaContrasena);
    // await actualizarNombreEnFirestore(nuevoNombre);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: Colors.green[700],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nombre:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Ingresa tu nombre',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Nueva Contraseña:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _nuevaContrasenaController,
              obscureText: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Ingresa nueva contraseña',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                onPressed: _guardarCambios,
                child: const Text('Guardar Cambios'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

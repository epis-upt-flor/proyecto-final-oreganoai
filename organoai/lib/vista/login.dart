import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        backgroundColor: Color(0xFFCFDB58),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 12),
              Center(
                child: Text(
                  'OreganoAI: Diagnosticos de cultivos de oregano',
                  style: TextStyle(
                    color: Color(0xFF4A6B3D),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 40),
              _buildSocialButton(
                icon: Icons.g_mobiledata,
                text: 'Continuar con Google',
                color: Colors.black,
              ),
              SizedBox(height: 24),
              Row(children: [
                Expanded(child: Divider(color: Colors.grey[700])),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('O', style: TextStyle(color: Colors.grey)),
                ),
                Expanded(child: Divider(color: Colors.grey[700])),
              ]),
              SizedBox(height: 24),
              _buildInputField('Correo electrónico o nombre de usuario'),
              SizedBox(height: 16),
              _buildInputField('Contraseña', isPassword: true),
              SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1DB954),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {},
                child: Text('Iniciar sesión'),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () {},
                child: Text('¿Se te ha olvidado la contraseña?',
                    style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('¿No tienes cuenta? ',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(
      {IconData? icon,
      String? text,
      bool isSelected = false,
      required Color color}) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? Color(0xFF60DC58) : Colors.transparent,
        side: BorderSide(color: Colors.grey[700]!),
        padding: EdgeInsets.symmetric(vertical: 16),
      ),
      onPressed: () {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? Colors.white : Colors.grey),
          SizedBox(width: 8),
          Text(text!,
              style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildInputField(String hint, {bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color.fromARGB(255, 255, 255, 255),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

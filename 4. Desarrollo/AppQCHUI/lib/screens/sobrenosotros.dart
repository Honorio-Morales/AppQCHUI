import 'package:flutter/material.dart';

void main() {
  runApp(const QchuiApp());
}

class QchuiApp extends StatelessWidget {
  const QchuiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QCHUI App',
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: 'Roboto',
      ),
      home: const AboutUsPage(),
    );
  }
}

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.red),
          onPressed: () {
            // Navigate back
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // About Us Section
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sobre\nNosotros',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Somos un equipo apasionado por la programación y el aprendizaje del idioma quechua, comprometidos con la preservación y difusión de nuestra cultura ancestral.',
                    style: TextStyle(
                      fontSize: 16, 
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'DONA YA! :)',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Building Image
            const SizedBox(height: 20),
            Image.asset(
              'assets/building.png', // You'll need to add this asset
              height: 150,
              fit: BoxFit.contain,
            ),
            
            // Logo Section
            const SizedBox(height: 30),
            const CircularLogoSection(),
            
            // Enjoy Section
            const SizedBox(height: 15),
            const Text(
              'Disfruta con QCHUI',
              style: TextStyle(
                fontSize: 22,
                color: Colors.redAccent,
                fontWeight: FontWeight.w500,
              ),
            ),
            
            // Feedback Section
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const Text(
                    'Te gusto la aplicacion?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Dejanos tu correo electronico para poder contactar con el equipo de QCHUI.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 25),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Ingresa tu correo electronico',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'ENVIAR',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Ya somos mas de ',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const Text(
                        '100+ ',
                        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'usuarios, ayudanos a mejorar la aplicacion',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Footer
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Column(
                children: [
                  const Text(
                    '©2025 QCHUI. Derechos reservados',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SocialIcon(Icons.facebook),
                      SocialIcon(Icons.camera_alt),
                      SocialIcon(Icons.public),
                      SocialIcon(Icons.work),
                    ],
                  ),
                ],
              ),
            ),
            
            // Bottom Navigation
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.redAccent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            NavItem(icon: Icons.home, label: 'Inicio'),
            NavItem(icon: Icons.book, label: 'Diccionario'),
            NavItem(icon: Icons.favorite, label: 'Favoritos'),
            NavItem(icon: Icons.info, label: 'Sobre nosotros', isSelected: true),
            NavItem(icon: Icons.monetization_on, label: 'Donación'),
          ],
        ),
      ),
    );
  }
}

class CircularLogoSection extends StatelessWidget {
  const CircularLogoSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 180,
          height: 180,
          child: Stack(
            children: [
              const Center(
                child: Text(
                  'USA EL QUECHUA',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
              ),
              RotatedBox(
                quarterTurns: 1,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.transparent),
                  ),
                  child: CircularText(
                    radius: 90,
                    text: 'USA EL QUECHUA',
                    textStyle: const TextStyle(
                      fontSize: 10,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Column(
          children: const [
            Text(
              'QCHUI',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
                letterSpacing: 1,
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: 30,
              height: 30,
              child: CircleAvatar(
                backgroundColor: Colors.brown,
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// This is a simplified version - a real implementation would use 
// path_drawing or other libraries for proper circular text
class CircularText extends StatelessWidget {
  final String text;
  final double radius;
  final TextStyle textStyle;

  const CircularText({
    Key? key,
    required this.text,
    required this.radius,
    required this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CircularTextPainter(
        text: text,
        radius: radius,
        textStyle: textStyle,
      ),
    );
  }
}

class CircularTextPainter extends CustomPainter {
  final String text;
  final double radius;
  final TextStyle textStyle;

  CircularTextPainter({
    required this.text,
    required this.radius,
    required this.textStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    
    // In a real implementation, you would calculate positions for each character
    // around the circle. This is simplified.
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class SocialIcon extends StatelessWidget {
  final IconData icon;
  
  const SocialIcon(this.icon, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Icon(
        icon,
        color: Colors.grey,
        size: 20,
      ),
    );
  }
}

class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  
  const NavItem({
    Key? key,
    required this.icon,
    required this.label,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 22,
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
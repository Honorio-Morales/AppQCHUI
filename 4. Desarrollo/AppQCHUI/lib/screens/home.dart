import 'package:flutter/material.dart';

void main() {
  runApp(QchuiApp());
}

class QchuiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFFE94B4B),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
      ),
      home: QchuiHomePage(),
    );
  }
}

class QchuiHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Logo header
          Container(
            padding: EdgeInsets.fromLTRB(20, 40, 20, 10),
            alignment: Alignment.center,
            child: Column(
              children: [
                // Logo with "USA EL QUECHUA" circular text
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "QCHUI",
                      style: TextStyle(
                        color: Color(0xFF6B4B35),
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 5),
                    Image.asset(
                      'assets/small_character.png', // Agregar ícono pequeño del personaje
                      height: 32,
                      width: 32,
                    ),
                  ],
                ),
                SizedBox(height: 8),
                // Reversed text for "Bienvenido, prueba todo ya!"
                Transform(
                  transform: Matrix4.rotationY(3.14159),
                  alignment: Alignment.center,
                  child: Text(
                    "Bienvenido, prueba todo ya!",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Emotions section
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Emotions",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.search, color: Colors.blue),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(Icons.translate, color: Colors.blue),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(Icons.volume_up, color: Colors.blue),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Description text
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "An emotion is a strong feeling, like the emotion you feel when you see your best friend at the movies with a group of people who cause trouble for you.",
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
          ),
          
          SizedBox(height: 20),
          
          // Category cards
          buildCategoryCard(
            context,
            icon: Icons.flight,
            iconColor: Colors.blue,
            title: "While Traveling",
          ),
          
          SizedBox(height: 12),
          
          buildCategoryCard(
            context,
            icon: Icons.medical_services,
            iconColor: Colors.red,
            title: "Help / Medical",
          ),
          
          SizedBox(height: 12),
          
          buildCategoryCard(
            context,
            icon: Icons.hotel,
            iconColor: Colors.amber,
            title: "At the Hotel",
          ),
          
          Spacer(),
          
          // Bottom navigation bar
          Container(
            height: 70,
            color: Color(0xFFE94B4B),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildNavBarItem(Icons.chat_bubble_outline, "Inicio"),
                buildNavBarItem(Icons.book, "Diccionario"),
                buildNavBarItem(Icons.person, "sobre nosotros"),
                buildNavBarItem(Icons.favorite_border_outlined, "Favoritos"),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget buildCategoryCard(BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        trailing: Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
  
  Widget buildNavBarItem(IconData icon, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:appchua/screens/home_screen.dart';

void main() {
  runApp(const TradduchuaApp());
}

class TradduchuaApp extends StatelessWidget {
  const TradduchuaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tradduchua',
      theme: ThemeData(
        primaryColor: Colors.green[700],
        scaffoldBackgroundColor: Colors.orange[100],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green[800],
          titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.brown, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      home: const TradduchuaHome(),
    );
  }
}

class TradduchuaHome extends StatelessWidget {
  const TradduchuaHome({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // 4 pestañas
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tradduchua'),
          bottom: const TabBar(
            indicatorColor: Colors.yellow,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            tabs: [
              Tab(icon: Icon(Icons.book), text: 'Diccionario'),
              Tab(icon: Icon(Icons.question_answer), text: 'Preguntas'),
              Tab(icon: Icon(Icons.people), text: 'Comunidad'),
              Tab(icon: Icon(Icons.info), text: 'Info'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            HomeScreen(), // Diccionario
            Center(child: Text("Sección de preguntas")),
            Center(child: Text("Comunidad")),
            Center(child: Text("Información sobre Tradduchua")),
          ],
        ),
      ),
    );
  }
}

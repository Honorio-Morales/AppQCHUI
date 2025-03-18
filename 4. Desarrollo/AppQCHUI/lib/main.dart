import 'package:flutter/material.dart';
import 'package:AppQCHUI/screens/home_screen.dart';
import 'package:AppQCHUI/screens/favorites_screen.dart';
import 'package:AppQCHUI/screens/questions_screen.dart';
import 'package:AppQCHUI/screens/comunity_screen.dart';
import 'package:AppQCHUI/screens/info_screen.dart';
import 'package:AppQCHUI/screens/home.dart';


void main() {
  runApp(const TradduchuaApp());
}
/// dasdsafasdsa dsadas angie aaqui
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

class TradduchuaHome extends StatefulWidget {
  const TradduchuaHome({super.key});

  @override
  _TradduchuaHomeState createState() => _TradduchuaHomeState();
}

class _TradduchuaHomeState extends State<TradduchuaHome> {
  final Set<String> favoritos = {};

  void _toggleFavorite(String palabra) {
    setState(() {
      if (favoritos.contains(palabra)) {
        favoritos.remove(palabra);
      } else {
        favoritos.add(palabra);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('QCHUI'),
          bottom: const TabBar(
            indicatorColor: Colors.yellow,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            tabs: [
              Tab(icon: Icon(Icons.book), text: 'Diccionario'),
              Tab(icon: Icon(Icons.favorite), text: 'Favoritos'),
              Tab(icon: Icon(Icons.question_answer), text: 'Preguntas'),
              Tab(icon: Icon(Icons.people), text: 'Comunidad'),
              Tab(icon: Icon(Icons.info), text: 'Info'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            HomeScreen(
              favoritos: favoritos,
              onToggleFavorite: _toggleFavorite,
            ),
            FavoritesScreen(
              favoritos: favoritos,
              onRemoveFavorite: _toggleFavorite,
            ),
            QuestionsScreen(),
            CommunityScreen(),
            InfoScreen(),
          ],
        ),
      ),
    );
  }
  ///////////////////////
}
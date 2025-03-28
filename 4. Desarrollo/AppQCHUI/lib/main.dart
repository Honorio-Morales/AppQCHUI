import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:AppQCHUI/screens/home_screen.dart';
import 'package:AppQCHUI/screens/dictionary_screen.dart';
import 'package:AppQCHUI/screens/favorites_screen.dart';
import 'package:AppQCHUI/screens/questions_screen.dart';
import 'package:AppQCHUI/screens/comunity_screen.dart';
import 'package:AppQCHUI/screens/info_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const TraduchuaApp());
}


class TraduchuaApp extends StatelessWidget {
  const TraduchuaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Traduchu',
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: const Color.fromARGB(255, 241, 221, 221),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFEE7072),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFFEE7072), // Color rojizo en la barra de navegación
          selectedItemColor: Colors.white, // Íconos seleccionados en blanco
          unselectedItemColor: Color.fromARGB(255, 72, 48, 49), // Íconos no seleccionados en tono más claro
        ),
      ),
      home: const MainNavigationWrapper(),
    );
  }
}

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  final Set<String> _favoritos = {};
  int _selectedIndex = 0;

  void _toggleFavorite(String palabra) {
    setState(() {
      if (_favoritos.contains(palabra)) {
        _favoritos.remove(palabra);
      } else {
        _favoritos.add(palabra);
      }
    });
  }

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(), // Pantalla de inicio
      DictionaryScreen( // Pantalla de diccionario
        favoritos: _favoritos,
        onToggleFavorite: _toggleFavorite,
      ),
      QuestionsScreen( // Pantalla de práctica
      ), 
      CommunityScreen( // Pantalla de comunidad
      ),
      FavoritesScreen( // Pantalla de favoritos
        favoritos: _favoritos,
        onRemoveFavorite: _toggleFavorite,
      ),
      const InfoScreen(), // Pantalla de información
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex != 0 
        ? AppBar(
            title: Row(
              children: [
                Image.asset(
                  'assets/images/qchui.png',
                  height: 60,
                  width: 60,
                ),
                const SizedBox(width: 10),
                const Text(
                  '',
                  style: TextStyle(
                    color: Colors.brown,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        : null,
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Diccionario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz),
            label: 'Preguntas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Comunidad',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Info',
          ),
        ],
      ),
    );
  }
}

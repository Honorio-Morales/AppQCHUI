import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:AppQCHUI/screens/home_screen.dart';
import 'package:AppQCHUI/screens/dictionary_screen.dart';
import 'package:AppQCHUI/screens/favorites_screen.dart';
import 'package:AppQCHUI/screens/questions_screen.dart';
import 'package:AppQCHUI/screens/comunity_screen.dart';
import 'package:AppQCHUI/screens/info_screen.dart';
import 'package:AppQCHUI/screens/login_screen.dart';
import 'package:AppQCHUI/screens/register_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
          backgroundColor: Color(0xFFEE7072),
          selectedItemColor: Colors.white,
          unselectedItemColor: Color.fromARGB(255, 72, 48, 49),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => AuthWrapper(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/main': (context) => const MainNavigationWrapper(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Mostrar pantalla de carga mientras verifica autenticación
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        // Usuario autenticado
        if (snapshot.hasData) {
          return const MainNavigationWrapper();
        }
        
        // Usuario no autenticado
        return const HomeScreen();
      },
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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _selectedIndex = 0;
  User? _currentUser;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    _auth.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() => _currentUser = user);
      }
    });
    
    _screens = [
      const HomeScreen(),
      DictionaryScreen(
        favoritos: _favoritos,
        onToggleFavorite: _toggleFavorite,
      ),
      QuestionsScreen(), 
      CommunityScreen(),
      FavoritesScreen(
        favoritos: _favoritos,
        onRemoveFavorite: _toggleFavorite,
      ),
      const InfoScreen(),
    ];
  }

  void _toggleFavorite(String palabra) {
    setState(() {
      if (_favoritos.contains(palabra)) {
        _favoritos.remove(palabra);
      } else {
        _favoritos.add(palabra);
      }
    });
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/',
        (route) => false,
      );
    }
  }

  Widget _buildUserAvatar() {
    if (_currentUser?.photoURL != null) {
      return CircleAvatar(
        backgroundImage: NetworkImage(_currentUser!.photoURL!),
      );
    }
    return CircleAvatar(
      backgroundColor: const Color(0xFFEE7072),
      child: _currentUser?.email != null
          ? Text(
              _currentUser!.email![0].toUpperCase(),
              style: const TextStyle(color: Colors.white),
            )
          : const Icon(Icons.person, color: Colors.white),
    );
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
                  Text(
                    _selectedIndex == 1 ? 'Diccionario' : 
                    _selectedIndex == 2 ? 'Ejercicios' :
                    _selectedIndex == 3 ? 'Comunidad' :
                    _selectedIndex == 4 ? 'Favoritos' : 'Información',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: _buildUserAvatar(),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Cerrar Sesión'),
                        content: const Text('¿Estás seguro que deseas salir?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () {
                              _signOut();
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Salir',
                              style: TextStyle(color: Color(0xFFEE7072)),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            )
          : null,
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
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
            label: 'Ejercicios',
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
            label: 'Información',
          ),
        ],
      ),
    );
  }
}
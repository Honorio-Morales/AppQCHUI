import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:qchui/screens/home_screen.dart';
import 'package:qchui/screens/dictionary_screen.dart';
import 'package:qchui/screens/favorites_screen.dart';
import 'package:qchui/screens/activities_screen.dart';
import 'package:qchui/screens/comunity_screen.dart';
import 'package:qchui/screens/info_screen.dart';
import 'package:qchui/screens/login_screen.dart';
import 'package:qchui/screens/register_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:qchui/services/auth_service.dart';
import 'package:qchui/services/firestore_service.dart';
import 'package:qchui/views/lvl4.dart';


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
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        ChangeNotifierProvider<LevelProgress>(
          create: (_) => LevelProgress(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'QChui',
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
          '/': (context) => const AuthWrapper(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/main': (context) => const MainNavigationWrapper(),
          '/nivel4': (context) => const Nivel4Page(),
        },
      ),
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) { // <<<--- Pequeña mejora: asegurar que data no sea null
          // Usar Future.microtask para programar la navegación después de que el build actual termine.
          Future.microtask(() {
            // Verificar si el widget sigue montado antes de navegar
            if (Navigator.of(context).canPop()) { // O una verificación más robusta si es necesario
              Navigator.pushReplacementNamed(context, '/main');
            } else {
              // A veces, especialmente en hot reload/restart o pruebas, el context puede no estar listo
              // para una navegación inmediata. Puedes intentar un pequeño delay o simplemente
              // permitir que el build complete y el siguiente tick lo maneje.
              // En este caso, pushReplacementNamed es bastante seguro.
              Navigator.pushReplacementNamed(context, '/main');
            }
          });
          // Devuelve un placeholder mientras la navegación ocurre.
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(key: Key('AuthWrapperRedirectingIndicator'))), // <<<--- Añadir una key ayuda en pruebas
          );
        }

        // Si no hay datos (usuario no logueado), muestra HomeScreen
        return const HomeScreen(); // HomeScreen debe manejar el estado de no logueado
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
      const DictionaryScreen(),
      const ExerciseScreen(),
      const CommunityScreen(),
      const FavoritesScreen(),
      const InfoScreen(),
    ];
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
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:AppQCHUI/screens/dictionary_screen.dart';
import 'package:AppQCHUI/screens/activities_screen.dart';
import 'package:AppQCHUI/screens/login_screen.dart';
import 'package:AppQCHUI/screens/register_screen.dart';
import 'package:AppQCHUI/services/firestore_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    // Verificar el estado de autenticación al iniciar
    _auth.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    });
  }

  Widget _buildUserAvatar() {
    if (_currentUser?.photoURL != null) {
      return CircleAvatar(
        backgroundImage: NetworkImage(_currentUser!.photoURL!),
      );
    } else if (_currentUser?.email != null) {
      return CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor,
        child: Text(
          _currentUser!.email![0].toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      );
    }
    return const CircleAvatar(
      child: Icon(Icons.person),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aprende Quechua'),
        actions: [
          if (_currentUser != null)
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
                          _auth.signOut();
                          Navigator.pop(context);
                        },
                        child: const Text('Salir'),
                      ),
                    ],
                  ),
                );
              },
              tooltip: 'Perfil de usuario',
            )
          else
            IconButton(
              icon: const Icon(Icons.login),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              tooltip: 'Iniciar Sesión',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset(
              'assets/images/qchui.png',
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            
            // Mostrar opciones de autenticación solo si no hay usuario logueado
            if (_currentUser == null) ...[
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Bienvenido a Aprende Quechua',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Iniciar Sesión'),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterScreen()),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: BorderSide(color: Theme.of(context).primaryColor),
                        ),
                        child: const Text('Crear Cuenta'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 20),
            ] else ...[
              // Mensaje de bienvenida personalizado para usuarios logueados
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    '¡Bienvenido, ${_currentUser!.email?.split('@').first ?? 'Usuario'}!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            
            // Contenido principal disponible para todos
            ElevatedButton.icon(
              icon: const Icon(Icons.book, size: 24),
              label: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  'DICCIONARIO QUECHUA-ESPAÑOL',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DictionaryScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            OutlinedButton.icon(
              icon: const Icon(Icons.quiz, size: 24),
              label: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  'PRACTICA CON EJERCICIOS',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                );
              },
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                side: BorderSide(color: Theme.of(context).primaryColor),
              ),
            ),
            
            const Spacer(),
            
            // Opción para continuar como invitado
            if (_currentUser == null)
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DictionaryScreen(),
                    ),
                  );
                },
                child: const Text('Continuar como invitado'),
              ),
          ],
        ),
      ),
    );
  }
}
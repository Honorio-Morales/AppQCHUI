import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:AppQCHUI/models/pregunta_model.dart';
import 'package:AppQCHUI/services/firestore_service.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _preguntaController = TextEditingController();
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  bool _isSending = false;

  @override
  void dispose() {
    _preguntaController.dispose();
    super.dispose();
  }

  Future<void> _publicarPregunta() async {
    String texto = _preguntaController.text.trim();
    if (_isSending || texto.isEmpty || _currentUser == null) return;

    setState(() => _isSending = true);

    try {
      // 🔹 Obtener nombre del usuario autenticado desde Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(_currentUser!.uid)
          .get();

      // 🔹 Depuración: Verificar si el usuario existe en Firestore
      print("UID del usuario autenticado: ${_currentUser!.uid}");
      print("Datos obtenidos de Firestore: ${userDoc.data()}");

      String nombreUsuario = (userDoc.data() as Map<String, dynamic>?)?['nombre'] ?? 'Usuario desconocido';

      // 🔹 Depuración: Verificar qué se está guardando
      print("Publicando pregunta con nombreUsuario: $nombreUsuario");

      final pregunta = Pregunta(
        id: '',
        usuarioUid: _currentUser!.uid,
        nombreUsuario: nombreUsuario,
        texto: texto,
        fecha: DateTime.now(),
      );

      await _firestoreService.addPregunta(pregunta);
      _preguntaController.clear();
    } catch (e) {
      print('Error al obtener el nombre del usuario: $e');
    }

    setState(() => _isSending = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comunidad')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _preguntaController,
                    decoration: InputDecoration(
                      hintText: 'Escribe tu pregunta...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: _isSending
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.send, color: Colors.blue),
                  onPressed: _isSending ? null : _publicarPregunta,
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Pregunta>>(
              stream: _firestoreService.getPreguntas(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final preguntas = snapshot.data!;
                return ListView.builder(
                  itemCount: preguntas.length,
                  itemBuilder: (context, index) {
                    return _buildPreguntaCard(preguntas[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreguntaCard(Pregunta pregunta) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pregunta.nombreUsuario,  // 🔹 Ahora usamos directamente el nombre guardado
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 5),
            Text(
              pregunta.texto,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Publicado el ${pregunta.fecha.day}/${pregunta.fecha.month}/${pregunta.fecha.year}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

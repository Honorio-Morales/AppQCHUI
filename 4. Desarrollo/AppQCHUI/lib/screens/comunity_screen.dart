import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:AppQCHUI/models/pregunta_model.dart';
import 'package:AppQCHUI/services/firestore_service.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final TextEditingController _preguntaController = TextEditingController();
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  bool _isSending = false;

  @override
  void dispose() {
    _preguntaController.dispose();
    super.dispose();
  }

  Future<void> _publicarPregunta() async {
    if (_isSending || _currentUser == null) return;
    final texto = _preguntaController.text.trim();
    if (texto.isEmpty) return;

    setState(() => _isSending = true);

    try {
      // Obtener o crear documento de usuario
      final userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(_currentUser.uid)
          .get();

      String nombreUsuario;
      if (!userDoc.exists) {
        nombreUsuario = _currentUser.email?.split('@')[0] ?? 'Usuario';
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(_currentUser.uid)
            .set({
          'nombre': nombreUsuario,
          'email': _currentUser.email,
        });
      } else {
        nombreUsuario = userDoc['nombre'] ?? 
            _currentUser.email?.split('@')[0] ?? 
            'Usuario';
      }

      await Provider.of<FirestoreService>(context, listen: false).addPregunta(
        Pregunta(
          id: '',
          usuarioUid: _currentUser.uid,
          nombreUsuario: nombreUsuario,
          texto: texto,
          fecha: DateTime.now(),
        ),
      );

      _preguntaController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isSending = false);
    }
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
              stream: Provider.of<FirestoreService>(context).getPreguntas(),
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
              pregunta.nombreUsuario,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
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
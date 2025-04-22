import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/palabra_model.dart';
import '../models/favorito_model.dart';
import '../services/firestore_service.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final TextEditingController _searchController = TextEditingController();
  late Stream<List<Palabra>> _palabrasStream;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Palabra> _palabrasFromJson = [];
  bool _showJsonData = false;

  @override
  void initState() {
    super.initState();
    _palabrasStream = Provider.of<FirestoreService>(context, listen: false).getPalabras();
  }

  Future<void> _loadJsonDictionary() async {
    try {
      final String data = await rootBundle.loadString('assets/verbos.json');
      final List<dynamic> jsonList = jsonDecode(data);
      
      setState(() {
        _palabrasFromJson = jsonList.map((item) => Palabra(
          id: 'json_${item["id"]}',
          palabraEspanol: item["traduccion"],
          palabraQuechua: item["quechua"],
          ejemplo: "Categoría: ${item["categoria"]} (${item["tipo_vocalico"]})",
        )).toList();
        _showJsonData = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Diccionario local cargado (${_palabrasFromJson.length} palabras)')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar JSON: $e')),
      );
    }
  }

  void _toggleDataSource() {
    setState(() {
      _showJsonData = !_showJsonData;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    setState(() {
      _palabrasStream = query.isEmpty
          ? Provider.of<FirestoreService>(context, listen: false).getPalabras()
          : Stream.fromFuture(
              Provider.of<FirestoreService>(context, listen: false).buscarPalabras(query));
    });
  }

  Future<void> _toggleFavorite(Palabra palabra) async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicia sesión para guardar favoritos')));
      return;
    }

    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    final isFavorite = await firestoreService
        .esFavorito(user.uid, palabra.id)
        .first;

    if (isFavorite) {
      final favoritoId = await firestoreService.getFavoritoId(user.uid, palabra.id);
      if (favoritoId != null) {
        await firestoreService.removeFavorito(favoritoId);
      }
    } else {
      await firestoreService.addFavorito(Favorito(
        id: '',
        usuarioUid: user.uid,
        palabraId: palabra.id,
        fecha: DateTime.now(),
      ));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleDataSource,
        child: Icon(_showJsonData ? Icons.cloud : Icons.storage),
        tooltip: _showJsonData ? 'Mostrar datos en línea' : 'Mostrar datos locales',
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _onSearchChanged(),
              decoration: InputDecoration(
                hintText: 'Buscar palabra...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          if (_showJsonData && _palabrasFromJson.isEmpty)
            ElevatedButton(
              onPressed: _loadJsonDictionary,
              child: const Text('Cargar Diccionaario trivocalico'),
            ),
          Expanded(
            child: _showJsonData
                ? _palabrasFromJson.isEmpty
                    ? const Center(child: Text('Presiona el botón para cargar datos locales'))
                    : ListView.builder(
                        itemCount: _palabrasFromJson.length,
                        itemBuilder: (context, index) {
                          final palabra = _palabrasFromJson[index];
                          return _buildWordCard(palabra);
                        },
                      )
                : StreamBuilder<List<Palabra>>(
                    stream: _palabrasStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final palabras = snapshot.data!;
                      return ListView.builder(
                        itemCount: palabras.length,
                        itemBuilder: (context, index) {
                          final palabra = palabras[index];
                          return _buildWordCard(palabra);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordCard(Palabra palabra) {
    final user = _auth.currentUser;
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (palabra.id.startsWith('json_'))
                    Chip(
                      label: const Text('LOCAL'),
                      backgroundColor: Colors.amber[100],
                      labelStyle: const TextStyle(fontSize: 10),
                    ),
                  Text(
                    palabra.palabraEspanol,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(height: 2, width: 60, color: Colors.orange),
                  const SizedBox(height: 4),
                  Text(
                    palabra.palabraQuechua,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.brown,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (palabra.ejemplo != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Ejemplo: ${palabra.ejemplo}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ]
                ],
              ),
            ),
            if (user != null && !palabra.id.startsWith('json_'))
              StreamBuilder<bool>(
                stream: Provider.of<FirestoreService>(context)
                    .esFavorito(user.uid, palabra.id),
                builder: (context, snapshot) {
                  final isFavorite = snapshot.data ?? false;
                  return IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey,
                    ),
                    onPressed: () => _toggleFavorite(palabra),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
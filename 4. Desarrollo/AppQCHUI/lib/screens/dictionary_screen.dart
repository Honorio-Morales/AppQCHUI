import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:AppQCHUI/models/palabra_model.dart';
import 'package:AppQCHUI/services/firestore_service.dart';
import 'package:AppQCHUI/screens/favorites_screen.dart';

class DictionaryScreen extends StatefulWidget {
  final Set<String> favoritos;
  final Function(String) onToggleFavorite;

  const DictionaryScreen({
    super.key,
    required this.favoritos,
    required this.onToggleFavorite,
  });

  @override
  _DictionaryScreenState createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _searchController = TextEditingController();
  late Stream<List<Palabra>> _palabrasStream;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    _palabrasStream = _firestoreService.getPalabras();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    setState(() {
      _palabrasStream = query.isEmpty
          ? _firestoreService.getPalabras()
          : Stream.fromFuture(_firestoreService.buscarPalabras(query));
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Diccionario Quechua-Español"),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.red),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoritesScreen(
                    favoritos: widget.favoritos,
                    onRemoveFavorite: widget.onToggleFavorite,
                  ),
                ),
              );
            },
          ),
        ],
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
          Expanded(
            child: StreamBuilder<List<Palabra>>(
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
    final esFavorito = widget.favoritos.contains(palabra.id);

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
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                esFavorito ? Icons.favorite : Icons.favorite_border,
                color: esFavorito ? Colors.red : Colors.grey,
              ),
              onPressed: () => widget.onToggleFavorite(palabra.id),
            ),
          ],
        ),
      ),
    );
  }
}

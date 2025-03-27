import 'package:flutter/material.dart';
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
  // Lista de palabras (podrías mover esto a un servicio/repositorio)
  final List<Map<String, String>> _words = [
    {'espanol': 'Hola', 'quechua': 'Allillanchu'},
    {'espanol': 'Gracias', 'quechua': 'Sulpayki'},
    {'espanol': 'Agua', 'quechua': 'Yaku'},
    {'espanol': 'Sol', 'quechua': 'Inti'},
    {'espanol': 'Luna', 'quechua': 'Killa'},
    // Agrega más palabras aquí
  ];

  // Controlador para la barra de búsqueda
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _filteredWords = [];

  @override
  void initState() {
    super.initState();
    _filteredWords = _words;
    _searchController.addListener(_filterWords);
  }

  void _filterWords() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredWords = _words.where((word) {
        return word['espanol']!.toLowerCase().contains(query) ||
               word['quechua']!.toLowerCase().contains(query);
      }).toList();
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
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar palabra...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          // Lista de palabras
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _filteredWords.length,
              itemBuilder: (context, index) {
                final espanol = _filteredWords[index]['espanol']!;
                final quechua = _filteredWords[index]['quechua']!;
                return _buildWordCard(espanol, quechua);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordCard(String espanol, String quechua) {
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
                    espanol,
                    style:  TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 2,
                    width: 60,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    quechua,
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
                widget.favoritos.contains(espanol)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: widget.favoritos.contains(espanol)
                    ? Colors.red
                    : Colors.grey,
              ),
              onPressed: () => widget.onToggleFavorite(espanol),
            ),
          ],
        ),
      ),
    );
  }
}
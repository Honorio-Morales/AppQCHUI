import 'package:flutter/material.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  final Set<String> favoritos;
  final Function(String) onToggleFavorite;

  const HomeScreen({
    super.key,
    required this.favoritos,
    required this.onToggleFavorite,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, String>> words = [
    {'espanol': 'Hola', 'quechua': 'Allillanchu'},
    {'espanol': 'Gracias', 'quechua': 'Sulpayki'},
    {'espanol': 'Agua', 'quechua': 'Yaku'},
    {'espanol': 'Sol', 'quechua': 'Inti'},
    {'espanol': 'Luna', 'quechua': 'Killa'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Diccionario"),
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
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: words.length,
        itemBuilder: (context, index) {
          String espanol = words[index]['espanol']!;
          String quechua = words[index]['quechua']!;
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4.0),
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
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 2,
                          width: 60,
                          color: Colors.orange,
                        ),
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
        },
      ),
    );
  }
}

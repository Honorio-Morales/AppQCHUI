import 'package:flutter/material.dart';

class FavoritesScreen extends StatelessWidget {
  final Set<String> favoritos;
  final Function(String) onRemoveFavorite;

  const FavoritesScreen({
    super.key,
    required this.favoritos,
    required this.onRemoveFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Favoritos")),
      body: favoritos.isEmpty
          ? const Center(child: Text("No hay palabras en favoritos"))
          : ListView.builder(
              itemCount: favoritos.length,
              itemBuilder: (context, index) {
                String palabra = favoritos.elementAt(index);
                return ListTile(
                  title: Text(palabra, style: const TextStyle(fontSize: 18)),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () => onRemoveFavorite(palabra),
                  ),
                );
              },
            ),
    );
  }
}

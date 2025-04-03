import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../models/palabra_model.dart';
import '../services/firestore_service.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final firestoreService = Provider.of<FirestoreService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Favoritos"),
        backgroundColor: Colors.red[700],
      ),
      body: user == null
          ? _buildNotSignedIn(context)
          : StreamBuilder<List<Palabra>>(
              stream: firestoreService.getPalabrasFavoritas(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoading();
                }
                if (snapshot.hasError) {
                  return _buildError(snapshot.error.toString());
                }
                final palabras = snapshot.data ?? [];
                return palabras.isEmpty
                    ? _buildEmptyState()
                    : _buildFavoritesList(palabras, user.uid, firestoreService, context);
              },
            ),
    );
  }

  Widget _buildNotSignedIn(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite_border, size: 50, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'Inicia sesión para ver tus favoritos',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            child: const Text('Iniciar Sesión'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 50),
          const SizedBox(height: 20),
          Text('Ocurrió un error: $error'),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite_border, size: 50, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'No tienes favoritos aún',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 10),
          const Text(
            'Toca el corazón en las palabras para guardarlas aquí',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(
      List<Palabra> palabras, String userId, FirestoreService firestoreService, BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: palabras.length,
      itemBuilder: (context, index) {
        final palabra = palabras[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            title: Text(
              palabra.palabraQuechua,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(palabra.palabraEspanol),
                if (palabra.ejemplo != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Ejemplo: ${palabra.ejemplo}',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
              ],
            ),
            trailing: StreamBuilder<bool>(
              stream: firestoreService.esFavorito(userId, palabra.id),
              builder: (context, snapshot) {
                final isFavorite = snapshot.data ?? false;
                return IconButton(
                  icon: Icon(
                    Icons.favorite,
                    color: isFavorite ? Colors.red : Colors.grey,
                  ),
                  onPressed: () async {
                    final favoritoId = await firestoreService
                        .getFavoritoId(userId, palabra.id);
                    if (favoritoId != null) {
                      await firestoreService.removeFavorito(favoritoId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Eliminado de favoritos')),
                      );
                    }
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
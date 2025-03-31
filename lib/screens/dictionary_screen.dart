import 'package:flutter/material.dart';
import 'package:AppQCHUI/models/palabra_model.dart';
import 'package:AppQCHUI/services/firebase_service.dart';
import 'package:AppQCHUI/screens/favorites_screen.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  _DictionaryScreenState createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _searchController = TextEditingController();
  late Stream<List<Palabra>> _palabrasStream;
  late Stream<Set<String>> _favoritosStream;
  Set<String> _favoritos = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _palabrasStream = _firebaseService.getPalabras();
    _favoritosStream = _firebaseService.getFavoritos();
    _favoritosStream.listen((favoritos) {
      setState(() => _favoritos = favoritos);
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    setState(() {
      _palabrasStream = query.isEmpty
          ? _firebaseService.getPalabras()
          : Stream.fromFuture(_firebaseService.buscarPalabras(query));
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Diccionario Quechua-Español"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.book)), 
            Tab(icon: Icon(Icons.favorite)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Pestaña 1: Diccionario
          Column(
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
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final palabras = snapshot.data!;
                    return ListView.builder(
                      itemCount: palabras.length,
                      itemBuilder: (context, index) {
                        final palabra = palabras[index];
                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: ListTile(
                            title: Text(palabra.palabraEspanol),
                            subtitle: Text(palabra.palabraQuechua),
                            trailing: IconButton(
                              icon: Icon(
                                _favoritos.contains(palabra.id)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.red,
                              ),
                              onPressed: () => _firebaseService.toggleFavorito(palabra.id),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          
          // Pestaña 2: Favoritos
          const FavoritesScreen(),
        ],
      ),
    );
  }
}
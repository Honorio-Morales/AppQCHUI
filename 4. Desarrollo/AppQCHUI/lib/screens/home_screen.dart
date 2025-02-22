import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key}); //  Se elimina 'const' aquí

  // Lista de palabras en español y su traducción en quechua
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
      body: ListView.builder(
        itemCount: words.length,
        itemBuilder: (context, index) {
          return wordCard(context, words[index]['espanol']!, words[index]['quechua']!);
        },
      ),
    );
  }

  Widget wordCard(BuildContext context, String espanol, String quechua) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 100,
        child: Card(
          child: Row(
            children: <Widget>[
              const SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
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
                    width: 100,
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
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(
    MaterialApp(
      home: const Level5Screen(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Nunito',
      ),
    ),
  );
}

class Level5Screen extends StatefulWidget {
  const Level5Screen({super.key});

  @override
  State<Level5Screen> createState() => _Level5ScreenState();
}

class _Level5ScreenState extends State<Level5Screen> {
  final List<Map<String, String>> _partesCuento = [
    {
      'titulo': 'Parte 1: El encuentro',
      'quechua': '''
Huk p'unchawsi, anka tutamanta huk urqupi huk'uchawan taripanakunku.
Ankas huk'uchata tapurisqa: ¿Imatataq rurachkanki? nispa.
Huk'uchataqsi kayhinata kutichin: Nuqaqa wawaykunapaqmi mikhunata apachkani.''',
      'espanol': '''
Dicen que un día, muy de madrugada, en la cumbre de un cerro un águila se encontró con un ratón.
Y dicen que el águila preguntó al ratón: ¿Qué estás haciendo?
Y el ratón le respondió así: Yo estoy llevando comida para mis hijos.'''
    },
    {
      'titulo': 'Parte 2: El conflicto',
      'quechua': '''
Hinaspas ankaqa huk'uchata nisqa: ¡Yarqasqam kani!, Mikhusqaykim.
Huk'uchataqsi, mancharisqakayhinata kutichin: Amapuni, ñuqata mikhuwaychu, wawaykunata qusqayki.
Ankaqa, ¡Chhiqacha! sunqun ukhullapi nisqa.
Chayqa kusisqa, mana payta mikhusqachu.''',
      'espanol': '''
El águila le dijo: ¡Estoy hambriento! Te voy a comer.
El ratón, muy asustado, le dijo: Por favor no me comas, te daré a mis hijos.
El águila, creyendo que era cierto, se lo guardó en el corazón (se lo creyó).
Y muy contenta, no se lo comió.'''
    },
    {
      'titulo': 'Parte 3: El plan del ratón',
      'quechua': '''
Hukuchaqa, qunqayllamantas, ankata kayhinata niykun: Haku purisun, wawaykunata, qumusayki.
Hina ankataqa purichin.
Chaymantas, huk'uchaqa, qunqayllamanta, huk tu'quman waykuyt'akun,
hinas ankaqa nin: _¡Wawantachá quwanqa!''',
      'espanol': '''
De pronto, el ratón le dijo al águila: Vamos, te daré a mis hijos.
Así hizo que el águila caminara junto a él.
Luego, el ratón se metió en un hueco,
y el águila dijo: ¡Me dará a sus hijos!'''
    },
    {
      'titulo': 'Parte 4: La huida',
      'quechua': '''
Chaymanta, kusisqa, huk'uchata wawankunantinta suyasqa.
Manas huk'uchaqa rikhurimunchu, qhipa karu t'uquntas lluqsirqapusqa.
Ankaqa, t'uquq siminpis suyaykuchkan.''',
      'espanol': '''
Y muy contento, el águila se quedó esperando a los hijos del ratón.
Pero el ratón no apareció, pues había escapado por otro hueco más lejano.
El águila se quedó esperando en la boca del hueco.'''
    },
    {
      'titulo': 'Parte 5: La reflexión del águila',
      'quechua': '''
Mana huk'ucha rikhurimuqtintaq ankaqa nin:
Paytachari mikhuyman karqa nispa;
_maypipis tarillasaqpunim ñuqata yanqhalla q'utuykuwan: _wawayta qusayki nispa.
Chayta nispas hanaq pachaman ankaqa phawarikun.''',
      'espanol': '''
Al ver que el ratón no aparecía, el águila molesto dijo:
Debí haberme comido al ratón;
pero de todas formas en algún lugar lo encontraré, y con engaños me pagó diciendo que me daría a su hijo.
Prometiéndose esto, el águila voló al cielo.'''
    }
  ];

  int _currentPartIndex = 0;
  int _attemptsLeft = 3;
  int _score = 0;
  bool _levelCompleted = false;
  bool _finalQuestionAnswered = false;
  bool _finalAnswerCorrect = false;
  final TextEditingController _answerController = TextEditingController();
  final TextEditingController _finalAnswerController = TextEditingController();

  @override
  void dispose() {
    _answerController.dispose();
    _finalAnswerController.dispose();
    super.dispose();
  }

  void _checkAnswer() {
    final currentPart = _partesCuento[_currentPartIndex];
    final correctAnswer = _currentPartIndex % 2 == 0 
        ? currentPart['espanol']!.toLowerCase() 
        : currentPart['quechua']!.toLowerCase();
    
    if (_answerController.text.trim().toLowerCase() == correctAnswer) {
      setState(() {
        _score++;
        _currentPartIndex++;
        _attemptsLeft = 3;
        _answerController.clear();
        
        if (_currentPartIndex >= _partesCuento.length) {
          _levelCompleted = true;
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_currentPartIndex % 2 == 0 
              ? '¡Allin! (¡Correcto!)' 
              : '¡Ancha allin! (¡Muy bien!)'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      setState(() {
        _attemptsLeft--;
      });
      
      if (_attemptsLeft > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Intento fallido. Te quedan $_attemptsLeft intentos.'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Respuesta incorrecta. La respuesta correcta es:'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Ver',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(currentPart['titulo']!),
                    content: Text(_currentPartIndex % 2 == 0 
                        ? currentPart['espanol']! 
                        : currentPart['quechua']!),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Continuar'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
        
        setState(() {
          _currentPartIndex++;
          _attemptsLeft = 3;
          _answerController.clear();
          
          if (_currentPartIndex >= _partesCuento.length) {
            _levelCompleted = true;
          }
        });
      }
    }
  }

  void _checkFinalAnswer() {
    final respuestaFinal = _finalAnswerController.text.trim().toLowerCase();
    final respuestaCorrecta = respuestaFinal.contains('ratón') && 
                            respuestaFinal.contains('águila') && 
                            respuestaFinal.contains('engaño');
    
    setState(() {
      _finalQuestionAnswered = true;
      _finalAnswerCorrect = respuestaCorrecta;
    });
  }

  void _resetLevel() {
    setState(() {
      _currentPartIndex = 0;
      _attemptsLeft = 3;
      _score = 0;
      _levelCompleted = false;
      _finalQuestionAnswered = false;
      _finalAnswerCorrect = false;
      _answerController.clear();
      _finalAnswerController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[50],
      appBar: AppBar(
        title: const Text('Nivel 5: Aprendiendo Quechua'),
        backgroundColor: Colors.red[800],
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _levelCompleted
            ? _finalQuestionAnswered
                ? _buildResultsScreen()
                : _buildFinalQuestion()
            : _buildPartScreen(),
      ),
    );
  }

  Widget _buildPartScreen() {
    final currentPart = _partesCuento[_currentPartIndex];
    final isTranslateToSpanish = _currentPartIndex % 2 == 0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            color: const Color.fromARGB(255, 198, 41, 56),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    currentPart['titulo']!,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 215, 122, 122),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isTranslateToSpanish 
                        ? 'Texto en Quechua:' 
                        : 'Texto en Español:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isTranslateToSpanish 
                        ? currentPart['quechua']! 
                        : currentPart['espanol']!,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isTranslateToSpanish 
                ? 'Traduce al español:' 
                : 'Traduce al quechua:',
            style: TextStyle(
              fontSize: 18,
              color: Colors.red[800],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _answerController,
            maxLines: 5,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.red[400]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.red[700]!),
              ),
              hintText: 'Escribe tu traducción aquí...',
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Intentos restantes: $_attemptsLeft',
            style: TextStyle(
              color: _attemptsLeft > 1 ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _checkAnswer,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Verificar Respuesta',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalQuestion() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            color: Colors.red[100],
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    '🌟 Pregunta final',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[900],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '¿Imata riman kay hawari? (¿De qué habla este cuento?)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Escribe una respuesta que mencione al ratón, al águila y el engaño.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _finalAnswerController,
            maxLines: 3,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.red[400]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.red[700]!),
              ),
              hintText: 'Escribe tu respuesta aquí...',
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _checkFinalAnswer,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Enviar Respuesta',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            color: Colors.red[100],
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  if (_finalAnswerCorrect)
                    Column(
                      children: [
                        Text(
                          '✨✨✨✨✨✨✨✨✨✨',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.red[800],
                          ),
                        ),
                        Text(
                          '¡TUKUY TAWANTIN SUTIYASQA!',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[900],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Text(
                          '(¡NIVEL 5 COMPLETADO CON ÉXITO!)',
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          '✨✨✨✨✨✨✨✨✨✨',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.red[800],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Puntaje final: $_score/5',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          '¡Yupaychani qamkuna! (¡Gracias a todos!)',
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Has demostrado un profundo entendimiento '
                          'del quechua y la sabiduría de los cuentos '
                          'andinos. ¡El águila y el ratón estarían '
                          'orgullosos de tu aprendizaje!',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        Text(
                          '💪🏽💪🏽💪🏽💪🏽💪🏽',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.red[800],
                          ),
                        ),
                        Text(
                          '¡AMANTA QAQUY!',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[900],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Text(
                          '(¡NO TE RINDAS!)',
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          '💪🏽💪🏽💪🏽💪🏽💪🏽',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.red[800],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Puntaje: $_score/5',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          '¡Sigue practicando! Puedes volver a intentar el nivel.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _resetLevel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[700],
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 32,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      _finalAnswerCorrect ? 'Continuar al Nivel 6' : 'Reintentar Nivel',
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
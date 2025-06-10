import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qchui/views/lvl1.dart';
import 'package:qchui/views/lvl2.dart';
import 'package:qchui/views/lvl3.dart';
import 'package:qchui/views/lvl4.dart';
import 'package:qchui/views/lvl5.dart';

class LevelProgress extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<LevelStatus> _levels = [];
  bool _isLoading = true;
  String? _error;

  List<LevelStatus> get levels => _levels;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserProgress() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      print('Cargando progreso para usuario: ${user.uid}'); // Debug

      // Intentar cargar progreso del usuario
      final progressDoc = await _firestore.collection('user_progress').doc(user.uid).get();
      
      print('Documento de progreso existe: ${progressDoc.exists}'); // Debug
      
      // Inicializar niveles basado en el progreso guardado o usar valores por defecto
      _levels = _initializeLevels(progressDoc.data()?['levels'] as List<dynamic>?);

      // Si no existe el documento de progreso, crear uno nuevo
      if (!progressDoc.exists) {
        print('Creando nuevo documento de progreso'); // Debug
        await _saveProgress();
      }

      print('Niveles cargados: ${_levels.length}'); // Debug
      
    } catch (e) {
      print('Error en loadUserProgress: $e'); // Debug
      _error = 'Error cargando progreso: ${e.toString()}';
      _levels = _initializeDefaultLevels();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<LevelStatus> _initializeLevels(List<dynamic>? progressData) {
    print('Inicializando niveles con data: $progressData'); // Debug
    
    return List.generate(5, (index) {
      final levelData = progressData != null && progressData.length > index 
          ? progressData[index] as Map<String, dynamic>?
          : null;
      
      final progress = levelData?['progress'] != null 
          ? (levelData?['progress'] as num).toDouble()
          : 0.0;
      
      final isEnabled = levelData?['isEnabled'] == true || index == 0;

      return LevelStatus(
        title: "Nivel ${index + 1}",
        subtitle: _getSubtitle(index, progress, isEnabled),
        icon: _getIconForLevel(index),
        progress: progress,
        isEnabled: isEnabled,
        color: _getColorForLevel(index, progress, isEnabled),
      );
    });
  }

  List<LevelStatus> _initializeDefaultLevels() {
    return [
      LevelStatus(
        title: "Nivel 1",
        subtitle: "Por comenzar",
        icon: Icons.school,
        progress: 0.0,
        isEnabled: true,
        color: Colors.redAccent,
      ),
      LevelStatus(
        title: "Nivel 2",
        subtitle: "Bloqueado",
        icon: Icons.star,
        progress: 0.0,
        isEnabled: false,
        color: Colors.grey,
      ),
      LevelStatus(
        title: "Nivel 3",
        subtitle: "Bloqueado",
        icon: Icons.emoji_events,
        progress: 0.0,
        isEnabled: false,
        color: Colors.grey,
      ),
      LevelStatus(
        title: "Nivel 4",
        subtitle: "Bloqueado",
        icon: Icons.military_tech,
        progress: 0.0,
        isEnabled: false,
        color: Colors.grey,
      ),
      LevelStatus(
        title: "Nivel 5",
        subtitle: "Bloqueado",
        icon: Icons.workspace_premium,
        progress: 0.0,
        isEnabled: false,
        color: Colors.grey,
      ),
    ];
  }

  String _getSubtitle(int index, double progress, bool isEnabled) {
    if (index > 0 && !isEnabled) return "Bloqueado";
    if (progress == 0.0) return "Por comenzar";
    if (progress < 0.7) return "En progreso";
    if (progress < 1.0) return "Casi terminado";
    return "Completado";
  }

  IconData _getIconForLevel(int index) {
    switch(index) {
      case 0: return Icons.school;
      case 1: return Icons.star;
      case 2: return Icons.emoji_events;
      case 3: return Icons.military_tech;
      case 4: return Icons.workspace_premium;
      default: return Icons.help_outline;
    }
  }

  Color _getColorForLevel(int index, double progress, bool isEnabled) {
    if (!isEnabled) return Colors.grey;
    if (progress >= 0.7) return Colors.green;
    return Colors.redAccent;
  }

  Future<void> updateProgress(int levelIndex, double newProgress) async {
    if (levelIndex < 0 || levelIndex >= _levels.length) return;

    final user = _auth.currentUser;
    if (user == null) return;

    print('Actualizando progreso - Nivel: $levelIndex, Progreso: $newProgress'); // Debug

    _levels[levelIndex].progress = newProgress.clamp(0.0, 1.0);
    _levels[levelIndex].subtitle = _getSubtitle(
      levelIndex, 
      newProgress, 
      _levels[levelIndex].isEnabled
    );
    _levels[levelIndex].color = _getColorForLevel(
      levelIndex, 
      newProgress, 
      _levels[levelIndex].isEnabled
    );
    
    // Desbloquear siguiente nivel si se completa al menos 70%
    if (newProgress >= 0.7 && levelIndex + 1 < _levels.length) {
      _levels[levelIndex + 1].isEnabled = true;
      _levels[levelIndex + 1].subtitle = _getSubtitle(
        levelIndex + 1, 
        0.0, 
        true
      );
      _levels[levelIndex + 1].color = _getColorForLevel(
        levelIndex + 1, 
        0.0, 
        true
      );
    }

    try {
      await _saveProgress();
      notifyListeners();
    } catch (e) {
      print('Error actualizando progreso: $e'); // Debug
      _error = 'Error actualizando progreso';
      notifyListeners();
    }
  }

  Future<void> _saveProgress() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      print('Guardando progreso para usuario: ${user.uid}'); // Debug

      final progressData = {
        'levels': _levels.map((level) => {
          'title': level.title,
          'subtitle': level.subtitle,
          'progress': level.progress,
          'isEnabled': level.isEnabled,
        }).toList(),
        'lastUpdated': FieldValue.serverTimestamp(),
        'userId': user.uid,
      };

      print('Datos a guardar: $progressData'); // Debug

      await _firestore.collection('user_progress').doc(user.uid).set(
        progressData,
        SetOptions(merge: true)
      );

      print('Progreso guardado exitosamente'); // Debug
      
    } catch (e) {
      print('Error saving progress: $e');
      throw Exception('Error guardando progreso: ${e.toString()}');
    }
  }

  // Método para reintentar cargar el progreso
  Future<void> retry() async {
    await loadUserProgress();
  }
}

class LevelStatus {
  final String title;
  String subtitle;
  final IconData icon;
  double progress;
  bool isEnabled;
  Color color;

  LevelStatus({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.progress,
    required this.isEnabled,
    required this.color,
  });
}

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar progreso cuando se inicializa la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final levelProgress = Provider.of<LevelProgress>(context, listen: false);
      if (levelProgress.levels.isEmpty) {
        levelProgress.loadUserProgress();
      }
    });
  }

  void _goToLevel(BuildContext context, int level) {
    Widget screen;
    switch (level) {
      case 1:
        screen = const Level1Screen();
        break;
        // aquiponer sus niveles companeros
      case 2:
        screen = const Level2Screen(); // Llama a la pantalla del Nivel 2
        break;
      case 3:
        screen = const Level3Screen(); // Llama a la pantalla del Nivel 3
        break;
      case 4:
        screen = const Level4Screen(); // Llama a la pantalla del Nivel 4
        break;
      case 5:
        screen = const Level5Screen(); // Llama a la pantalla del Nivel 5
        break;
      default:
        screen = const Scaffold(
          body: Center(child: Text('Nivel no disponible aún')),
        );
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  Widget _buildLevelCard(BuildContext context, int index, LevelStatus level) {
    return GestureDetector(
      onTap: level.isEnabled 
          ? () => _goToLevel(context, index + 1) 
          : () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Completa el nivel anterior para desbloquear'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 2),
                ),
              );
            },
      child: Card(
        elevation: level.isEnabled ? 4 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: level.isEnabled ? Colors.white : Colors.grey[100],
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Icon(level.icon, size: 36, color: level.color.withOpacity(0.2)),
                  Icon(level.icon, size: 30, color: level.color),
                  if (!level.isEnabled)
                    Icon(Icons.lock, size: 16, color: Colors.grey[600]),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                level.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold, 
                  color: level.color,
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: level.progress,
                minHeight: 8,
                color: level.color,
                backgroundColor: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(height: 8),
              Text(
                level.subtitle,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: level.isEnabled ? Colors.black87 : Colors.grey,
                ),
              ),
              if (level.progress > 0)
                Text(
                  '${(level.progress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: level.color,
                  ),
                ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(
      begin: 0.1,
      curve: Curves.easeOutQuad,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LevelProgress>(
      builder: (context, levelProgress, child) {
        return Scaffold(
          body: _buildBody(context, levelProgress),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, LevelProgress levelProgress) {
    if (levelProgress.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEE7072)),
            ),
            SizedBox(height: 16),
            Text('Cargando niveles...'),
          ],
        ),
      );
    }

    if (levelProgress.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                levelProgress.error!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => levelProgress.retry(),
                child: Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFEE7072),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.school, color: Color(0xFFEE7072)),
              SizedBox(width: 8),
              Text(
                'Selecciona un nivel:',
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEE7072),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 0.9,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: List.generate(levelProgress.levels.length, (index) {
                return _buildLevelCard(context, index, levelProgress.levels[index]);
              }),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:confetti/confetti.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// =================================================================
// 1. GLOBAL VARIABLES & SETUP
// =================================================================

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final ValueNotifier<ThemeMode> _themeNotifier = ValueNotifier(ThemeMode.dark);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load Theme Preference
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDark') ?? true;
  _themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;

  // NOTE: Hum yahan Notification Init NAHI karenge taaki Crash na ho.
  // Wo hum Home Screen par karenge (Safe Mode).

  runApp(const TaskMasterApp());
}

class TaskMasterApp extends StatelessWidget {
  const TaskMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeNotifier,
      builder: (_, mode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'TaskMaster Hero',
          themeMode: mode,
          // --- Light Theme ---
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF2F4F7),
            primaryColor: const Color(0xFF6C63FF),
            cardColor: const Color(0xFFFFFFFF),
            canvasColor: const Color(0xFFFFFFFF),
            dividerColor: const Color(0xFFE6E8EB),
            textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
            useMaterial3: true,
          ),
          // --- Dark Theme ---
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0A0A0A),
            primaryColor: const Color(0xFF6C63FF),
            cardColor: const Color(0xFF141414),
            canvasColor: const Color(0xFF141414),
            dividerColor: const Color(0xFF2A2A2A),
            textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
            useMaterial3: true,
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}

// =================================================================
// 2. SPLASH SCREEN (Safe Asset Loading)
// =================================================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();

    // 2.5 second baad Home Screen par
    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(PageRouteBuilder(
            pageBuilder: (_, __, ___) => const TodoHome(),
            transitionsBuilder: (_, a, __, c) =>
                FadeTransition(opacity: a, child: c),
            transitionDuration: const Duration(milliseconds: 800)));
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF6C63FF).withOpacity(0.1)),
                // SAFE IMAGE LOAD: Agar logo nahi mila to Icon dikhayega
                child: Image.asset(
                  'assets/logo.png', // Tumhara naya folder path
                  width: 120,
                  height: 120,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(LucideIcons.checkCircle,
                        size: 80, color: Color(0xFF6C63FF));
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text("TaskMaster",
                style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -1)),
            const SizedBox(height: 10),
            Text("HERO EDITION • FST HAVOC",
                style: GoogleFonts.outfit(
                    fontSize: 12, letterSpacing: 3, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// =================================================================
// 3. INFO SCREENS (Privacy & About) - Jo ChatGPT ne hata diya tha
// =================================================================

class InfoScreen extends StatelessWidget {
  final String title;
  final String contentType; // 'privacy' or 'about'

  const InfoScreen({super.key, required this.title, required this.contentType});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    List<Widget> contentWidgets = [];
    if (contentType == 'privacy') {
      contentWidgets = [
        _sectionTitle("1. Privacy First", theme),
        _sectionBody(
            "TaskMaster Hero is an offline-first app. We do not store your personal data on any server."),
        const SizedBox(height: 15),
        _sectionTitle("2. Local Storage", theme),
        _sectionBody("All your tasks are stored locally on your device."),
      ];
    } else {
      contentWidgets = [
        _sectionTitle("About TaskMaster", theme),
        _sectionBody("Designed for focus and speed. Built for Heroes."),
        const SizedBox(height: 15),
        _sectionTitle("Developer", theme),
        _sectionBody("Created by FST Havoc (Ayush Tiwari)."),
        const SizedBox(height: 15),
        _sectionTitle("Version", theme),
        _sectionBody("v8.0 (Native Android)"),
      ];
    }

    return Scaffold(
      appBar: AppBar(
          title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          iconTheme: theme.iconTheme),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ...contentWidgets,
          const SizedBox(height: 30),
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white),
              child: const Text("Back"),
            ),
          )
        ],
      ),
    );
  }

  Widget _sectionTitle(String text, ThemeData theme) {
    return Text(text,
        style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color));
  }

  Widget _sectionBody(String text) {
    return Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Text(text,
            style: GoogleFonts.outfit(
                fontSize: 14, color: Colors.grey, height: 1.5)));
  }
}

// =================================================================
// 4. MAIN HOME SCREEN (Full Features)
// =================================================================
class TodoHome extends StatefulWidget {
  const TodoHome({super.key});
  @override
  State<TodoHome> createState() => _TodoHomeState();
}

class _TodoHomeState extends State<TodoHome> with TickerProviderStateMixin {
  // --- STATE VARIABLES ---
  List<Map<String, dynamic>> todos = [];
  final TextEditingController _inputController = TextEditingController();
  late ConfettiController _confettiController;

  String filter = 'all';
  String selectedEnergy = 'low';
  bool isMenuOpen = false;

  // Colors
  final Color cPrimary = const Color(0xFF6C63FF);
  final Color cEnergyHigh = const Color(0xFFFF6B6B);
  final Color cEnergyLow = const Color(0xFF1DD1A1);

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 1));
    _loadTodos();
    // CRASH FIX: Init notifications here safely
    _initNotificationsSafely();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  // --- SAFE NOTIFICATION LOGIC ---
  Future<void> _initNotificationsSafely() async {
    try {
      // 1. Init Settings
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      // 2. Initialize Plugin (Try-Catch ke andar)
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);

      // 3. Channel Setup
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'taskmaster_channel', 'Task Updates',
        importance: Importance.max,
      );

      final android = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (android != null) {
        await android.createNotificationChannel(channel);
        try {
          await android.requestNotificationsPermission();
        } catch (_) {}
      }
    } catch (e) {
      debugPrint("Notification Init Failed (Safe Mode): $e");
    }
  }

  Future<void> _showNotification() async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'taskmaster_channel',
        'Task Updates',
        importance: Importance.max,
        priority: Priority.high,
      );
      const NotificationDetails details =
          NotificationDetails(android: androidDetails);

      await flutterLocalNotificationsPlugin.show(
          0, 'Task Added! 🚀', 'Go achieve your goals, Hero.', details);
    } catch (e) {
      debugPrint("Notification Show Failed: $e");
    }
  }

  // --- DATA OPERATIONS ---
  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('todos');
    if (data != null && mounted) {
      setState(
          () => todos = List<Map<String, dynamic>>.from(json.decode(data)));
    }
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('todos', json.encode(todos));
  }

  void _addTask() {
    if (_inputController.text.trim().isEmpty) return;
    setState(() {
      todos.add({
        'id': DateTime.now().millisecondsSinceEpoch,
        'text': _inputController.text.trim(),
        'completed': false,
        'energy': selectedEnergy,
      });
      _inputController.clear();
      _saveTodos();
    });
    HapticFeedback.mediumImpact();
    _showNotification();
  }

  void _toggleTask(int id) {
    int idx = todos.indexWhere((t) => t['id'] == id);
    if (idx != -1) {
      setState(() {
        todos[idx]['completed'] = !todos[idx]['completed'];
        if (todos[idx]['completed']) {
          _confettiController.play();
          HapticFeedback.heavyImpact();
        }
        _saveTodos();
      });
    }
  }

  void _deleteTask(int id) {
    setState(() {
      todos.removeWhere((t) => t['id'] == id);
      _saveTodos();
    });
    HapticFeedback.selectionClick();
  }

  double _getProgress() {
    if (todos.isEmpty) return 0.0;
    return todos.where((t) => t['completed'] == true).length / todos.length;
  }

  List<Map<String, dynamic>> get _visibleTodos {
    var list = filter == 'all'
        ? todos
        : todos.where((t) => t['energy'] == filter).toList();
    // Sort completed to bottom
    list.sort((a, b) =>
        (a['completed'] == b['completed']) ? 0 : a['completed'] ? 1 : -1);
    return list;
  }

  // --- UI BUILDING BLOCKS ---

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      // Side Menu Drawer
      drawer: Drawer(
        backgroundColor: theme.cardColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: cPrimary.withOpacity(0.1)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("TaskMaster",
                      style: GoogleFonts.outfit(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                          color: cPrimary,
                          borderRadius: BorderRadius.circular(4)),
                      child: const Text("HERO EDITION",
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)))
                ],
              ),
            ),
            ListTile(
              leading: const Icon(LucideIcons.moon),
              title: const Text("Dark Mode"),
              trailing: Switch(
                value: isDark,
                activeColor: cPrimary,
                onChanged: (val) async {
                  _themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                  final prefs = await SharedPreferences.getInstance();
                  prefs.setBool('isDark', val);
                },
              ),
            ),
            ListTile(
              leading: const Icon(LucideIcons.shield),
              title: const Text("Privacy Policy"),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const InfoScreen(
                          title: "Privacy Policy", contentType: 'privacy'))),
            ),
            ListTile(
              leading: const Icon(LucideIcons.info),
              title: const Text("About Us"),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const InfoScreen(
                          title: "About Us", contentType: 'about'))),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(LucideIcons.trash, color: Colors.red),
              title: const Text("Reset All Data",
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                setState(() {
                  todos.clear();
                  _saveTodos();
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // HEADER
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Hello, Hero 👋",
                              style: GoogleFonts.outfit(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500)),
                          Text("My Tasks",
                              style: GoogleFonts.outfit(
                                  fontSize: 28, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      // HAMBURGER MENU BUTTON
                      Builder(builder: (context) {
                        return GestureDetector(
                          onTap: () => Scaffold.of(context).openDrawer(),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: theme.dividerColor)),
                            child: Icon(LucideIcons.menu,
                                color: theme.iconTheme.color),
                          ),
                        );
                      })
                    ],
                  ),
                ),

                // PROGRESS BAR
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                        value: _getProgress(),
                        minHeight: 8,
                        backgroundColor: theme.dividerColor,
                        valueColor: AlwaysStoppedAnimation(cPrimary)),
                  ),
                ),
                const SizedBox(height: 20),

                // FILTERS
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _buildFilter('All', 'all', theme),
                      const SizedBox(width: 10),
                      _buildFilter('🔥 High', 'high', theme),
                      const SizedBox(width: 10),
                      _buildFilter('☕ Low', 'low', theme),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // INPUT BOX
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: theme.dividerColor),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 10))
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 15),
                        Expanded(
                          child: TextField(
                            controller: _inputController,
                            style: TextStyle(
                                color: theme.textTheme.bodyMedium?.color),
                            decoration: const InputDecoration(
                                hintText: "Add new task...",
                                border: InputBorder.none),
                            onSubmitted: (_) => _addTask(),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => selectedEnergy =
                              selectedEnergy == 'high' ? 'low' : 'high'),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark
                                    ? const Color(0xFF1F1F1F)
                                    : const Color(0xFFF0F0F0),
                                border: Border.all(
                                    color: selectedEnergy == 'high'
                                        ? cEnergyHigh
                                        : cEnergyLow,
                                    width: 2)),
                            child: Center(
                                child: Text(
                                    selectedEnergy == 'high' ? '🔥' : '☕',
                                    style: const TextStyle(fontSize: 16))),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FloatingActionButton.small(
                          onPressed: _addTask,
                          backgroundColor: cPrimary,
                          elevation: 0,
                          child:
                              const Icon(LucideIcons.plus, color: Colors.white),
                        )
                      ],
                    ),
                  ),
                ),

                // LIST VIEW
                Expanded(
                  child: _visibleTodos.isEmpty
                      ? Center(
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                              Icon(LucideIcons.list,
                                  size: 50, color: Colors.grey.withOpacity(0.5)),
                              const SizedBox(height: 10),
                              Text("No tasks yet!",
                                  style: GoogleFonts.outfit(color: Colors.grey))
                            ]))
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: _visibleTodos.length,
                          itemBuilder: (context, index) {
                            final todo = _visibleTodos[index];
                            final bool isCompleted = todo['completed'];
                            return Dismissible(
                              key: Key(todo['id'].toString()),
                              background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: const Icon(LucideIcons.trash2,
                                      color: Colors.white)),
                              direction: DismissDirection.endToStart,
                              onDismissed: (dir) => _deleteTask(todo['id']),
                              child: GestureDetector(
                                onTap: () => _toggleTask(todo['id']),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                      color: theme.cardColor,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: isCompleted
                                              ? Colors.green.withOpacity(0.5)
                                              : theme.dividerColor),
                                      boxShadow: [
                                        BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.02),
                                            blurRadius: 5,
                                            offset: const Offset(0, 2))
                                      ]),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isCompleted
                                            ? LucideIcons.checkCircle
                                            : LucideIcons.circle,
                                        color: isCompleted
                                            ? Colors.green
                                            : Colors.grey,
                                      ),
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: Text(
                                          todo['text'],
                                          style: GoogleFonts.outfit(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            decoration: isCompleted
                                                ? TextDecoration.lineThrough
                                                : null,
                                            color: isCompleted
                                                ? Colors.grey
                                                : theme
                                                    .textTheme.bodyMedium?.color,
                                          ),
                                        ),
                                      ),
                                      if (todo['energy'] == 'high')
                                        const Text("🔥",
                                            style: TextStyle(fontSize: 16))
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  numberOfParticles: 20,
                  gravity: 0.2)),
        ],
      ),
    );
  }

  Widget _buildFilter(String label, String val, ThemeData theme) {
    bool isActive = filter == val;
    return GestureDetector(
      onTap: () => setState(() => filter = val),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? cPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: isActive ? cPrimary : theme.dividerColor),
        ),
        child: Text(label,
            style: TextStyle(
                color: isActive ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold)),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:confetti/confetti.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// =================================================================
// GLOBAL SETUP
// =================================================================

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
final ValueNotifier<ThemeMode> _themeNotifier = ValueNotifier(ThemeMode.dark);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Theme Load
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDark') ?? true;
  _themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;

  // NOTE: Notification Init ko yahan se hata kar Home Screen me daal diya hai
  // taaki "Startup Crash" na ho.
  
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
          // Light Theme
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
          // Dark Theme
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
// 1. SPLASH SCREEN (Safe Logo)
// =================================================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
    
    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(PageRouteBuilder(
          pageBuilder: (_, __, ___) => const TodoHome(),
          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
          transitionDuration: const Duration(milliseconds: 800)
        ));
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
                decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF6C63FF).withOpacity(0.1)),
                // Logo Safe Load
                child: Image.asset(
                  'logo.png', 
                  width: 120, 
                  height: 120, 
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(LucideIcons.checkCircle, size: 80, color: Color(0xFF6C63FF));
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text("TaskMaster", style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -1)),
            const SizedBox(height: 10),
            Text("HERO EDITION • FST HAVOC", style: GoogleFonts.outfit(fontSize: 12, letterSpacing: 3, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// =================================================================
// 2. INFO SCREENS (Restored!) ✅
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
        _sectionBody("TaskMaster Hero is an offline-first app. We do not store your personal data on any server."),
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
      appBar: AppBar(title: Text(title), backgroundColor: theme.scaffoldBackgroundColor, elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ...contentWidgets,
          const SizedBox(height: 30),
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor, foregroundColor: Colors.white),
              child: const Text("Back"),
            ),
          )
        ],
      ),
    );
  }

  Widget _sectionTitle(String text, ThemeData theme) {
    return Text(text, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color));
  }
  Widget _sectionBody(String text) {
    return Padding(padding: const EdgeInsets.only(top: 5), child: Text(text, style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey, height: 1.5)));
  }
}

// =================================================================
// 3. MAIN HOME SCREEN
// =================================================================
class TodoHome extends StatefulWidget {
  const TodoHome({super.key});
  @override
  State<TodoHome> createState() => _TodoHomeState();
}

class _TodoHomeState extends State<TodoHome> with TickerProviderStateMixin {
  // State
  List<Map<String, dynamic>> todos = [];
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _editSheetController = TextEditingController();
  late ConfettiController _confettiController;
  
  String filter = 'all'; 
  String selectedEnergy = 'low';
  bool isMenuOpen = false;
  bool isBulkMode = false;
  int? currentEditId;

  // Colors
  final Color cPrimary = const Color(0xFF6C63FF);
  final Color cEnergyHigh = const Color(0xFFFF6B6B);
  final Color cEnergyLow = const Color(0xFF1DD1A1);
  final Color cDanger = const Color(0xFFFF4757);

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    _loadTodos();
    // Notification Init ko yahan Safe Mode me call kiya hai
    _initNotificationsSafely();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _inputController.dispose();
    _editSheetController.dispose();
    super.dispose();
  }

  // --- SAFE NOTIFICATION LOGIC (Chhota Feature) --- ✅
  Future<void> _initNotificationsSafely() async {
    try {
      // 1. Init Settings
      const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
      
      // 2. Initialize Plugin
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);

      // 3. Ask Permission (Android 13+)
      await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();

    } catch (e) {
      // Agar crash hua to bas ignore karega, App band nahi hoga
      print("Notification Init Failed (Safe Mode): $e");
    }
  }

  Future<void> _showSimpleNotification() async {
    // Ye function tab call hoga jab user task add karega (Test ke liye)
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'taskmaster_channel', 'Task Updates',
        importance: Importance.max, priority: Priority.high,
      );
      const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
      
      await flutterLocalNotificationsPlugin.show(
        0, 
        'Task Added! 🚀', 
        'Now go and finish it like a Hero.', 
        platformChannelSpecifics
      );
    } catch (e) {
      print("Notification Show Failed: $e");
    }
  }

  // --- DATA OPERATIONS ---
  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('todos');
    if (data != null) {
      setState(() => todos = List<Map<String, dynamic>>.from(json.decode(data)));
    }
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('todos', json.encode(todos));
  }

  void _triggerHaptic(String type) {
    if (type == 'add') HapticFeedback.mediumImpact();
    if (type == 'success') HapticFeedback.heavyImpact();
    if (type == 'delete') HapticFeedback.selectionClick();
  }

  void _addTask() {
    if (_inputController.text.trim().isEmpty) return;
    setState(() {
      todos.add({
        'id': DateTime.now().millisecondsSinceEpoch,
        'text': _inputController.text.trim(),
        'completed': false,
        'selected': false,
        'energy': selectedEnergy,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      });
      _inputController.clear();
      _saveTodos();
    });
    _triggerHaptic('add');
    // Simple Notification Trigger
    _showSimpleNotification(); 
  }

  void _toggleTask(int id) {
    if (isBulkMode) return _selectTask(id);
    int idx = todos.indexWhere((t) => t['id'] == id);
    if (idx != -1) {
      setState(() {
        todos[idx]['completed'] = !todos[idx]['completed'];
        if (todos[idx]['completed']) {
          _confettiController.play();
          _triggerHaptic('success');
        }
        _saveTodos();
      });
    }
  }

  void _enterBulkMode(int id) {
    setState(() { isBulkMode = true; _selectTask(id); });
    _triggerHaptic('add');
  }

  void _selectTask(int id) {
    int idx = todos.indexWhere((t) => t['id'] == id);
    if (idx != -1) {
      setState(() => todos[idx]['selected'] = !(todos[idx]['selected'] ?? false));
    }
  }

  void _deleteSelected() {
    setState(() {
      todos.removeWhere((t) => t['selected'] == true);
      isBulkMode = false;
      _saveTodos();
    });
    _triggerHaptic('delete');
  }

  // --- UI: EDIT SHEET ---
  void _openEditSheet(int id) {
    if (isBulkMode) return;
    final task = todos.firstWhere((t) => t['id'] == id);
    setState(() { currentEditId = id; _editSheetController.text = task['text']; });
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, top: 20, left: 20, right: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Edit Task", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(LucideIcons.x), onPressed: () => Navigator.pop(ctx))
              ],
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _editSheetController,
              autofocus: true,
              style: const TextStyle(fontSize: 18),
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1F1F1F) : const Color(0xFFF0F0F0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () { _deleteSingleTask(currentEditId!); Navigator.pop(ctx); },
                    icon: Icon(LucideIcons.trash2, color: cDanger),
                    label: Text("Delete", style: TextStyle(color: cDanger)),
                    style: TextButton.styleFrom(padding: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: cDanger))),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () { _saveEdit(); Navigator.pop(ctx); },
                    icon: const Icon(LucideIcons.save, color: Colors.white),
                    label: const Text("Save", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: cPrimary, padding: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  ),
                )
              ],
            )
          ],
        ),
      )
    );
  }

  void _saveEdit() {
    if (currentEditId == null) return;
    int idx = todos.indexWhere((t) => t['id'] == currentEditId);
    if (idx != -1) {
      setState(() { todos[idx]['text'] = _editSheetController.text; _saveTodos(); });
    }
  }

  void _deleteSingleTask(int id) {
    setState(() { todos.removeWhere((t) => t['id'] == id); _saveTodos(); });
    _triggerHaptic('delete');
  }

  // --- UI: HELPERS ---
  String _getGreeting() {
    var h = DateTime.now().hour;
    if (h < 12) return "Good Morning";
    if (h < 17) return "Good Afternoon";
    return "Good Evening";
  }

  double _getProgress() {
    if (todos.isEmpty) return 0.0;
    return todos.where((t) => t['completed'] == true).length / todos.length;
  }

  List<Map<String, dynamic>> get _visibleTodos {
    var list = filter == 'all' ? todos : todos.where((t) => t['energy'] == filter).toList();
    list.sort((a, b) => (a['completed'] == b['completed']) ? 0 : a['completed'] ? 1 : -1);
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${_getGreeting()}, Hero 👋", style: GoogleFonts.outfit(color: Colors.grey, fontWeight: FontWeight.w500)),
                              Text("My Tasks", style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => setState(() => isMenuOpen = true),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(14), border: Border.all(color: theme.dividerColor)),
                              child: Icon(LucideIcons.menu, color: theme.iconTheme.color),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(value: _getProgress(), minHeight: 8, backgroundColor: theme.dividerColor, valueColor: AlwaysStoppedAnimation(cPrimary)),
                      ),
                      const SizedBox(height: 8),
                      Align(alignment: Alignment.centerRight, child: Text("${(_getProgress() * 100).toInt()}% Done", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12))),
                      const SizedBox(height: 15),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
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
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: theme.dividerColor),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 10))],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 15),
                        Expanded(
                          child: TextField(
                            controller: _inputController,
                            style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                            decoration: const InputDecoration(hintText: "Add new task...", hintStyle: TextStyle(color: Colors.grey), border: InputBorder.none),
                            onSubmitted: (_) => _addTask(),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => selectedEnergy = selectedEnergy == 'high' ? 'low' : 'high'),
                          child: Container(
                            width: 32, height: 32,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: isDark ? const Color(0xFF1F1F1F) : const Color(0xFFF0F0F0), border: Border.all(color: selectedEnergy == 'high' ? cEnergyHigh : cEnergyLow, width: 2)),
                            child: Center(child: Text(selectedEnergy == 'high' ? '🔥' : '☕', style: const TextStyle(fontSize: 16))),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FloatingActionButton.small(
                          onPressed: _addTask,
                          backgroundColor: cPrimary,
                          elevation: 0,
                          child: const Icon(LucideIcons.plus, color: Colors.white),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: _visibleTodos.isEmpty 
                  ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(LucideIcons.list, size: 50, color: Colors.grey.withOpacity(0.5)), const SizedBox(height: 10), Text("No tasks yet!", style: GoogleFonts.outfit(color: Colors.grey))]))
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: _visibleTodos.length,
                      itemBuilder: (context, index) {
                        final todo = _visibleTodos[index];
                        final bool isCompleted = todo['completed'];
                        final bool isSelected = todo['selected'] ?? false;
                        
                        Color borderColor = theme.dividerColor;
                        if (isSelected) borderColor = cPrimary;

                        return GestureDetector(
                          onLongPress: () => _enterBulkMode(todo['id']),
                          onTap: () => _toggleTask(todo['id']),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected ? cPrimary.withOpacity(0.1) : theme.cardColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: borderColor),
                              boxShadow: isSelected ? [] : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2))]
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 24, height: 24,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: isCompleted ? const Color(0xFF2ED573) : Colors.grey),
                                    color: isCompleted ? const Color(0xFF2ED573) : Colors.transparent,
                                  ),
                                  child: isCompleted ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Text(
                                    todo['text'],
                                    style: GoogleFonts.outfit(
                                      fontSize: 16, fontWeight: FontWeight.w500,
                                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                                      color: isCompleted ? Colors.grey : theme.textTheme.bodyMedium?.color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ),
              ],
            ),
          ),
          Align(alignment: Alignment.topCenter, child: ConfettiWidget(confettiController: _confettiController, blastDirectionality: BlastDirectionality.explosive, numberOfParticles: 20, gravity: 0.2)),
          
          if (isMenuOpen) GestureDetector(onTap: () => setState(() => isMenuOpen = false), child: Container(color: Colors.black.withOpacity(0.5))),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            left: isMenuOpen ? 0 : -300,
            top: 0, bottom: 0, width: 300,
            child: _buildSidebar(theme, isDark),
          ),
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
        child: Text(label, style: TextStyle(color: isActive ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSidebar(ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: const BorderRadius.only(topRight: Radius.circular(24), bottomRight: Radius.circular(24))),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Settings", style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: cPrimary, borderRadius: BorderRadius.circular(4)), child: const Text("HERO", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)))]),
                  IconButton(icon: const Icon(LucideIcons.x), onPressed: () => setState(() => isMenuOpen = false))
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _menuItem(LucideIcons.moon, "Dark Mode", theme, trailing: Switch(
                    value: isDark, 
                    activeColor: cPrimary,
                    onChanged: (val) async {
                       _themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                       final prefs = await SharedPreferences.getInstance();
                       prefs.setBool('isDark', val);
                    }
                  )),
                  // --- Restored Buttons --- ✅
                  InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const InfoScreen(title: "Privacy Policy", contentType: 'privacy'))),
                    child: _menuItem(LucideIcons.shield, "Privacy Policy", theme),
                  ),
                  InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const InfoScreen(title: "About Us", contentType: 'about'))),
                    child: _menuItem(LucideIcons.info, "About Us", theme),
                  ),

                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Reset All Data", style: TextStyle(color: Color(0xFFFF4757), fontWeight: FontWeight.bold)),
                    leading: const Icon(LucideIcons.trash, color: Color(0xFFFF4757)),
                    onTap: () { setState(() { todos.clear(); _saveTodos(); isMenuOpen = false; }); },
                  )
                ],
              ),
            ),
            const Padding(padding: EdgeInsets.all(20), child: Text("Version 8.0 • FST Havoc", style: TextStyle(color: Colors.grey, fontSize: 10)))
          ],
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String text, ThemeData theme, {Widget? trailing}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600))),
          if (trailing != null) trailing
        ],
      ),
    );
  }
}

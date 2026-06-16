import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

/* ================= MAIN ================= */

void main() {
  runApp(const SproutApp());
}

class SproutApp extends StatelessWidget {
  const SproutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sprout',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7FAF8),
      ),
      home: const SplashScreen(),
    );
  }
}

/* ================= HOME SCREEN ================= */

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int stars = 0;
  File? imageFile;

  int totalTasks = 5;
  int completedTasks = 0;

  int get remainingTasks => totalTasks - completedTasks;

  @override
  void initState() {
    super.initState();
    loadStars();
  }

  // ================= LOCAL STORAGE =================
  Future<void> loadStars() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      stars = prefs.getInt('stars') ?? 0;
    });
  }

  Future<void> saveStars() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('stars', stars);
  }

  // ================= STAR SYSTEM =================
  void addStar() {
    setState(() {
      stars++;
    });
    saveStars();
  }

  // ================= QUIZ SCREEN =================
  Future<void> openActivity() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ActivityScreen()),
    );

    if (!mounted) return;

    if (result == true) {
      setState(() {
        completedTasks++;
      });

      addStar();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⭐ Star from Quiz!")),
      );
    }
  }

  // ================= CAMERA SCREEN =================
  Future<void> openCamera() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CameraScreen()),
    );

    if (!mounted) return;

    if (result is Map) {
      setState(() {
        imageFile = result["image"];
        completedTasks++;
      });

      addStar();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🎉 Plant Scanned +1 Star"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sprout 🌱"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // HEADER
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const Text(
                    "🌱 Sprout Adventure",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  const SizedBox(height: 10),

                  Text(
                    "⭐ Stars: $stars",
                    style: const TextStyle(color: Colors.white),
                  ),

                  Text(
                    "📌 Remaining Tasks: $remainingTasks",
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // BUTTONS
            ElevatedButton.icon(
              onPressed: openActivity,
              icon: const Icon(Icons.auto_stories),
              label: const Text("Learning Activity"),
            ),

            const SizedBox(height: 10),

            ElevatedButton.icon(
              onPressed: openCamera,
              icon: const Icon(Icons.camera_alt),
              label: const Text("Plant Explorer"),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LeaderboardScreen(stars: stars),
                  ),
                );
              },
              child: const Text("🏆 Leaderboard"),
            ),

            const SizedBox(height: 20),

            // IMAGE
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: imageFile == null
                    ? const Center(
                        child: Text(
                          "📷 No image yet\nStart scanning plants!",
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(imageFile!, fit: BoxFit.cover),
                      ),
              ),
            ),

            const SizedBox(height: 10),

            Text(
              completedTasks >= totalTasks
                  ? "🎉 All Tasks Completed!"
                  : "Keep going 🌱",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
/* ================= ACTIVITY SCREEN ================= */
class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  int currentIndex = 0;
  int score = 0;
  String selected = "";
  bool locked = false;

  final List<Map<String, dynamic>> allQuestions = [
    {"emoji": "🍎", "answer": "Apple", "options": ["Apple", "Banana", "Orange"]},
    {"emoji": "🐶", "answer": "Dog", "options": ["Cat", "Dog", "Cow"]},
    {"emoji": "🔴", "answer": "Red", "options": ["Red", "Blue", "Green"]},
    {"emoji": "🐱", "answer": "Cat", "options": ["Cat", "Dog", "Lion"]},
    {"emoji": "🍌", "answer": "Banana", "options": ["Apple", "Banana", "Orange"]},
    {"emoji": "🐘", "answer": "Elephant", "options": ["Elephant", "Tiger", "Lion"]},
  ];

  late List<Map<String, dynamic>> questions;

  @override
  void initState() {
    super.initState();
    questions = List.from(allQuestions)..shuffle();
  }

  void checkAnswer(String answer) {
    if (locked) return;

    final correct = questions[currentIndex]["answer"];

    setState(() {
      selected = answer;
    });

    // wrong answer → stay
    if (answer != correct) return;

    // correct answer
    locked = true;
    score++;

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      setState(() {
        selected = "";
        locked = false;

        if (currentIndex < questions.length - 1) {
          currentIndex++;
        } else {
          Navigator.pop(context, true);
        }
      });
    });
  }

@override
Widget build(BuildContext context) {
  if (questions.isEmpty) {
    return const Scaffold(
      body: Center(child: Text("No questions available")),
    );
  }

  if (currentIndex >= questions.length) {
    return const Scaffold(
      body: Center(child: Text("Quiz completed 🎉")),
    );
  }

  final q = questions[currentIndex];
  final correct = q["answer"];
  final isCorrect = selected == correct;

  return Scaffold(
    appBar: AppBar(
      title: const Text("Pro Quiz Game 🎮"),
      centerTitle: true,
    ),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "⭐ Score: $score",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            const Text(
              "What is this?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Text(
              q["emoji"],
              style: const TextStyle(fontSize: 100),
            ),

            const SizedBox(height: 25),

            ...q["options"].map<Widget>((opt) {
              final selectedNow = selected == opt;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(220, 55),
                    backgroundColor: selectedNow
                        ? (opt == correct
                            ? Colors.green.shade300
                            : Colors.red.shade300)
                        : Colors.blue.shade50,
                  ),
                  onPressed: locked ? null : () => checkAnswer(opt),
                  child: Text(opt),
                ),
              );
            }).toList(),

            const SizedBox(height: 20),

            if (selected.isNotEmpty)
              Text(
                isCorrect ? "🎉 Correct!" : "❌ Try Again",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? Colors.green : Colors.red,
                ),
              ),

            const SizedBox(height: 10),

            Text(
              "Question ${currentIndex + 1} / ${questions.length}",
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    ),
  );
}
}
/* ================= CAMERA SCREEN ================= */
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker picker = ImagePicker();

  File? imageFile;
  bool isPicking = false;

  int detectedCount = 0;
  String detectedLabel = "No prediction yet";

  Future<String> fakePrediction() async {
    await Future.delayed(const Duration(seconds: 1));
    final labels = ["flower", "plant", "tree", "leaf", "grass"];
    labels.shuffle();
    return labels.first;
  }

  /* ================= CAMERA PICK ================= */
  Future<void> openCamera() async {
    if (isPicking) return;
    isPicking = true;

    try {
      final picked = await picker.pickImage(source: ImageSource.camera);

      if (!mounted || picked == null) return;

      setState(() {
        imageFile = File(picked.path);
      });

      final prediction = await fakePrediction();

      setState(() {
        detectedLabel = prediction;
        detectedCount++;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("🌿 Detected: $prediction"),
          backgroundColor: Colors.green,
        ),
      );
    } finally {
      isPicking = false;
    }
  }

  /* ================= RETURN RESULT ================= */
  void claimReward() {
    if (detectedCount < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Need ${5 - detectedCount} more plants 🌱"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.pop(context, {
      "image": imageFile,
      "count": detectedCount,
      "success": true,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Plant Explorer 🌿"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            Text(
              "Found: $detectedCount / 5",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: imageFile == null
                  ? const Center(child: Text("No Image"))
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(imageFile!, fit: BoxFit.cover),
                    ),
            ),

            const SizedBox(height: 20),

            Text(
              "AI Guess: $detectedLabel",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: openCamera,
              icon: const Icon(Icons.camera_alt),
              label: const Text("Scan Plant"),
            ),

            const SizedBox(height: 10),

            ElevatedButton.icon(
              onPressed: claimReward,
              icon: const Icon(Icons.card_giftcard),
              label: const Text("Claim Reward"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class LeaderboardScreen extends StatelessWidget {
  final int stars;

  const LeaderboardScreen({super.key, required this.stars});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> players = [
      {"name": "You", "stars": stars},
      {"name": "Aarav", "stars": 18},
      {"name": "Diya", "stars": 15},
      {"name": "Kabir", "stars": 10},
      {"name": "Meera", "stars": 8},
    ];

    players.sort((a, b) => b["stars"].compareTo(a["stars"]));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Leaderboard 🏆"),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: players.length,
        itemBuilder: (context, index) {
          final p = players[index];

          return ListTile(
            leading: CircleAvatar(child: Text("#${index + 1}")),
            title: Text(p["name"]),
            trailing: Text("⭐ ${p["stars"]}"),
          );
        },
      ),
    );
  }
}
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> bounce;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    bounce = Tween<double>(begin: 0, end: 15).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      body: Center(
        child: AnimatedBuilder(
          animation: bounce,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // bouncing logo
                Transform.translate(
                  offset: Offset(0, -bounce.value),
                  child: const Text(
                    "🌱🐣",
                    style: TextStyle(fontSize: 75),
                  ),
                ),

                const SizedBox(height: 20),

                // app name
                const Text(
                  "Sprout",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),

                const SizedBox(height: 8),

                // tagline
                const Text(
                  "Learn • Play • Grow",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 20),

                // loading dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    _Dot(),
                    SizedBox(width: 6),
                    _Dot(delay: 200),
                    SizedBox(width: 6),
                    _Dot(delay: 400),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/* ================= LOADING DOT WIDGET ================= */

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({this.delay = 0});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scale;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    scale = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scale,
      child: const CircleAvatar(
        radius: 4,
        backgroundColor: Colors.green,
      ),
    );
  }
}
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Text(
              "🌱 Sprout Login",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Enter your name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

        ElevatedButton(
  onPressed: () {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
      (route) => false,
    );
  },
  child: const Text("Continue"),
),
          ],
        ),
      ),
    );
  }
}
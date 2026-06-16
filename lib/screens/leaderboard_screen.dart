import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  final List<Map<String, dynamic>> dummyData = const [
    {"name": "You", "stars": 12},
    {"name": "Aarav", "stars": 10},
    {"name": "Diya", "stars": 8},
    {"name": "Rohan", "stars": 6},
    {"name": "Anaya", "stars": 4},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🏆 Leaderboard"),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: dummyData.length,
        itemBuilder: (context, index) {
          final user = dummyData[index];

          return Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Text("#${index + 1}"),
              ),
              title: Text(user["name"]),
              trailing: Text("⭐ ${user["stars"]}"),
            ),
          );
        },
      ),
    );
  }
}
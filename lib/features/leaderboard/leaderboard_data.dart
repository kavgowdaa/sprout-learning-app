class LeaderboardData {
  static List<Map<String, dynamic>> players = [
    {"name": "You", "stars": 0},
    {"name": "Aarav", "stars": 18},
    {"name": "Diya", "stars": 14},
    {"name": "Rohan", "stars": 9},
    {"name": "Anaya", "stars": 6},
  ];

  static void updateUserScore(int stars) {
    players[0]["stars"] = stars;

    players.sort((a, b) => b["stars"].compareTo(a["stars"]));
  }
}
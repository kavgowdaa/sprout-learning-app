class RewardSystem {
  static String getBadge(int stars) {
    if (stars >= 20) return "🏆 Gold Explorer";
    if (stars >= 10) return "🥈 Silver Explorer";
    if (stars >= 5) return "🥉 Bronze Explorer";
    return "🌱 Beginner";
  }

  static String nextGoal(int stars) {
    if (stars < 5) return "Earn 5 stars for Bronze badge";
    if (stars < 10) return "Earn 10 stars for Silver badge";
    if (stars < 20) return "Earn 20 stars for Gold badge";
    return "Max level reached 🎉";
  }
}
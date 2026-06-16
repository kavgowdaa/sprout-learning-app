import 'dart:io';
import 'package:flutter/material.dart';

class GameController extends ChangeNotifier {
  int stars = 0;

  int totalTasks = 5;
  int completedTasks = 0;

  File? lastImage;

  double get progress =>
      (completedTasks / totalTasks).clamp(0.0, 1.0);

  int get remaining => (totalTasks - completedTasks).clamp(0, totalTasks);

  void addStar() {
    stars++;
    notifyListeners();
  }

  void completeTask({File? image}) {
    if (completedTasks < totalTasks) {
      completedTasks++;
    }

    if (image != null) {
      lastImage = image;
    }

    addStar();
    notifyListeners();
  }

  void reset() {
    stars = 0;
    completedTasks = 0;
    lastImage = null;
    notifyListeners();
  }
}
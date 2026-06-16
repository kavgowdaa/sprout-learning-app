import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CameraLearningScreen extends StatefulWidget {
  const CameraLearningScreen({super.key});

  @override
  State<CameraLearningScreen> createState() => _CameraLearningScreenState();
}

class _CameraLearningScreenState extends State<CameraLearningScreen> {
  final ImagePicker picker = ImagePicker();

  File? imageFile;

  int count = 0;
  final int target = 5;

  bool busy = false;

  Future<void> captureImage() async {
    if (busy) return;

    busy = true;

    final picked = await picker.pickImage(
      source: ImageSource.camera,
    );

    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
        count++;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Progress: $count / $target")),
      );
    }

    busy = false;

    if (count >= target) {
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pop(context, true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Find Objects 🌿")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Task: Capture $target objects",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text("Found: $count / $target"),

            const SizedBox(height: 20),

            Container(
              height: 300,
              width: double.infinity,
              color: Colors.grey.shade200,
              child: imageFile == null
                  ? const Center(child: Text("No Image"))
                  : Image.file(imageFile!, fit: BoxFit.cover),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: captureImage,
              icon: const Icon(Icons.camera_alt),
              label: const Text("Capture"),
            ),
          ],
        ),
      ),
    );
  }
}
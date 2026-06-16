import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final picker = ImagePicker();

  File? imageFile;
  int detectedCount = 0;
  String label = "No prediction";

  Future<void> openCamera() async {
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (!mounted || picked == null) return;

    setState(() {
      imageFile = File(picked.path);
      detectedCount++;
      label = "plant";
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("🌿 Scanned")),
    );
  }

  void claimReward() {
    if (detectedCount < 5) return;

    Navigator.pop(context, {
      "image": imageFile,
      "count": detectedCount,
      "success": true,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Camera")),
      body: Column(
        children: [
          if (imageFile != null) Image.file(imageFile!, height: 200),

          Text("Detected: $detectedCount"),
          Text("AI: $label"),

          ElevatedButton(
            onPressed: openCamera,
            child: const Text("Scan"),
          ),

          ElevatedButton(
            onPressed: claimReward,
            child: const Text("Claim Reward"),
          ),
        ],
      ),
    );
  }
}
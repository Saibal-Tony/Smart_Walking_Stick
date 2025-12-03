import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late VideoPlayerController _controller;

  // TODO: replace with your actual Raspberry Pi streaming URL
  // Example: "http://192.168.1.20:8080/stream.mjpg" or HLS "http://pi-ip:8080/stream.m3u8"
  final String streamUrl = 'http://YOUR_PI_IP:8080/stream.m3u8';

  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // Create video controller
    _controller = VideoPlayerController.networkUrl(Uri.parse(streamUrl))
      ..initialize()
          .then((_) {
            setState(() {
              _isInitialized = true;
            });
            _controller.play();
          })
          .catchError((error) {
            setState(() {
              _errorMessage = "Error loading video: $error";
            });
          });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (_errorMessage != null) {
      body = Text(_errorMessage!, style: const TextStyle(color: Colors.red));
    } else if (!_isInitialized) {
      body = const CircularProgressIndicator();
    } else {
      body = AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: VideoPlayer(_controller),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Live Camera Feed')),
      body: Center(child: body),
    );
  }
}

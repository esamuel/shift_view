import 'package:flutter/material.dart';

class GuideVideoPlayer extends StatelessWidget {
  final String videoUrl;
  final String thumbnailUrl;

  const GuideVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.thumbnailUrl,
  });

  @override
  Widget build(BuildContext context) {
    // For now, just show the thumbnail
    return Image.asset(
      thumbnailUrl,
      fit: BoxFit.cover,
    );
  }
} 
import 'dart:io';

void main() async {
  // Create directories
  await Directory('assets').create(recursive: true);
  await Directory('assets/icon').create(recursive: true);
  await Directory('assets/images').create(recursive: true);
  await Directory('assets/videos').create(recursive: true);

  // Create a placeholder app icon if it doesn't exist
  final iconFile = File('assets/icon/app_icon.png');
  if (!await iconFile.exists()) {
    // You should replace this with your actual app icon
    print('Please add your app icon at: assets/icon/app_icon.png');
  }

  // Create .gitkeep files to track empty directories
  await File('assets/images/.gitkeep').create();
  await File('assets/videos/.gitkeep').create();
} 
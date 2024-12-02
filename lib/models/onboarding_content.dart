import 'package:flutter/material.dart';

class OnboardingContent {
  final String title;
  final String description;
  final String videoAsset;
  final String thumbnailAsset;
  final List<String> bulletPoints;
  final IconData icon;

  OnboardingContent({
    required this.title,
    required this.description,
    required this.videoAsset,
    required this.thumbnailAsset,
    required this.bulletPoints,
    required this.icon,
  });
}

class OnboardingData {
  static List<OnboardingContent> getContent() {
    return [
      OnboardingContent(
        title: 'Welcome to ShiftView',
        description: 'Your complete shift management solution',
        videoAsset: 'assets/videos/welcome.mp4',
        thumbnailAsset: 'assets/images/welcome_thumb.jpg',
        bulletPoints: [
          'Track your work hours easily',
          'Calculate wages automatically',
          'Generate detailed reports',
        ],
        icon: Icons.home_outlined,
      ),
      OnboardingContent(
        title: 'Essential Settings',
        description: 'Set up your work rules first',
        videoAsset: 'assets/videos/settings.mp4',
        thumbnailAsset: 'assets/images/settings_thumb.jpg',
        bulletPoints: [
          'Configure hourly rates',
          'Set up overtime rules',
          'Customize special day rates',
        ],
        icon: Icons.settings_outlined,
      ),
      OnboardingContent(
        title: 'Recording Shifts',
        description: 'Track your work hours effortlessly',
        videoAsset: 'assets/videos/shifts.mp4',
        thumbnailAsset: 'assets/images/shifts_thumb.jpg',
        bulletPoints: [
          'Add shifts with a few taps',
          'Include notes and special conditions',
          'View calculated earnings instantly',
        ],
        icon: Icons.work_outline,
      ),
      OnboardingContent(
        title: 'Reports & Analytics',
        description: 'Monitor your work and earnings',
        videoAsset: 'assets/videos/reports.mp4',
        thumbnailAsset: 'assets/images/reports_thumb.jpg',
        bulletPoints: [
          'View detailed summaries',
          'Export to PDF or CSV',
          'Track overtime and bonuses',
        ],
        icon: Icons.bar_chart_outlined,
      ),
    ];
  }
} 
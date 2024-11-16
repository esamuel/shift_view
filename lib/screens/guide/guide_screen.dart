import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'sections/getting_started_section.dart';
import 'sections/core_features_section.dart';
import 'sections/advanced_features_section.dart';
import 'sections/customization_section.dart';
import 'sections/tips_section.dart';
import 'sections/troubleshooting_section.dart';
import 'sections/video_library_section.dart';
import 'widgets/guide_video_player.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.appGuideTitle),
      ),
      body: ListView(
        children: [
          // Welcome Section
          _buildWelcomeSection(context),
          
          // Main Guide Sections
          _buildGuideSection(
            context,
            title: localizations.gettingStartedTitle,
            icon: Icons.play_circle_outline,
            onTap: () => _navigateToSection(context, const GettingStartedSection()),
          ),
          _buildGuideSection(
            context,
            title: localizations.coreFeaturesTitle,
            icon: Icons.featured_play_list,
            onTap: () => _navigateToSection(context, const CoreFeaturesSection()),
          ),
          _buildGuideSection(
            context,
            title: localizations.advancedFeaturesTitle,
            icon: Icons.psychology,
            onTap: () => _navigateToSection(context, const AdvancedFeaturesSection()),
          ),
          _buildGuideSection(
            context,
            title: localizations.customizationTitle,
            icon: Icons.palette,
            onTap: () => _navigateToSection(context, const CustomizationSection()),
          ),
          _buildGuideSection(
            context,
            title: localizations.tipsAndTricksTitle,
            icon: Icons.lightbulb,
            onTap: () => _navigateToSection(context, const TipsSection()),
          ),
          _buildGuideSection(
            context,
            title: localizations.troubleshootingTitle,
            icon: Icons.build,
            onTap: () => _navigateToSection(context, const TroubleshootingSection()),
          ),
          _buildGuideSection(
            context,
            title: localizations.videoLibraryTitle,
            icon: Icons.video_library,
            onTap: () => _navigateToSection(context, const VideoLibrarySection()),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.welcomeToGuide,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.guideIntroduction,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            GuideVideoPlayer(
              videoUrl: 'assets/videos/welcome_guide.mp4',
              thumbnailUrl: 'assets/images/welcome_thumbnail.jpg',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  void _navigateToSection(BuildContext context, Widget section) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => section),
    );
  }
} 
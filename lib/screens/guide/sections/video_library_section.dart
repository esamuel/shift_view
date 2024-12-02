import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../widgets/guide_section_card.dart';

class VideoLibrarySection extends StatelessWidget {
  const VideoLibrarySection({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.videoLibraryTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Getting Started Videos
          GuideSectionCard(
            title: localizations.gettingStartedVideosTitle,
            content: localizations.gettingStartedVideosContent,
            videoUrl: 'assets/videos/getting_started.mp4',
            thumbnailUrl: 'assets/images/getting_started_thumbnail.jpg',
            steps: [
              localizations.appOverview,
              localizations.basicSetup,
              localizations.firstShiftGuide,
              localizations.navigationBasics,
            ],
          ),

          const SizedBox(height: 16),

          // Core Features Videos
          GuideSectionCard(
            title: localizations.coreFeaturesVideosTitle,
            content: localizations.coreFeaturesVideosContent,
            videoUrl: 'assets/videos/core_features.mp4',
            thumbnailUrl: 'assets/images/core_features_thumbnail.jpg',
            steps: [
              localizations.shiftManagementGuide,
              localizations.overtimeRulesGuide,
              localizations.reportsGuide,
              localizations.settingsGuide,
            ],
          ),

          const SizedBox(height: 16),

          // Advanced Features Videos
          GuideSectionCard(
            title: localizations.advancedFeaturesVideosTitle,
            content: localizations.advancedFeaturesVideosContent,
            videoUrl: 'assets/videos/advanced_features.mp4',
            thumbnailUrl: 'assets/images/advanced_features_thumbnail.jpg',
            steps: [
              localizations.customCalculations,
              localizations.dataManagementGuide,
              localizations.specialDaysSetup,
              localizations.advancedSettings,
            ],
          ),

          const SizedBox(height: 16),

          // Tips and Tricks Videos
          GuideSectionCard(
            title: localizations.tipsAndTricksVideosTitle,
            content: localizations.tipsAndTricksVideosContent,
            videoUrl: 'assets/videos/tips_tricks.mp4',
            thumbnailUrl: 'assets/images/tips_tricks_thumbnail.jpg',
            steps: [
              localizations.timeManagementTips,
              localizations.productivityHacks,
              localizations.usefulShortcuts,
              localizations.bestPracticesGuide,
            ],
          ),

          const SizedBox(height: 16),

          // Troubleshooting Videos
          GuideSectionCard(
            title: localizations.troubleshootingVideosTitle,
            content: localizations.troubleshootingVideosContent,
            videoUrl: 'assets/videos/troubleshooting.mp4',
            thumbnailUrl: 'assets/images/troubleshooting_thumbnail.jpg',
            steps: [
              localizations.commonIssuesSolutions,
              localizations.dataRecoveryGuide,
              localizations.errorResolution,
              localizations.preventiveMeasures,
            ],
          ),

          const SizedBox(height: 16),

          // Additional Resources
          GuideSectionCard(
            title: localizations.additionalResourcesTitle,
            content: localizations.additionalResourcesContent,
            links: [
              GuideSectionLink(
                title: localizations.fullDocumentation,
                onTap: () => _openDocumentation(context),
              ),
              GuideSectionLink(
                title: localizations.videoTutorials,
                onTap: () => _openVideoTutorials(context),
              ),
              GuideSectionLink(
                title: localizations.communityGuides,
                onTap: () => _openCommunityGuides(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openDocumentation(BuildContext context) {
    // Implementation for opening documentation
  }

  void _openVideoTutorials(BuildContext context) {
    // Implementation for opening video tutorials
  }

  void _openCommunityGuides(BuildContext context) {
    // Implementation for opening community guides
  }
} 
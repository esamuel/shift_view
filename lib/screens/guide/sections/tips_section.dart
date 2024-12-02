import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../widgets/guide_section_card.dart';

class TipsSection extends StatelessWidget {
  const TipsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.tipsAndTricksTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Quick Actions
          GuideSectionCard(
            title: localizations.quickActionsTitle,
            content: localizations.quickActionsContent,
            videoUrl: 'assets/videos/quick_actions.mp4',
            thumbnailUrl: 'assets/images/quick_actions_thumbnail.jpg',
            steps: [
              localizations.swipeActions,
              localizations.longPressFeatures,
              localizations.quickAdd,
              localizations.gestureShortcuts,
            ],
          ),

          const SizedBox(height: 16),

          // Time-Saving Features
          GuideSectionCard(
            title: localizations.timeSavingTitle,
            content: localizations.timeSavingContent,
            steps: [
              localizations.shiftTemplates,
              localizations.copyPreviousShift,
              localizations.bulkActions,
              localizations.favoriteSettings,
            ],
          ),

          const SizedBox(height: 16),

          // Best Practices
          GuideSectionCard(
            title: localizations.bestPracticesTitle,
            content: localizations.bestPracticesContent,
            videoUrl: 'assets/videos/best_practices.mp4',
            thumbnailUrl: 'assets/images/best_practices_thumbnail.jpg',
            steps: [
              localizations.regularBackups,
              localizations.organizingShifts,
              localizations.trackingOvertime,
              localizations.monitoringEarnings,
            ],
          ),

          const SizedBox(height: 16),

          // Common Workflows
          GuideSectionCard(
            title: localizations.commonWorkflowsTitle,
            content: localizations.commonWorkflowsContent,
            videoUrl: 'assets/videos/common_workflows.mp4',
            thumbnailUrl: 'assets/images/common_workflows_thumbnail.jpg',
            steps: [
              localizations.dailyRoutine,
              localizations.weeklyReview,
              localizations.monthlyReporting,
              localizations.yearEndTasks,
            ],
          ),

          const SizedBox(height: 16),

          // Pro Tips
          GuideSectionCard(
            title: localizations.proTipsTitle,
            content: localizations.proTipsContent,
            steps: [
              localizations.advancedFeatures,
              localizations.hiddenFeatures,
              localizations.powerUserTips,
              localizations.troubleshootingTips,
            ],
          ),

          const SizedBox(height: 16),

          // Learn More
          GuideSectionCard(
            title: localizations.learnMoreTitle,
            content: localizations.learnMoreContent,
            links: [
              GuideSectionLink(
                title: localizations.advancedTutorialsLink,
                onTap: () => _navigateToSection(context, 'advanced-tutorials'),
              ),
              GuideSectionLink(
                title: localizations.videoGuidesLink,
                onTap: () => _navigateToSection(context, 'video-guides'),
              ),
              GuideSectionLink(
                title: localizations.frequentlyAskedQuestionsLink,
                onTap: () => _navigateToSection(context, 'faq'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToSection(BuildContext context, String section) {
    // Navigation logic to other sections
  }
} 
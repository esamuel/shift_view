import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../widgets/guide_section_card.dart';

class GettingStartedSection extends StatelessWidget {
  const GettingStartedSection({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.gettingStartedTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Initial Setup Card
          GuideSectionCard(
            title: localizations.initialSetupTitle,
            content: localizations.initialSetupContent,
            videoUrl: 'assets/videos/initial_setup.mp4',
            thumbnailUrl: 'assets/images/initial_setup_thumbnail.jpg',
          ),

          const SizedBox(height: 16),

          // Basic Navigation Card
          GuideSectionCard(
            title: localizations.basicNavigationTitle,
            content: localizations.basicNavigationContent,
            steps: [
              localizations.homeScreenDescription,
              localizations.shiftManagerDescription,
              localizations.reportsDescription,
              localizations.settingsDescription,
            ],
          ),

          const SizedBox(height: 16),

          // First Shift Card
          GuideSectionCard(
            title: localizations.firstShiftTitle,
            content: localizations.firstShiftContent,
            videoUrl: 'assets/videos/add_first_shift.mp4',
            thumbnailUrl: 'assets/images/add_shift_thumbnail.jpg',
            steps: [
              localizations.openShiftManager,
              localizations.tapAddShift,
              localizations.selectDateTime,
              localizations.saveShift,
            ],
          ),

          const SizedBox(height: 16),

          // Settings Setup Card
          GuideSectionCard(
            title: localizations.settingsSetupTitle,
            content: localizations.settingsSetupContent,
            steps: [
              localizations.hourlyWageSetup,
              localizations.taxDeductionSetup,
              localizations.workWeekSetup,
              localizations.languageSetup,
            ],
          ),

          const SizedBox(height: 16),

          // Next Steps Card
          GuideSectionCard(
            title: localizations.nextStepsTitle,
            content: localizations.nextStepsContent,
            links: [
              GuideSectionLink(
                title: localizations.exploreOvertimeRules,
                onTap: () => _navigateToSection(context, 'overtime'),
              ),
              GuideSectionLink(
                title: localizations.learnAboutReports,
                onTap: () => _navigateToSection(context, 'reports'),
              ),
              GuideSectionLink(
                title: localizations.discoverAdvancedFeatures,
                onTap: () => _navigateToSection(context, 'advanced'),
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
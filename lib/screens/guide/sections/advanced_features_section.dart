import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../widgets/guide_section_card.dart';

class AdvancedFeaturesSection extends StatelessWidget {
  const AdvancedFeaturesSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.advancedFeaturesTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Overtime Rules
          GuideSectionCard(
            title: localizations.overtimeRulesTitle,
            content: localizations.overtimeRulesContent,
            videoUrl: 'assets/videos/overtime_rules.mp4',
            thumbnailUrl: 'assets/images/overtime_rules_thumbnail.jpg',
            steps: [
              localizations.creatingOvertimeRules,
              localizations.editingOvertimeRules,
              localizations.applyingOvertimeRules,
              localizations.specialDayRules,
            ],
          ),

          const SizedBox(height: 16),

          // Special Days Management
          GuideSectionCard(
            title: localizations.specialDaysTitle,
            content: localizations.specialDaysContent,
            videoUrl: 'assets/videos/special_days.mp4',
            thumbnailUrl: 'assets/images/special_days_thumbnail.jpg',
            steps: [
              localizations.markingSpecialDays,
              localizations.configuringSpecialRates,
              localizations.holidaySettings,
              localizations.weekendSettings,
            ],
          ),

          const SizedBox(height: 16),

          // Data Export and Backup
          GuideSectionCard(
            title: localizations.dataExportTitle,
            content: localizations.dataExportContent,
            videoUrl: 'assets/videos/data_export.mp4',
            thumbnailUrl: 'assets/images/data_export_thumbnail.jpg',
            steps: [
              localizations.exportingReports,
              localizations.creatingBackups,
              localizations.restoringData,
              localizations.dataFormats,
            ],
          ),

          const SizedBox(height: 16),

          // Advanced Calculations
          GuideSectionCard(
            title: localizations.advancedCalculationsTitle,
            content: localizations.advancedCalculationsContent,
            steps: [
              localizations.complexOvertimeCalculations,
              localizations.taxDeductionFormulas,
              localizations.multiRateCalculations,
              localizations.totalEarningsBreakdown,
            ],
          ),

          const SizedBox(height: 16),

          // Customization Options
          GuideSectionCard(
            title: localizations.customizationOptionsTitle,
            content: localizations.customizationOptionsContent,
            steps: [
              localizations.settingPreferences,
              localizations.configuringDisplayOptions,
              localizations.personalizingReports,
              localizations.customizingNotifications,
            ],
          ),

          const SizedBox(height: 16),

          // Next Steps Card
          GuideSectionCard(
            title: localizations.moreAdvancedTopicsTitle,
            content: localizations.moreAdvancedTopicsContent,
            links: [
              GuideSectionLink(
                title: localizations.dataManagementLink,
                onTap: () => _navigateToSection(context, 'data'),
              ),
              GuideSectionLink(
                title: localizations.troubleshootingLink,
                onTap: () => _navigateToSection(context, 'troubleshooting'),
              ),
              GuideSectionLink(
                title: localizations.bestPracticesLink,
                onTap: () => _navigateToSection(context, 'best-practices'),
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
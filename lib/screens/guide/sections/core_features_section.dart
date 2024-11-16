import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../widgets/guide_section_card.dart';

class CoreFeaturesSection extends StatelessWidget {
  const CoreFeaturesSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.coreFeaturesTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Shift Management
          GuideSectionCard(
            title: localizations.shiftManagementTitle,
            content: localizations.shiftManagementContent,
            videoUrl: 'assets/videos/shift_management.mp4',
            thumbnailUrl: 'assets/images/shift_management_thumbnail.jpg',
            steps: [
              localizations.addingShifts,
              localizations.editingShifts,
              localizations.deletingShifts,
              localizations.specialDaysManagement,
            ],
          ),

          const SizedBox(height: 16),

          // Time Tracking
          GuideSectionCard(
            title: localizations.timeTrackingTitle,
            content: localizations.timeTrackingContent,
            videoUrl: 'assets/videos/time_tracking.mp4',
            thumbnailUrl: 'assets/images/time_tracking_thumbnail.jpg',
            steps: [
              localizations.regularHoursTracking,
              localizations.overtimeCalculation,
              localizations.specialRatesHandling,
            ],
          ),

          const SizedBox(height: 16),

          // Financial Management
          GuideSectionCard(
            title: localizations.financialManagementTitle,
            content: localizations.financialManagementContent,
            videoUrl: 'assets/videos/financial_management.mp4',
            thumbnailUrl: 'assets/images/financial_management_thumbnail.jpg',
            steps: [
              localizations.wageCalculations,
              localizations.taxDeductions,
              localizations.currencySettings,
              localizations.reportsAndExports,
            ],
          ),

          const SizedBox(height: 16),

          // Reports and Analytics
          GuideSectionCard(
            title: localizations.reportsAnalyticsTitle,
            content: localizations.reportsAnalyticsContent,
            videoUrl: 'assets/videos/reports_analytics.mp4',
            thumbnailUrl: 'assets/images/reports_analytics_thumbnail.jpg',
            steps: [
              localizations.weeklyReports,
              localizations.monthlyReports,
              localizations.exportOptions,
              localizations.dataVisualization,
            ],
          ),

          const SizedBox(height: 16),

          // Data Management
          GuideSectionCard(
            title: localizations.dataManagementTitle,
            content: localizations.dataManagementContent,
            steps: [
              localizations.backupData,
              localizations.restoreData,
              localizations.dataPrivacy,
              localizations.dataStorage,
            ],
          ),

          const SizedBox(height: 16),

          // Next Steps Card
          GuideSectionCard(
            title: localizations.learnMoreTitle,
            content: localizations.learnMoreContent,
            links: [
              GuideSectionLink(
                title: localizations.advancedFeaturesLink,
                onTap: () => _navigateToSection(context, 'advanced'),
              ),
              GuideSectionLink(
                title: localizations.customizationLink,
                onTap: () => _navigateToSection(context, 'customization'),
              ),
              GuideSectionLink(
                title: localizations.tipsAndTricksLink,
                onTap: () => _navigateToSection(context, 'tips'),
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
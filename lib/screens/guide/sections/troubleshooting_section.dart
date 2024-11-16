import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../widgets/guide_section_card.dart';

class TroubleshootingSection extends StatelessWidget {
  const TroubleshootingSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.troubleshootingTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Common Issues
          GuideSectionCard(
            title: localizations.commonIssuesTitle,
            content: localizations.commonIssuesContent,
            videoUrl: 'assets/videos/common_issues.mp4',
            thumbnailUrl: 'assets/images/common_issues_thumbnail.jpg',
            steps: [
              localizations.calculationIssues,
              localizations.syncProblems,
              localizations.displayGlitches,
              localizations.performanceIssues,
            ],
          ),

          const SizedBox(height: 16),

          // Data Management Issues
          GuideSectionCard(
            title: localizations.dataManagementIssuesTitle,
            content: localizations.dataManagementIssuesContent,
            steps: [
              localizations.backupRestoreIssues,
              localizations.dataLossRecovery,
              localizations.corruptedDataFix,
              localizations.importExportProblems,
            ],
          ),

          const SizedBox(height: 16),

          // Settings and Configuration
          GuideSectionCard(
            title: localizations.settingsIssuesTitle,
            content: localizations.settingsIssuesContent,
            videoUrl: 'assets/videos/settings_troubleshooting.mp4',
            thumbnailUrl: 'assets/images/settings_issues_thumbnail.jpg',
            steps: [
              localizations.preferencesReset,
              localizations.languageIssues,
              localizations.currencyProblems,
              localizations.timeZoneIssues,
            ],
          ),

          const SizedBox(height: 16),

          // Error Messages
          GuideSectionCard(
            title: localizations.errorMessagesTitle,
            content: localizations.errorMessagesContent,
            steps: [
              localizations.commonErrors,
              localizations.errorSolutions,
              localizations.errorPrevention,
              localizations.errorReporting,
            ],
          ),

          const SizedBox(height: 16),

          // App Reset and Recovery
          GuideSectionCard(
            title: localizations.appResetTitle,
            content: localizations.appResetContent,
            videoUrl: 'assets/videos/app_reset.mp4',
            thumbnailUrl: 'assets/images/app_reset_thumbnail.jpg',
            steps: [
              localizations.softReset,
              localizations.hardReset,
              localizations.dataBackupBeforeReset,
              localizations.postResetSetup,
            ],
          ),

          const SizedBox(height: 16),

          // Contact Support
          GuideSectionCard(
            title: localizations.contactSupportTitle,
            content: localizations.contactSupportContent,
            links: [
              GuideSectionLink(
                title: localizations.emailSupport,
                onTap: () => _launchEmail(context),
              ),
              GuideSectionLink(
                title: localizations.reportBug,
                onTap: () => _reportBug(context),
              ),
              GuideSectionLink(
                title: localizations.requestFeature,
                onTap: () => _requestFeature(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _launchEmail(BuildContext context) {
    // Implementation for launching email client
  }

  void _reportBug(BuildContext context) {
    // Implementation for bug reporting
  }

  void _requestFeature(BuildContext context) {
    // Implementation for feature requests
  }
} 
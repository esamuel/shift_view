import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final appState = Provider.of<AppState>(context);
    appState.getCurrencySymbol();

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.infoTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSection(localizations.appGuideIntroduction,
              localizations.appGuideIntroductionContent),
          _buildSection(localizations.appGuideGettingStarted,
              '${localizations.appGuideSettingUp}\n\n${localizations.appGuideNavigatingApp}'),
          _buildSection(
              localizations.appGuideSettings,
              '${localizations.appGuideHourlyWage}\n\n'
              '${localizations.appGuideTaxDeduction}\n\n'
              '${localizations.appGuideWorkWeekStart}\n\n'
              '${localizations.appGuideLanguage}\n\n'
              '${localizations.appGuideCurrency}'),
          _buildSection(
              localizations.appGuideManagingShifts,
              '${localizations.appGuideAddingShift}\n\n'
              '${localizations.appGuideEditingShift}\n\n'
              '${localizations.appGuideDeletingShift}'),
          _buildSection(
              localizations.appGuideOvertimeRules,
              '${localizations.appGuideCreatingOvertimeRule}\n\n'
              '${localizations.appGuideEditingOvertimeRule}\n\n'
              '${localizations.appGuideDeletingOvertimeRule}'),
          _buildSection(
              localizations.appGuideReports,
              '${localizations.appGuideWeeklyReport}\n\n'
              '${localizations.appGuideMonthlyReport}\n\n'
              '${localizations.appGuideExportingReports}'),
          _buildSection(
              localizations.appGuideCalculations,
              '${localizations.appGuideWageCalculation}\n\n'
              '${localizations.appGuideOvertimeCalculation}\n\n'
              '${localizations.appGuideTaxEstimation}'),
          _buildSection(localizations.appGuideTipsAndTricks,
              localizations.appGuideTipsAndTricksContent),
          _buildSection(localizations.appGuideTroubleshooting,
              localizations.appGuideTroubleshootingContent),
          _buildSection(localizations.appGuidePrivacyAndDataSecurity,
              localizations.appGuidePrivacyAndDataSecurityContent),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              localizations.appGuideFooter,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
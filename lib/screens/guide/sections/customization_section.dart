import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../widgets/guide_section_card.dart';

class CustomizationSection extends StatelessWidget {
  const CustomizationSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.customizationTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Language and Localization
          GuideSectionCard(
            title: localizations.languageLocalizationTitle,
            content: localizations.languageLocalizationContent,
            videoUrl: 'assets/videos/language_settings.mp4',
            thumbnailUrl: 'assets/images/language_settings_thumbnail.jpg',
            steps: [
              localizations.changingLanguage,
              localizations.dateTimeFormats,
              localizations.numberFormats,
              localizations.rtlSupport,
            ],
          ),

          const SizedBox(height: 16),

          // Display Settings
          GuideSectionCard(
            title: localizations.displaySettingsTitle,
            content: localizations.displaySettingsContent,
            videoUrl: 'assets/videos/display_settings.mp4',
            thumbnailUrl: 'assets/images/display_settings_thumbnail.jpg',
            steps: [
              localizations.customizingLayout,
              localizations.colorSchemes,
              localizations.fontSizes,
              localizations.themeSettings,
            ],
          ),

          const SizedBox(height: 16),

          // Currency and Formats
          GuideSectionCard(
            title: localizations.currencyFormatsTitle,
            content: localizations.currencyFormatsContent,
            steps: [
              localizations.settingCurrency,
              localizations.numberFormatting,
              localizations.decimalPlaces,
              localizations.currencySymbols,
            ],
          ),

          const SizedBox(height: 16),

          // Report Customization
          GuideSectionCard(
            title: localizations.reportCustomizationTitle,
            content: localizations.reportCustomizationContent,
            videoUrl: 'assets/videos/report_customization.mp4',
            thumbnailUrl: 'assets/images/report_customization_thumbnail.jpg',
            steps: [
              localizations.customizingReportLayout,
              localizations.choosingColumns,
              localizations.sortingOptions,
              localizations.exportFormats,
            ],
          ),

          const SizedBox(height: 16),

          // Work Schedule Settings
          GuideSectionCard(
            title: localizations.workScheduleSettingsTitle,
            content: localizations.workScheduleSettingsContent,
            steps: [
              localizations.weekStartDay,
              localizations.defaultShiftDuration,
              localizations.breakTimeSettings,
              localizations.overtimePreferences,
            ],
          ),

          const SizedBox(height: 16),

          // Next Steps Card
          GuideSectionCard(
            title: localizations.moreCustomizationTitle,
            content: localizations.moreCustomizationContent,
            links: [
              GuideSectionLink(
                title: localizations.advancedSettingsLink,
                onTap: () => _navigateToSection(context, 'advanced-settings'),
              ),
              GuideSectionLink(
                title: localizations.personalPreferencesLink,
                onTap: () => _navigateToSection(context, 'preferences'),
              ),
              GuideSectionLink(
                title: localizations.backupSettingsLink,
                onTap: () => _navigateToSection(context, 'backup-settings'),
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
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appGuideTitle),
      ),
      body: ListView(
        children: [
          // Main Guide Sections
          _buildGuideSection(
            context: context,
            title: l10n.gettingStartedTitle,
            content: l10n.guideIntroduction,
            subsections: [
              GuideLink(
                title: l10n.initialSetupTitle,
                onTap: () => _navigateToSubsection(context, 'initial_setup'),
              ),
              GuideLink(
                title: l10n.basicNavigationTitle,
                onTap: () => _navigateToSubsection(context, 'basic_navigation'),
              ),
              GuideLink(
                title: l10n.firstShiftTitle,
                onTap: () => _navigateToSubsection(context, 'first_shift'),
              ),
            ],
          ),
          _buildGuideSection(
            context: context,
            title: l10n.coreFeaturesTitle,
            content: l10n.coreFeaturesVideosContent,
            subsections: [
              GuideLink(
                title: l10n.shiftManagementTitle,
                onTap: () => _navigateToSubsection(context, 'shift_management'),
              ),
              GuideLink(
                title: l10n.timeTrackingTitle,
                onTap: () => _navigateToSubsection(context, 'time_tracking'),
              ),
              GuideLink(
                title: l10n.financialManagementTitle,
                onTap: () => _navigateToSubsection(context, 'financial_management'),
              ),
            ],
          ),
          _buildGuideSection(
            context: context,
            title: l10n.advancedFeaturesTitle,
            content: l10n.advancedFeaturesVideosContent,
            subsections: [
              GuideLink(
                title: l10n.overtimeRulesTitle,
                onTap: () => _navigateToSubsection(context, 'overtime_rules'),
              ),
              GuideLink(
                title: l10n.specialDaysTitle,
                onTap: () => _navigateToSubsection(context, 'special_days'),
              ),
              GuideLink(
                title: l10n.dataExportTitle,
                onTap: () => _navigateToSubsection(context, 'data_export'),
              ),
              GuideLink(
                title: l10n.advancedCalculationsTitle,
                onTap: () => _navigateToSubsection(context, 'advanced_calculations'),
              ),
            ],
          ),
          _buildGuideSection(
            context: context,
            title: l10n.customizationTitle,
            content: l10n.customizationOptionsContent,
            subsections: [
              GuideLink(
                title: l10n.languageLocalizationTitle,
                onTap: () => _navigateToSubsection(context, 'language_localization'),
              ),
              GuideLink(
                title: l10n.displaySettingsTitle,
                onTap: () => _navigateToSubsection(context, 'display_settings'),
              ),
              GuideLink(
                title: l10n.currencyFormatsTitle,
                onTap: () => _navigateToSubsection(context, 'currency_formats'),
              ),
              GuideLink(
                title: l10n.reportCustomizationTitle,
                onTap: () => _navigateToSubsection(context, 'report_customization'),
              ),
            ],
          ),
          _buildGuideSection(
            context: context,
            title: l10n.tipsAndTricksTitle,
            content: l10n.tipsAndTricksVideosContent,
            subsections: [
              GuideLink(
                title: l10n.quickActionsTitle,
                onTap: () => _navigateToSubsection(context, 'quick_actions'),
              ),
              GuideLink(
                title: l10n.timeSavingTitle,
                onTap: () => _navigateToSubsection(context, 'time_saving'),
              ),
              GuideLink(
                title: l10n.bestPracticesTitle,
                onTap: () => _navigateToSubsection(context, 'best_practices'),
              ),
            ],
          ),
          _buildGuideSection(
            context: context,
            title: l10n.troubleshootingTitle,
            content: l10n.troubleshootingVideosContent,
            subsections: [
              GuideLink(
                title: l10n.commonIssuesTitle,
                onTap: () => _navigateToSubsection(context, 'common_issues'),
              ),
              GuideLink(
                title: l10n.dataManagementIssuesTitle,
                onTap: () => _navigateToSubsection(context, 'data_management_issues'),
              ),
              GuideLink(
                title: l10n.settingsIssuesTitle,
                onTap: () => _navigateToSubsection(context, 'settings_issues'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGuideSection({
    required BuildContext context,
    required String title,
    required String content,
    required List<GuideLink> subsections,
  }) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ...subsections,
          ],
        ),
      ),
    );
  }

  void _navigateToSubsection(BuildContext context, String sectionId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GuideDetailScreen(
          sectionId: sectionId,
        ),
      ),
    );
  }
}

class GuideDetailScreen extends StatelessWidget {
  final String sectionId;

  const GuideDetailScreen({Key? key, required this.sectionId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(_getSectionTitle(context)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getSectionContent(context),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              _buildVideoContent(context),
              _buildRelatedLinks(context),
            ],
          ),
        ),
      ),
    );
  }

  String _getSectionTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    switch (sectionId) {
      case 'initial_setup':
        return l10n.initialSetupTitle;
      case 'basic_navigation':
        return l10n.basicNavigationTitle;
      case 'first_shift':
        return l10n.firstShiftTitle;
      case 'shift_management':
        return l10n.shiftManagementTitle;
      case 'time_tracking':
        return l10n.timeTrackingTitle;
      case 'financial_management':
        return l10n.financialManagementTitle;
      case 'settings_setup':
        return l10n.settingsSetupTitle;
      case 'overtime_rules':
        return l10n.overtimeRulesTitle;
      case 'special_days':
        return l10n.specialDaysTitle;
      case 'data_export':
        return l10n.dataExportTitle;
      case 'advanced_calculations':
        return l10n.advancedCalculationsTitle;
      case 'language_localization':
        return l10n.languageLocalizationTitle;
      case 'display_settings':
        return l10n.displaySettingsTitle;
      case 'currency_formats':
        return l10n.currencyFormatsTitle;
      case 'report_customization':
        return l10n.reportCustomizationTitle;
      case 'quick_actions':
        return l10n.quickActionsTitle;
      case 'time_saving':
        return l10n.timeSavingTitle;
      case 'best_practices':
        return l10n.bestPracticesTitle;
      case 'common_issues':
        return l10n.commonIssuesTitle;
      case 'data_management_issues':
        return l10n.dataManagementIssuesTitle;
      case 'settings_issues':
        return l10n.settingsIssuesTitle;
      default:
        return l10n.appGuideTitle;
    }
  }

  String _getSectionContent(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    switch (sectionId) {
      case 'initial_setup':
        return '''
${l10n.initialSetupContent}

1. ${l10n.hourlyWageSetup}
   • ${l10n.pleaseEnterYourHourlyWage}
   • ${l10n.pleaseEnterAValidNumber}

2. ${l10n.taxDeductionSetup}
   • ${l10n.pleaseEnterTaxDeductionPercentage}
   • ${l10n.pleaseEnterAValidPercentage}

3. ${l10n.workWeekSetup}
   • ${l10n.startWorkWeekOn}

4. ${l10n.languageSetup}
   • ${l10n.language}
   • ${l10n.country}
''';

      case 'shift_management':
        return '''
${l10n.shiftManagementContent}

1. ${l10n.addingShifts}
   • ${l10n.selectDate}
   • ${l10n.startTime}
   • ${l10n.endTime}
   • ${l10n.addNote}

2. ${l10n.editingShifts}
   • ${l10n.edit}
   • ${l10n.save}
   • ${l10n.markAsSpecialDay}

3. ${l10n.deletingShifts}
   • ${l10n.confirmDelete}
   • ${l10n.deleteShiftConfirmation}

4. ${l10n.specialDaysManagement}
   • ${l10n.specialDayRate}
   • ${l10n.appliesOnWeekends}
   • ${l10n.appliesOnFestiveDays}
''';

      case 'overtime_rules':
        return '''
${l10n.overtimeRulesContent}

1. ${l10n.creatingOvertimeRules}
   • ${l10n.hoursThreshold}
   • ${l10n.rate}
   • ${l10n.isWeekly}
   • ${l10n.appliesOnSpecialDays}

2. ${l10n.editingOvertimeRules}
   • ${l10n.baseHoursWeekday}
   • ${l10n.baseHoursSpecialDay}
   • ${l10n.regularDaysOnly}

3. ${l10n.applyingOvertimeRules}
   • ${l10n.hoursAt100Percent}
   • ${l10n.hoursAt125Percent}
   • ${l10n.hoursAt150Percent}
   • ${l10n.hoursAt175Percent}
   • ${l10n.hoursAt200Percent}
''';

      case 'financial_management':
        return '''
${l10n.financialManagementContent}

1. ${l10n.wageCalculations}
   • ${l10n.grossWage}
   • ${l10n.netWage}
   • ${l10n.wageBreakdown}

2. ${l10n.taxDeductions}
   • ${l10n.taxDeductionFormulas}
   • ${l10n.multiRateCalculations}

3. ${l10n.currencySettings}
   • ${l10n.settingCurrency}
   • ${l10n.numberFormatting}
   • ${l10n.decimalPlaces}

4. ${l10n.reportsAndExports}
   • ${l10n.exportAsCsv}
   • ${l10n.exportAsPdf}
   • ${l10n.exportedReport}
''';

      case 'data_export':
        return '''
${l10n.dataExportContent}

1. ${l10n.exportingReports}
   • CSV ${l10n.exportFormats}
   • PDF ${l10n.exportFormats}
   • ${l10n.dataFormats}

2. ${l10n.creatingBackups}
   • ${l10n.backupData}
   • ${l10n.dataBackupBeforeReset}
   • ${l10n.backupFileCreated}

3. ${l10n.restoringData}
   • ${l10n.restore}
   • ${l10n.restoreSuccessful}
   • ${l10n.restoringBackup}
''';

      case 'best_practices':
        return '''
${l10n.bestPracticesContent}

1. ${l10n.regularBackups}
   • ${l10n.backupAndRestore}
   • ${l10n.dataPrivacy}

2. ${l10n.organizingShifts}
   • ${l10n.currentMonth}
   • ${l10n.allShifts}
   • ${l10n.upcomingShifts}

3. ${l10n.trackingOvertime}
   • ${l10n.overtimeRulesDescription}
   • ${l10n.specialDaysDescription}

4. ${l10n.monitoringEarnings}
   • ${l10n.weeklyReports}
   • ${l10n.monthlyReports}
   • ${l10n.totalEarningsBreakdown}
''';

      case 'common_issues':
        return '''
${l10n.commonIssuesContent}

1. ${l10n.calculationIssues}
   • ${l10n.complexOvertimeCalculations}
     - ${l10n.hoursThreshold}
     - ${l10n.rate}
   • ${l10n.taxDeductionFormulas}
     - ${l10n.taxDeduction}
     - ${l10n.pleaseEnterAValidPercentage}
   • ${l10n.multiRateCalculations}
     - ${l10n.specialDayRate}
     - ${l10n.overtimeRulesDescription}

2. ${l10n.syncProblems}
   • ${l10n.backupRestoreIssues}
     - ${l10n.backupData}
     - ${l10n.restore}
   • ${l10n.dataLossRecovery}
     - ${l10n.backupCreated}
     - ${l10n.restoreSuccessful}
   • ${l10n.corruptedDataFix}
     - ${l10n.dataStorage}
     - ${l10n.dataFormats}

3. ${l10n.displayGlitches}
   • ${l10n.rtlSupport}
     - ${l10n.language}
     - ${l10n.displaySettingsContent}
   • ${l10n.customizingLayout}
     - ${l10n.weeklyView}
     - ${l10n.monthlyView}

4. ${l10n.performanceIssues}
   • ${l10n.dataStorage}
     - ${l10n.backupAndRestore}
     - ${l10n.export}
   • ${l10n.corruptedDataFix}
     - ${l10n.dataLossRecovery}
     - ${l10n.restoreData}
''';

      case 'basic_navigation':
        return '''
${l10n.basicNavigationContent}

1. ${l10n.homeScreenDescription}
   • ${l10n.shiftManagerTitle}: ${l10n.shiftManagerDescription}
   • ${l10n.reportsTitle}: ${l10n.reportsDescription}
   • ${l10n.settingsTitle}: ${l10n.settingsDescription}
   • ${l10n.infoButtonTitle}: ${l10n.appGuideTitle}

2. ${l10n.shiftManagerDescription}
   • ${l10n.addNewShift}: ${l10n.tapAddShift}
   • ${l10n.existingShifts}: ${l10n.showingCurrentMonthShifts}
   • ${l10n.upcomingShiftsTitle}: ${l10n.upcomingShifts}
   • ${l10n.weeklyView} / ${l10n.monthlyView}

3. ${l10n.reportsDescription}
   • ${l10n.weeklyReports}
   • ${l10n.monthlyReports}
   • ${l10n.wageBreakdown}
   • ${l10n.exportReport}

4. ${l10n.settingsDescription}
   • ${l10n.hourlyWage}
   • ${l10n.taxDeduction}
   • ${l10n.language}
   • ${l10n.country}
   • ${l10n.startWorkWeekOn}

5. ${l10n.utilities}
   • ${l10n.backupAndRestore}
   • ${l10n.export}
   • ${l10n.addToHomeScreen}
''';

      case 'first_shift':
        return '''
${l10n.firstShiftContent}

1. ${l10n.openShiftManager}
   • ${l10n.tapAddShift}
   • ${l10n.addNewShift}

2. ${l10n.selectDateTime}
   • ${l10n.selectDate}
   • ${l10n.startTime}
   • ${l10n.endTime}
   • ${l10n.totalHours}

3. ${l10n.addNote}
   • ${l10n.addNoteHint}
   • ${l10n.shiftNotes}

4. ${l10n.specialDays}
   • ${l10n.toggleSpecialDay}
   • ${l10n.specialDayEnabled}
   • ${l10n.specialDayRate}

5. ${l10n.saveShift}
   • ${l10n.shiftAddedSuccessfully}
   • ${l10n.wageBreakdown}:
     - ${l10n.grossWage}
     - ${l10n.netWage}
     - ${l10n.totalHours}

6. ${l10n.viewShifts}
   • ${l10n.existingShifts}
   • ${l10n.editShift}
   • ${l10n.deleteShift}
   • ${l10n.weeklyView} / ${l10n.monthlyView}

${l10n.nextStepsContent}
• ${l10n.exploreOvertimeRules}
• ${l10n.learnAboutReports}
• ${l10n.discoverAdvancedFeatures}
''';

      case 'time_tracking':
        return '''
${l10n.timeTrackingContent}

1. ${l10n.regularHoursTracking}
   • ${l10n.totalHours}
   • ${l10n.weeklyView}
     - ${l10n.totalWorkingDays}
     - ${l10n.weekdays}
     - ${l10n.specialDays}
   • ${l10n.monthlyView}
     - ${l10n.currentMonth}
     - ${l10n.allShifts}
     - ${l10n.upcomingShifts}

2. ${l10n.overtimeCalculation}
   • ${l10n.baseHoursWeekday}
     - ${l10n.hoursAt100Percent}
     - ${l10n.hoursAt125Percent}
     - ${l10n.hoursAt150Percent}
   • ${l10n.baseHoursSpecialDay}
     - ${l10n.hoursAt175Percent}
     - ${l10n.hoursAt200Percent}
   • ${l10n.weekly} vs ${l10n.daily}

3. ${l10n.specialRatesHandling}
   • ${l10n.specialDayRate}
     - ${l10n.appliesOnWeekends}
     - ${l10n.appliesOnFestiveDays}
   • ${l10n.festiveDays}
     - ${l10n.addFestiveDay}
     - ${l10n.specialDayEnabled}
   • ${l10n.specialDayRules}
     - ${l10n.isForSpecialDays}
     - ${l10n.appliesOnSpecialDays}

4. ${l10n.wageBreakdown}
   • ${l10n.grossWage}
     - ${l10n.regularHoursTracking}
     - ${l10n.overtimeCalculation}
   • ${l10n.netWage}
     - ${l10n.taxDeduction}
     - ${l10n.totalEarningsBreakdown}

5. ${l10n.shiftNotes}
   • ${l10n.addNote}
   • ${l10n.editNote}
   • ${l10n.noNotes}
''';

      case 'special_days':
        return '''
${l10n.specialDaysContent}

1. ${l10n.weekendSettings}
   • ${l10n.appliesOnWeekends}
     - ${l10n.saturday}
     - ${l10n.sunday}
   • ${l10n.specialDayRate}
     - ${l10n.hoursAt150Percent}
     - ${l10n.hoursAt175Percent}
   • ${l10n.baseHoursSpecialDay}

2. ${l10n.holidaySettings}
   • ${l10n.festiveDays}
     - ${l10n.addFestiveDay}
     - ${l10n.specialDayEnabled}
   • ${l10n.appliesOnFestiveDays}
     - ${l10n.hoursAt200Percent}
     - ${l10n.specialDayRate}

3. ${l10n.markingSpecialDays}
   • ${l10n.toggleSpecialDay}
   • ${l10n.specialDayEnabled}
   • ${l10n.specialDayDisabled}
   • ${l10n.markAsSpecialDay}

4. ${l10n.configuringSpecialRates}
   • ${l10n.specialDayRate}
   • ${l10n.overtimeRulesDescription}
   • ${l10n.appliesOnSpecialDays}
   • ${l10n.regularDaysOnly}

5. ${l10n.specialDayRules}
   • ${l10n.isForSpecialDays}
   • ${l10n.appliesOnSpecialDays}
   • ${l10n.baseHoursSpecialDay}
   • ${l10n.wageBreakdown}
''';

      case 'advanced_calculations':
        return '''
${l10n.advancedCalculationsContent}

1. ${l10n.complexOvertimeCalculations}
   • ${l10n.weekly}
     - ${l10n.baseHoursWeekday}
     - ${l10n.hoursThreshold}
     - ${l10n.rate}
   • ${l10n.daily}
     - ${l10n.baseHoursWeekday}
     - ${l10n.baseHoursSpecialDay}
     - ${l10n.specialDayRate}

2. ${l10n.multiRateCalculations}
   • ${l10n.hoursAt100Percent}
   • ${l10n.hoursAt125Percent}
   • ${l10n.hoursAt150Percent}
   • ${l10n.hoursAt175Percent}
   • ${l10n.hoursAt200Percent}

3. ${l10n.taxDeductionFormulas}
   • ${l10n.grossWage}
     - ${l10n.regularHoursTracking}
     - ${l10n.overtimeCalculation}
   • ${l10n.taxDeduction}
     - ${l10n.pleaseEnterTaxDeductionPercentage}
     - ${l10n.pleaseEnterAValidPercentage}
   • ${l10n.netWage}

4. ${l10n.totalEarningsBreakdown}
   • ${l10n.wageBreakdown}
     - ${l10n.regularHoursTracking}
     - ${l10n.overtimeCalculation}
     - ${l10n.specialRatesHandling}
   • ${l10n.weeklyReports}
   • ${l10n.monthlyReports}

5. ${l10n.calculationsDescription}
   • ${l10n.weeklyView}
     - ${l10n.totalWorkingDays}
     - ${l10n.weekdays}
     - ${l10n.specialDays}
   • ${l10n.monthlyView}
     - ${l10n.currentMonth}
     - ${l10n.allShifts}
     - ${l10n.totalEarningsBreakdown}
''';

      case 'language_localization':
        return '''
${l10n.languageLocalizationContent}

1. ${l10n.changingLanguage}
   • ${l10n.language}
     - English
     - עברית
     - Русский
     - Français
     - Deutsch
     - Español
   • ${l10n.country}
     - ${l10n.countryUS}
     - ${l10n.countryGB}
     - ${l10n.countryEU}
     - ${l10n.countryIL}
     - ${l10n.countryJP}
     - ${l10n.countryRU}

2. ${l10n.dateTimeFormats}
   • ${l10n.dateLabel}
   • ${l10n.startTime}
   • ${l10n.endTime}
   • ${l10n.weekStartDay}
   • ${l10n.startWorkWeekOn}

3. ${l10n.numberFormats}
   • ${l10n.decimalPlaces}
   • ${l10n.currencySymbols}
   • ${l10n.numberFormatting}

4. ${l10n.rtlSupport}
   • עברית (Hebrew)
   • ${l10n.displaySettingsContent}
   • ${l10n.customizingLayout}
''';

      case 'display_settings':
        return '''
${l10n.displaySettingsContent}

1. ${l10n.customizingLayout}
   • ${l10n.weeklyView}
   • ${l10n.monthlyView}
   • ${l10n.showingAllShifts}
   • ${l10n.showingCurrentMonthShifts}

2. ${l10n.colorSchemes}
   • Light Theme
   • Dark Theme
   • System Default
   • ${l10n.themeSettings}

3. ${l10n.fontSizes}
   • Small
   • Medium
   • Large
   • System Default

4. ${l10n.themeSettings}
   • ${l10n.customizingLayout}
   • ${l10n.personalizingReports}
   • ${l10n.configuringDisplayOptions}

5. ${l10n.addToHomeScreen}
   • ${l10n.addToHomeScreeniOS}
   • ${l10n.addToHomeScreenAndroid}
''';

      case 'currency_formats':
        return '''
${l10n.currencyFormatsContent}

1. ${l10n.settingCurrency}
   • ${l10n.countryUS}: USD (\$)
   • ${l10n.countryGB}: GBP (£)
   • ${l10n.countryEU}: EUR (€)
   • ${l10n.countryIL}: ILS (₪)
   • ${l10n.countryJP}: JPY (¥)
   • ${l10n.countryRU}: RUB (₽)

2. ${l10n.numberFormatting}
   • ${l10n.decimalPlaces}
     - 0.00
     - 0.000
     - 0
   • ${l10n.pleaseEnterAValidNumber}
   • ${l10n.pleaseEnterAValidPercentage}

3. ${l10n.currencySymbols}
   • ${l10n.grossWage}
   • ${l10n.netWage}
   • ${l10n.hourlyWage}
   • ${l10n.wageBreakdown}

4. ${l10n.taxDeductionFormulas}
   • ${l10n.taxDeduction}
   • ${l10n.pleaseEnterTaxDeductionPercentage}
   • ${l10n.multiRateCalculations}
''';

      case 'report_customization':
        return '''
${l10n.reportCustomizationContent}

1. ${l10n.customizingReportLayout}
   • ${l10n.weeklyView}
     - ${l10n.totalWorkingDays}
     - ${l10n.weekdays}
     - ${l10n.specialDays}
   • ${l10n.monthlyView}
     - ${l10n.currentMonth}
     - ${l10n.allShifts}
     - ${l10n.totalEarningsBreakdown}

2. ${l10n.choosingColumns}
   • ${l10n.dateLabel}
   • ${l10n.startTime}
   • ${l10n.endTime}
   • ${l10n.totalHours}
   • ${l10n.grossWage}
   • ${l10n.netWage}
   • ${l10n.shiftNotes}

3. ${l10n.sortingOptions}
   • ${l10n.dateLabel}
   • ${l10n.totalHours}
   • ${l10n.grossWage}
   • ${l10n.netWage}

4. ${l10n.exportFormats}
   • ${l10n.exportAsCsv}
     - ${l10n.dataFormats}
     - ${l10n.exportedReport}
   • ${l10n.exportAsPdf}
     - ${l10n.personalizingReports}
     - ${l10n.exportReport}

5. ${l10n.dataVisualization}
   • ${l10n.wageBreakdown}
   • ${l10n.totalEarningsBreakdown}
   • ${l10n.weeklyReports}
   • ${l10n.monthlyReports}
''';

      case 'quick_actions':
        return '''
${l10n.quickActionsContent}

1. ${l10n.editShift}
   • ${l10n.edit}
     - ${l10n.editShift}
     - ${l10n.deleteShift}
   • ${l10n.shiftNotes}
     - ${l10n.addNote}
     - ${l10n.editNote}
   • ${l10n.toggleSpecialDay}
     - ${l10n.specialDayEnabled}
     - ${l10n.specialDayDisabled}

2. ${l10n.longPressFeatures}
   • ${l10n.existingShifts}
     - ${l10n.copyPreviousShift}
     - ${l10n.deleteShift}
   • ${l10n.weeklyView}
     - ${l10n.showingAllShifts}
     - ${l10n.showingCurrentMonthShifts}

3. ${l10n.quickAdd}
   • ${l10n.addNewShift}
     - ${l10n.selectDateTime}
     - ${l10n.startTime}
     - ${l10n.endTime}
   • ${l10n.addNote}
   • ${l10n.markAsSpecialDay}

4. ${l10n.gestureShortcuts}
   • ${l10n.weeklyView} ↔ ${l10n.monthlyView}
   • ${l10n.currentMonth} ↔ ${l10n.allShifts}
   • ${l10n.upcomingShifts}
''';

      case 'time_saving':
        return '''
${l10n.timeSavingContent}

1. ${l10n.shiftTemplates}
   • ${l10n.regularHoursTracking}
     - ${l10n.startTime}
     - ${l10n.endTime}
     - ${l10n.totalHours}
   • ${l10n.specialDays}
     - ${l10n.specialDayRate}
     - ${l10n.appliesOnWeekends}
   • ${l10n.shiftNotes}

2. ${l10n.copyPreviousShift}
   • ${l10n.selectDate}
   • ${l10n.startTime}
   • ${l10n.endTime}
   • ${l10n.shiftNotes}
   • ${l10n.specialDayRate}

3. ${l10n.bulkActions}
   • ${l10n.weeklyView}
     - ${l10n.editShift}
     - ${l10n.deleteShift}
   • ${l10n.monthlyView}
     - ${l10n.exportReport}
     - ${l10n.wageBreakdown}

4. ${l10n.favoriteSettings}
   • ${l10n.hourlyWage}
   • ${l10n.taxDeduction}
   • ${l10n.specialDayRate}
   • ${l10n.overtimeRulesTitle}
''';


      case 'data_management_issues':
        return '''
${l10n.dataManagementIssuesContent}

1. ${l10n.backupRestoreIssues}
   • ${l10n.backupData}
     - ${l10n.creatingBackup}
     - ${l10n.backupCreated}
   • ${l10n.restore}
     - ${l10n.restoringBackup}
     - ${l10n.restoreSuccessful}
   • ${l10n.backupError}
     - ${l10n.restoreError}
     - ${l10n.dataLossRecovery}

2. ${l10n.dataLossRecovery}
   • ${l10n.backupFileCreated}
     - ${l10n.dataStorage}
     - ${l10n.dataFormats}
   • ${l10n.restoreSuccessful}
     - ${l10n.dataPrivacy}
     - ${l10n.dataManagementGuide}

3. ${l10n.corruptedDataFix}
   • ${l10n.dataStorage}
     - ${l10n.backupAndRestore}
     - ${l10n.export}
   • ${l10n.dataFormats}
     - ${l10n.exportAsCsv}
     - ${l10n.exportAsPdf}

4. ${l10n.importExportProblems}
   • ${l10n.exportReport}
     - ${l10n.exportAsCsv}
     - ${l10n.exportAsPdf}
   • ${l10n.dataExportDescription}
     - ${l10n.exportingReports}
     - ${l10n.exportedReport}
''';

      case 'settings_issues':
        return '''
${l10n.settingsIssuesContent}

1. ${l10n.preferencesReset}
   • ${l10n.settingsSetupTitle}
     - ${l10n.hourlyWageSetup}
     - ${l10n.taxDeductionSetup}
   • ${l10n.workWeekSetup}
     - ${l10n.startWorkWeekOn}
     - ${l10n.weekStartDay}

2. ${l10n.languageIssues}
   • ${l10n.language}
     - ${l10n.rtlSupport}
     - ${l10n.displaySettingsContent}
   • ${l10n.dateTimeFormats}
     - ${l10n.numberFormats}
     - ${l10n.currencySymbols}

3. ${l10n.currencyProblems}
   • ${l10n.settingCurrency}
     - ${l10n.country}
     - ${l10n.currencySymbols}
   • ${l10n.numberFormatting}
     - ${l10n.decimalPlaces}
     - ${l10n.pleaseEnterAValidNumber}

4. ${l10n.timeZoneIssues}
   • ${l10n.dateTimeFormats}
     - ${l10n.selectDateTime}
     - ${l10n.startTime}
   • ${l10n.weekStartDay}
     - ${l10n.startWorkWeekOn}
     - ${l10n.weeklyView}

5. ${l10n.errorMessagesTitle}
   • ${l10n.commonErrors}
     - ${l10n.errorSolutions}
     - ${l10n.errorPrevention}
   • ${l10n.errorReporting}
     - ${l10n.reportBug}
     - ${l10n.emailSupport}
''';

      // Add more detailed content for other sections...
      default:
        return l10n.guideIntroduction;
    }
  }

  Widget _buildRelatedLinks(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final List<GuideLink> relatedLinks = _getRelatedLinks(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          l10n.learnMoreTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        ...relatedLinks,
      ],
    );
  }

  List<GuideLink> _getRelatedLinks(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    switch (sectionId) {
      case 'initial_setup':
        return [
          GuideLink(
            title: l10n.basicNavigationTitle,
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const GuideDetailScreen(sectionId: 'basic_navigation'),
              ),
            ),
          ),
          GuideLink(
            title: l10n.settingsSetupTitle,
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const GuideDetailScreen(sectionId: 'settings_setup'),
              ),
            ),
          ),
        ];
      case 'overtime_rules':
        return [
          GuideLink(
            title: l10n.specialDaysTitle,
            onTap: () => _navigateToRelated(context, 'special_days'),
          ),
          GuideLink(
            title: l10n.advancedCalculationsTitle,
            onTap: () => _navigateToRelated(context, 'advanced_calculations'),
          ),
        ];
      case 'special_days':
        return [
          GuideLink(
            title: l10n.overtimeRulesTitle,
            onTap: () => _navigateToRelated(context, 'overtime_rules'),
          ),
          GuideLink(
            title: l10n.advancedCalculationsTitle,
            onTap: () => _navigateToRelated(context, 'advanced_calculations'),
          ),
          GuideLink(
            title: l10n.shiftManagementTitle,
            onTap: () => _navigateToRelated(context, 'shift_management'),
          ),
        ];
      case 'time_tracking':
        return [
          GuideLink(
            title: l10n.overtimeRulesTitle,
            onTap: () => _navigateToRelated(context, 'overtime_rules'),
          ),
          GuideLink(
            title: l10n.specialDaysTitle,
            onTap: () => _navigateToRelated(context, 'special_days'),
          ),
          GuideLink(
            title: l10n.financialManagementTitle,
            onTap: () => _navigateToRelated(context, 'financial_management'),
          ),
          GuideLink(
            title: l10n.shiftManagementTitle,
            onTap: () => _navigateToRelated(context, 'shift_management'),
          ),
        ];
      case 'language_localization':
        return [
          GuideLink(
            title: l10n.displaySettingsTitle,
            onTap: () => _navigateToRelated(context, 'display_settings'),
          ),
          GuideLink(
            title: l10n.currencyFormatsTitle,
            onTap: () => _navigateToRelated(context, 'currency_formats'),
          ),
          GuideLink(
            title: l10n.settingsSetupTitle,
            onTap: () => _navigateToRelated(context, 'settings_setup'),
          ),
        ];
      case 'display_settings':
        return [
          GuideLink(
            title: l10n.languageLocalizationTitle,
            onTap: () => _navigateToRelated(context, 'language_localization'),
          ),
          GuideLink(
            title: l10n.reportCustomizationTitle,
            onTap: () => _navigateToRelated(context, 'report_customization'),
          ),
          GuideLink(
            title: l10n.customizationTitle,
            onTap: () => _navigateToRelated(context, 'customization'),
          ),
        ];
      case 'currency_formats':
        return [
          GuideLink(
            title: l10n.languageLocalizationTitle,
            onTap: () => _navigateToRelated(context, 'language_localization'),
          ),
          GuideLink(
            title: l10n.financialManagementTitle,
            onTap: () => _navigateToRelated(context, 'financial_management'),
          ),
          GuideLink(
            title: l10n.reportCustomizationTitle,
            onTap: () => _navigateToRelated(context, 'report_customization'),
          ),
        ];
      case 'report_customization':
        return [
          GuideLink(
            title: l10n.displaySettingsTitle,
            onTap: () => _navigateToRelated(context, 'display_settings'),
          ),
          GuideLink(
            title: l10n.currencyFormatsTitle,
            onTap: () => _navigateToRelated(context, 'currency_formats'),
          ),
          GuideLink(
            title: l10n.dataExportTitle,
            onTap: () => _navigateToRelated(context, 'data_export'),
          ),
        ];
      case 'quick_actions':
        return [
          GuideLink(
            title: l10n.timeSavingTitle,
            onTap: () => _navigateToRelated(context, 'time_saving'),
          ),
          GuideLink(
            title: l10n.bestPracticesTitle,
            onTap: () => _navigateToRelated(context, 'best_practices'),
          ),
          GuideLink(
            title: l10n.shiftManagementTitle,
            onTap: () => _navigateToRelated(context, 'shift_management'),
          ),
        ];
      case 'time_saving':
        return [
          GuideLink(
            title: l10n.quickActionsTitle,
            onTap: () => _navigateToRelated(context, 'quick_actions'),
          ),
          GuideLink(
            title: l10n.bestPracticesTitle,
            onTap: () => _navigateToRelated(context, 'best_practices'),
          ),
          GuideLink(
            title: l10n.shiftManagementTitle,
            onTap: () => _navigateToRelated(context, 'shift_management'),
          ),
        ];
      case 'best_practices':
        return [
          GuideLink(
            title: l10n.quickActionsTitle,
            onTap: () => _navigateToRelated(context, 'quick_actions'),
          ),
          GuideLink(
            title: l10n.timeSavingTitle,
            onTap: () => _navigateToRelated(context, 'time_saving'),
          ),
          GuideLink(
            title: l10n.dataManagementTitle,
            onTap: () => _navigateToRelated(context, 'data_management'),
          ),
        ];
      case 'common_issues':
        return [
          GuideLink(
            title: l10n.dataManagementIssuesTitle,
            onTap: () => _navigateToRelated(context, 'data_management_issues'),
          ),
          GuideLink(
            title: l10n.settingsIssuesTitle,
            onTap: () => _navigateToRelated(context, 'settings_issues'),
          ),
          GuideLink(
            title: l10n.bestPracticesTitle,
            onTap: () => _navigateToRelated(context, 'best_practices'),
          ),
        ];
      case 'data_management_issues':
        return [
          GuideLink(
            title: l10n.commonIssuesTitle,
            onTap: () => _navigateToRelated(context, 'common_issues'),
          ),
          GuideLink(
            title: l10n.dataExportTitle,
            onTap: () => _navigateToRelated(context, 'data_export'),
          ),
          GuideLink(
            title: l10n.dataManagementGuide,
            onTap: () => _navigateToRelated(context, 'data_management'),
          ),
        ];
      case 'settings_issues':
        return [
          GuideLink(
            title: l10n.commonIssuesTitle,
            onTap: () => _navigateToRelated(context, 'common_issues'),
          ),
          GuideLink(
            title: l10n.settingsSetupTitle,
            onTap: () => _navigateToRelated(context, 'settings_setup'),
          ),
          GuideLink(
            title: l10n.customizationTitle,
            onTap: () => _navigateToRelated(context, 'customization'),
          ),
        ];
      // Add more cases for other sections...
      default:
        return [];
    }
  }

  void _navigateToRelated(BuildContext context, String sectionId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GuideDetailScreen(
          sectionId: sectionId,
        ),
      ),
    );
  }

  Widget _buildVideoContent(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    switch (sectionId) {
      case 'first_shift':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GuideVideo(
              title: l10n.firstShiftGuide,
              videoUrl: 'https://your-video-url/first-shift-guide.mp4',
            ),
          ],
        );
      case 'overtime_rules':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GuideVideo(
              title: l10n.overtimeRulesGuide,
              videoUrl: 'https://your-video-url/overtime-rules-guide.mp4',
            ),
          ],
        );
      // Add more video sections as needed
      default:
        return const SizedBox.shrink();
    }
  }
}

class GuideLink extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const GuideLink({
    Key? key,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }
}

class GuideVideo extends StatefulWidget {
  final String videoUrl;
  final String title;

  const GuideVideo({
    Key? key,
    required this.videoUrl,
    required this.title,
  }) : super(key: key);

  @override
  State<GuideVideo> createState() => _GuideVideoState();
}

class _GuideVideoState extends State<GuideVideo> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  Future<void> initializePlayer() async {
    _videoPlayerController = VideoPlayerController.network(widget.videoUrl);
    await _videoPlayerController.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: false,
      looping: false,
      aspectRatio: 16 / 9,
      placeholder: const Center(child: CircularProgressIndicator()),
      autoInitialize: true,
    );
    setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        AspectRatio(
          aspectRatio: 16 / 9,
          child: _chewieController != null
              ? Chewie(controller: _chewieController!)
              : const Center(child: CircularProgressIndicator()),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

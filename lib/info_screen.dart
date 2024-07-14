import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.infoTitle),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          _buildSection(
            localizations.aboutThisApp,
            localizations.aboutThisAppContent,
          ),
          _buildSection(
            localizations.keyFeatures,
            localizations.keyFeaturesContent,
          ),
          _buildSection(
            localizations.howToUse,
            localizations.howToUseContent,
          ),
          _buildSection(
            localizations.shiftInformation,
            localizations.shiftInformationContent,
          ),
          _buildSection(
            localizations.privacy,
            localizations.privacyContent,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

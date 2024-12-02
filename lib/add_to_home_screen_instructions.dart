import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AddToHomeScreenInstructions extends StatelessWidget {
  const AddToHomeScreenInstructions({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return const SizedBox.shrink(); // Only show on web

    final localizations = AppLocalizations.of(context)!;
    return ElevatedButton(
      child: Text(localizations.addToHomeScreen),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(localizations.addToHomeScreenTitle),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(localizations.iPhoneInstructions),
                    Text('1. ${localizations.openInSafari}'),
                    Text('2. ${localizations.tapShareButton}'),
                    Text('3. ${localizations.scrollAndTapAddToHomeScreen}'),
                    Text('4. ${localizations.tapAddInTopRight}'),
                    const SizedBox(height: 16),
                    Text(localizations.androidInstructions),
                    Text('1. ${localizations.openInChrome}'),
                    Text('2. ${localizations.tapMenuIcon}'),
                    Text('3. ${localizations.tapAddToHomeScreen}'),
                    Text('4. ${localizations.tapAddOnPopup}'),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(localizations.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}

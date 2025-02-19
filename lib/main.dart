import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'app_state.dart';
import 'main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/firebase_service.dart';
import 'screens/access_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await FirebaseService.initialize();
    print('Firebase initialized successfully');
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return MaterialApp(
          title: 'Shift View',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            brightness: Brightness.light,
            iconTheme: const IconThemeData(
              color: Colors.blue,
              size: 24.0,
            ),
            // Ensure proper font loading
            textTheme: Typography.material2021().black,
            primaryTextTheme: Typography.material2021().black,
          ),
          darkTheme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            brightness: Brightness.dark,
            iconTheme: const IconThemeData(
              color: Colors.blue,
              size: 24.0,
            ),
            // Ensure proper font loading
            textTheme: Typography.material2021().white,
            primaryTextTheme: Typography.material2021().white,
          ),
          themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          locale: appState.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('he', ''),
            Locale('es', ''),
            Locale('de', ''),
            Locale('ru', ''),
            Locale('fr', ''),
          ],
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Scaffold(
                  body: Center(
                    child: Text('Error: ${snapshot.error}'),
                  ),
                );
              }

              if (snapshot.data == null) {
                return const AccessScreen();
              }

              return const MainScreen();
            },
          ),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

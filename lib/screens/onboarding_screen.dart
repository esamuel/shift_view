import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'main_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final FlutterTts _flutterTts = FlutterTts();
  int _currentPage = 0;
  bool _isVoiceEnabled = true;
  double _fontSize = 16.0;
  bool _isHighContrast = false;
  
  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to ShiftView',
      description: 'Track your work hours and calculate your wages easily',
      icon: Icons.access_time,
      color: Colors.blue,
      voicePrompt: 'Welcome to ShiftView, your work shift manager. Tap anywhere to continue.',
    ),
    OnboardingPage(
      title: 'Track Your Shifts',
      description: 'Record your work hours and manage your schedule efficiently',
      icon: Icons.calendar_today,
      color: Colors.green,
      voicePrompt: 'Record and manage your work shifts easily.',
    ),
    OnboardingPage(
      title: 'Calculate Earnings',
      description: 'Automatically calculate your wages including overtime',
      icon: Icons.attach_money,
      color: Colors.orange,
      voicePrompt: 'Calculate your earnings automatically, including overtime.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _loadAccessibilitySettings();
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    
    if (_isVoiceEnabled) {
      _speakCurrentPage();
    }
  }

  Future<void> _loadAccessibilitySettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fontSize = prefs.getDouble('fontSize') ?? 16.0;
      _isHighContrast = prefs.getBool('highContrast') ?? false;
      _isVoiceEnabled = prefs.getBool('voiceEnabled') ?? true;
    });
  }

  Future<void> _saveAccessibilitySettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', _fontSize);
    await prefs.setBool('highContrast', _isHighContrast);
    await prefs.setBool('voiceEnabled', _isVoiceEnabled);
  }

  Future<void> _speakCurrentPage() async {
    if (_isVoiceEnabled) {
      await _flutterTts.speak(_pages[_currentPage].voicePrompt);
    }
  }

  Future<void> _completeOnboarding() async {
    await _flutterTts.stop();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstLaunch', false);
    await _saveAccessibilitySettings();
    
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const MainScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isHighContrast ? Colors.black : Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Main Content
            PageView.builder(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
                _speakCurrentPage();
              },
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                return OnboardingPageWidget(
                  page: _pages[index],
                  fontSize: _fontSize,
                  isHighContrast: _isHighContrast,
                );
              },
            ),

            // Navigation Controls
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // Page Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: CircleAvatar(
                          radius: 6,
                          backgroundColor: _currentPage == index
                              ? (_isHighContrast ? Colors.white : Theme.of(context).primaryColor)
                              : (_isHighContrast ? Colors.grey : Colors.grey[300]),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Navigation Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_currentPage > 0)
                          ElevatedButton(
                            onPressed: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: _isHighContrast ? Colors.black : Colors.white,
                              backgroundColor: _isHighContrast ? Colors.white : Theme.of(context).primaryColor,
                              minimumSize: const Size(120, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: const Text('Previous'),
                          ),
                        Expanded(child: Container()),
                        ElevatedButton(
                          onPressed: _currentPage == _pages.length - 1
                              ? _completeOnboarding
                              : () {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: _isHighContrast ? Colors.black : Colors.white,
                            backgroundColor: _isHighContrast ? Colors.white : Theme.of(context).primaryColor,
                            minimumSize: const Size(120, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _flutterTts.stop();
    super.dispose();
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String voicePrompt;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.voicePrompt,
  });
}

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingPage page;
  final double fontSize;
  final bool isHighContrast;

  const OnboardingPageWidget({
    super.key,
    required this.page,
    required this.fontSize,
    required this.isHighContrast,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            page.icon,
            size: 120,
            color: isHighContrast ? Colors.white : page.color,
          ),
          const SizedBox(height: 60),
          Text(
            page.title,
            style: TextStyle(
              fontSize: fontSize * 1.5,
              fontWeight: FontWeight.bold,
              color: isHighContrast ? Colors.white : Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            page.description,
            style: TextStyle(
              fontSize: fontSize,
              color: isHighContrast ? Colors.white70 : Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
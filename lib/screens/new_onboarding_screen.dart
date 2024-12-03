import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/onboarding_content.dart';
import '../main_screen.dart';

class NewOnboardingScreen extends StatefulWidget {
  const NewOnboardingScreen({super.key});

  @override
  State<NewOnboardingScreen> createState() => _NewOnboardingScreenState();
}

class _NewOnboardingScreenState extends State<NewOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late List<OnboardingContent> _pages;
  ChewieController? _chewieController;
  VideoPlayerController? _videoController;
  bool _isVideoInitializing = false;

  @override
  void initState() {
    super.initState();
    _pages = OnboardingData.getContent();
    _initializeVideo(_pages[0].videoAsset);
  }

  Future<void> _initializeVideo(String videoAsset) async {
    if (_isVideoInitializing) return;
    
    try {
      _isVideoInitializing = true;
      print('Starting video initialization for: $videoAsset');
      
      // Dispose of previous controllers
      if (_videoController != null) {
        print('Disposing previous video controller');
        await _videoController!.dispose();
        _videoController = null;
      }
      if (_chewieController != null) {
        print('Disposing previous chewie controller');
        _chewieController!.dispose();
        _chewieController = null;
      }

      // Create new video controller
      print('Creating new video controller');
      _videoController = VideoPlayerController.asset(videoAsset);

      // Initialize video
      print('Initializing video controller');
      await _videoController!.initialize().then((_) {
        print('Video initialized successfully');
        print('Video size: ${_videoController!.value.size}');
        print('Video duration: ${_videoController!.value.duration}');
        print('Video aspect ratio: ${_videoController!.value.aspectRatio}');
        
        if (!mounted) return;

        // Create chewie controller
        _chewieController = ChewieController(
          videoPlayerController: _videoController!,
          autoPlay: false,
          looping: true,
          showControls: true,
          allowMuting: true,
          allowPlaybackSpeedChanging: false,
          aspectRatio: _videoController!.value.aspectRatio,
          errorBuilder: (context, errorMessage) {
            print('Chewie error: $errorMessage');
            return _buildErrorWidget(context, errorMessage);
          },
          placeholder: _buildPlaceholderWidget(context),
        );
        
        if (mounted) setState(() {});
      }).catchError((error) {
        print('Error initializing video: $error');
        throw error;
      });
    } catch (e) {
      print('Error in _initializeVideo: $e');
      // Clean up on error
      if (_videoController != null) {
        await _videoController!.dispose();
        _videoController = null;
      }
      if (_chewieController != null) {
        _chewieController!.dispose();
        _chewieController = null;
      }
    } finally {
      _isVideoInitializing = false;
      if (mounted) setState(() {});
    }
  }

  Widget _buildErrorWidget(BuildContext context, String errorMessage) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _pages[_currentPage].icon,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Unable to load video: $errorMessage',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderWidget(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _pages[_currentPage].icon,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Loading video...',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    if (_currentPage == page) return;
    
    setState(() {
      _currentPage = page;
    });
    
    // Initialize the video for the new page
    _initializeVideo(_pages[page].videoAsset);
  }

  Future<void> _completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasCompletedOnboarding', true);
      
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error completing onboarding: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            _buildNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoWidget(OnboardingContent content) {
    if (_chewieController != null && _videoController?.value.isInitialized == true) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Chewie(
          controller: _chewieController!,
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                content.icon,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                _isVideoInitializing ? 'Loading video...' : 'Tap to play video',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildPage(OnboardingContent content) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final containerWidth = screenWidth * 0.95;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              content.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              content.description,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: screenHeight * 0.75,
                maxWidth: containerWidth,
                minWidth: containerWidth,
              ),
              child: AspectRatio(
                aspectRatio: _videoController?.value.aspectRatio ?? 16/9,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _buildVideoWidget(content),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: content.bulletPoints.map((point) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(point,
                          style: Theme.of(context).textTheme.bodyMedium),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigation() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            TextButton(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: const Text('Previous'),
            )
          else
            const SizedBox(width: 80),
          Row(
            children: List.generate(
              _pages.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade300,
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: _currentPage == _pages.length - 1
                ? _completeOnboarding
                : () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
            child: Text(
              _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
            ),
          ),
        ],
      ),
    );
  }
} 
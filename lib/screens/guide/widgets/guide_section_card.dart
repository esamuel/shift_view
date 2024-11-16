import 'package:flutter/material.dart';
import 'guide_video_player.dart';

class GuideSectionCard extends StatelessWidget {
  final String title;
  final String content;
  final String? videoUrl;
  final String? thumbnailUrl;
  final List<String>? steps;
  final List<GuideSectionLink>? links;

  const GuideSectionCard({
    Key? key,
    required this.title,
    required this.content,
    this.videoUrl,
    this.thumbnailUrl,
    this.steps,
    this.links,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
            if (videoUrl != null && thumbnailUrl != null) ...[
              const SizedBox(height: 16),
              GuideVideoPlayer(
                videoUrl: videoUrl!,
                thumbnailUrl: thumbnailUrl!,
              ),
            ],
            if (steps != null) ...[
              const SizedBox(height: 16),
              ...steps!.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${entry.key + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(entry.value),
                      ),
                    ],
                  ),
                );
              }),
            ],
            if (links != null) ...[
              const SizedBox(height: 16),
              ...links!.map((link) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TextButton(
                      onPressed: () => link.onTap(),
                      child: Row(
                        children: [
                          Text(link.title),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward),
                        ],
                      ),
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}

class GuideSectionLink {
  final String title;
  final VoidCallback onTap;

  const GuideSectionLink({
    required this.title,
    required this.onTap,
  });
} 
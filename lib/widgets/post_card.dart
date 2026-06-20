import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/post.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;
  final VoidCallback onLike;

  const PostCard({
    super.key,
    required this.post,
    required this.onTap,
    required this.onLike,
  });

  String _getCaption(String id) {
    final captions = [
      'Exploring the unknown 🌍',
      'Nature at its finest 🍃',
      'City lights and late nights 🌃',
      'A moment to remember ✨',
      'Chasing horizons 🌅',
      'Wanderlust vibes ✈️',
      'Finding beauty in the details 🔍',
      'Good times and crazy friends 🎉',
    ];
    final index = id.hashCode.abs() % captions.length;
    return captions[index];
  }

  @override
  Widget build(BuildContext context) {
    // Convert logical pixels to physical pixels for optimal memory usage
    final cacheWidth = (MediaQuery.of(context).devicePixelRatio * 400).round();

    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              // Heavy BoxShadow
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 30,
                spreadRadius: 8,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (post.mediaThumbUrl.isNotEmpty)
                  Hero(
                    tag: 'hero_image_${post.id}',
                    child: CachedNetworkImage(
                      imageUrl: post.mediaThumbUrl,
                      memCacheWidth: cacheWidth,
                      imageBuilder: (context, imageProvider) => AspectRatio(
                        aspectRatio: 4 / 5,
                        child: Image(image: imageProvider, fit: BoxFit.cover),
                      ),
                      placeholder: (context, url) => AspectRatio(
                        aspectRatio: 4 / 5,
                        child: Container(
                          color: Colors.black12,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => const SizedBox.shrink(),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getCaption(post.id),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).textTheme.titleLarge?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            '${post.likeCount}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            customBorder: const CircleBorder(),
                            onTap: onLike,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                post.isLiked ? Icons.favorite : Icons.favorite_border,
                                color: post.isLiked ? Colors.redAccent : Colors.grey.shade400,
                                size: 28,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

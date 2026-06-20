import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post.dart';
import '../providers/feed_provider.dart';

class LikeButton extends ConsumerWidget {
  final Post post;

  const LikeButton({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
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
          onTap: () {
            ref.read(feedProvider.notifier).toggleLike(post.id);
          },
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
    );
  }
}

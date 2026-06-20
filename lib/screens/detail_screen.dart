import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/post.dart';

class DetailScreen extends StatefulWidget {
  final Post post;

  const DetailScreen({super.key, required this.post});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _loadHighRes = false;

  @override
  Widget build(BuildContext context) {
    // Determine the target URL based on whether the user requested High Res
    final targetUrl = _loadHighRes
        ? (widget.post.mediaRawUrl ?? widget.post.mediaMobileUrl ?? widget.post.mediaThumbUrl)
        : (widget.post.mediaMobileUrl ?? widget.post.mediaThumbUrl);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          InteractiveViewer(
            minScale: 1.0,
            maxScale: 4.0,
            child: Hero(
              tag: 'hero_image_${widget.post.id}',
              child: CachedNetworkImage(
                imageUrl: targetUrl,
                fit: BoxFit.contain,
                fadeInDuration: const Duration(milliseconds: 400),
                placeholder: (context, url) {
                  final placeholderUrl = _loadHighRes
                      ? (widget.post.mediaMobileUrl ?? widget.post.mediaThumbUrl)
                      : widget.post.mediaThumbUrl;

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: placeholderUrl,
                        fit: BoxFit.contain,
                      ),
                      if (_loadHighRes)
                        const Center(
                          child: Chip(
                            label: Text('Loading High Res...', style: TextStyle(color: Colors.white)),
                            backgroundColor: Colors.black54,
                          ),
                        ),
                    ],
                  );
                },
                errorWidget: (context, url, error) {
                  final placeholderUrl = widget.post.mediaMobileUrl ?? widget.post.mediaThumbUrl;
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: placeholderUrl,
                        fit: BoxFit.contain,
                      ),
                      if (_loadHighRes)
                        const Center(
                          child: Chip(
                            label: Text('High Res unavailable. Showing standard.', style: TextStyle(color: Colors.white)),
                            backgroundColor: Colors.redAccent,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
          if (!_loadHighRes && widget.post.mediaRawUrl != null)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _loadHighRes = true;
                    });
                  },
                  icon: const Icon(Icons.high_quality),
                  label: const Text('Load High Res'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    backgroundColor: Colors.white.withValues(alpha: 0.9),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

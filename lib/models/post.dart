class Post {
  final String id;
  final DateTime createdAt;
  final String mediaThumbUrl;
  final String? mediaMobileUrl;
  final String? mediaRawUrl;
  final int likeCount;
  final bool isLiked;

  const Post({
    required this.id,
    required this.createdAt,
    required this.mediaThumbUrl,
    this.mediaMobileUrl,
    this.mediaRawUrl,
    required this.likeCount,
    required this.isLiked,
  });

  Post copyWith({
    String? id,
    DateTime? createdAt,
    String? mediaThumbUrl,
    String? mediaMobileUrl,
    String? mediaRawUrl,
    int? likeCount,
    bool? isLiked,
  }) {
    return Post(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      mediaThumbUrl: mediaThumbUrl ?? this.mediaThumbUrl,
      mediaMobileUrl: mediaMobileUrl ?? this.mediaMobileUrl,
      mediaRawUrl: mediaRawUrl ?? this.mediaRawUrl,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  factory Post.fromJson(Map<String, dynamic> json, {bool isLiked = false}) {
    return Post(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      mediaThumbUrl: json['media_thumb_url'] as String,
      mediaMobileUrl: json['media_mobile_url'] as String?,
      mediaRawUrl: json['media_raw_url'] as String?,
      likeCount: json['like_count'] as int? ?? 0,
      isLiked: isLiked,
    );
  }
}

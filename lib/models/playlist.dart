import 'package:emotion_music_player/models/song.dart';

class Playlist {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final bool isPublic;
  final int songCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  List<Song> songs;

  Playlist({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.isPublic = false,
    this.songCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.songs = const [],
  });

  Playlist copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    bool? isPublic,
    int? songCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Song>? songs,
  }) {
    return Playlist(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      isPublic: isPublic ?? this.isPublic,
      songCount: songCount ?? this.songCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      songs: songs ?? this.songs,
    );
  }

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
        id: json['id'],
        userId: json['user_id'],
        title: json['title'],
        description: json['description'],
        isPublic: json['is_public'] ?? false,
        songCount: json['song_count'] ?? 0,
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
        songs: (json['songs'] as List?)
            ?.map((songData) => Song.fromJson(songData))
            .toList() ?? [],
    );
}

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'is_public': isPublic,
      'song_count': songCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
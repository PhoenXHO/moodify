import 'dart:convert';

class Song {
  final String id;
  final String title;
  final String artist;
  final List<String> genres;
  final List<String> moods;
  final int favorites;
  final DateTime createdAt;
  bool isFavorite;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.genres,
    required this.moods,
    required this.favorites,
    required this.createdAt,
    this.isFavorite = false,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      genres: List<String>.from(json['genres']),
      moods: List<String>.from(json['moods']),
      favorites: json['favorites'],
      createdAt: DateTime.parse(json['created_at']),
      isFavorite: json['is_favorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'genres': jsonEncode(genres),
      'moods': jsonEncode(moods),
      'favorites': favorites,
      'created_at': createdAt.toIso8601String(),
      'is_favorite': isFavorite,
    };
  }
}

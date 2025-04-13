class PlaylistSong {
  final String id;
  final String playlistId;
  final String songId;
  final int position;
  final String? addedBy;
  final DateTime addedAt;

  PlaylistSong({
    required this.id,
    required this.playlistId,
    required this.songId,
    required this.position,
    this.addedBy,
    required this.addedAt,
  });

  factory PlaylistSong.fromJson(Map<String, dynamic> json) {
    return PlaylistSong(
      id: json['id'],
      playlistId: json['playlist_id'],
      songId: json['song_id'],
      position: json['position'],
      addedBy: json['added_by'],
      addedAt: DateTime.parse(json['added_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'playlist_id': playlistId,
      'song_id': songId,
      'position': position,
      'added_by': addedBy,
      'added_at': addedAt.toIso8601String(),
    };
  }
}
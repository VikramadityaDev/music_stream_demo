class Song {
  final String title;
  final String coverUrl;
  final String singer;
  final String url;

  Song({required this.title, required this.coverUrl, required this.singer, required this.url});

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      title: json['title'],
      coverUrl: json['coverUrl'],
      singer: json['singer'],
      url: json['url'],
    );
  }
}
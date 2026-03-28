/// 從常見 YouTube 網址解析 video id（供 [youtube_player_flutter] 使用）。
String? extractYoutubeVideoId(String url) {
  final trimmed = url.trim();
  if (trimmed.isEmpty) return null;

  final uri = Uri.tryParse(trimmed);
  if (uri == null) return null;

  if (uri.host.contains('youtu.be')) {
    final seg = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
    return seg.isEmpty ? null : seg;
  }

  if (uri.host.contains('youtube.com')) {
    final v = uri.queryParameters['v'];
    if (v != null && v.isNotEmpty) return v;
    final path = uri.pathSegments;
    if (path.length >= 2 && path[0] == 'embed') {
      return path[1];
    }
    if (path.length >= 2 && path[0] == 'shorts') {
      return path[1];
    }
  }

  return null;
}

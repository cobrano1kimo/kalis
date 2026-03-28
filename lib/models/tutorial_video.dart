/// 教學影片項目（首版寫死；日後可改為 API / JSON 載入）。
class TutorialVideo {
  const TutorialVideo({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.videoUrl,
  });

  final String id;
  final String title;
  final String description;

  /// 縮圖網址；placeholder 服務亦可用於 MVP。
  final String thumbnailUrl;

  /// 完整 YouTube 網址（支援 watch?v= 與 youtu.be）。
  final String videoUrl;
}

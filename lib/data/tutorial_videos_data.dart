import '../models/tutorial_video.dart';

/// 假資料：之後可替換為遠端 JSON 或 CMS。
const List<TutorialVideo> kTutorialVideos = [
  TutorialVideo(
    id: 't1',
    title: '前後對比拼接 — 快速上手',
    description: '示範如何拍攝 Before / After 並完成上下拼接與儲存。',
    thumbnailUrl: 'https://picsum.photos/seed/photocompare1/640/360',
    videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
  ),
  TutorialVideo(
    id: 't2',
    title: '團隊作品庫與分享',
    description: '在 App 內瀏覽拼接成果、分享給同事或客戶。',
    thumbnailUrl: 'https://picsum.photos/seed/photocompare2/640/360',
    videoUrl: 'https://youtu.be/jNQXAC9IVRw',
  ),
  TutorialVideo(
    id: 't3',
    title: '拍攝光線與構圖建議',
    description: '美業／產品照常見注意事項（範例影片）。',
    thumbnailUrl: 'https://picsum.photos/seed/photocompare3/640/360',
    videoUrl: 'https://www.youtube.com/watch?v=9bZkp7q19f0',
  ),
];

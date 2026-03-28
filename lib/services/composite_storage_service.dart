import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/saved_composite_item.dart';

/// 管理 App **專用**拼接輸出目錄（非系統檔案總管）。
///
/// Android / iOS 對「任意路徑檔案管理」限制多，使用者體驗上 App 內列表最穩定；
/// 成果集中於 [outputDirectory]，列表頁只讀此目錄。
class CompositeStorageService {
  CompositeStorageService._();

  static final CompositeStorageService instance = CompositeStorageService._();

  /// 舊版曾使用 `photo_compare_composites`；仍一併掃描以相容先前存檔。
  static const String _folderName = 'kalis_composites';
  static const String _legacyFolderName = 'photo_compare_composites';

  Directory? _dir;

  Future<Directory> get outputDirectory async {
    if (_dir != null) return _dir!;
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, _folderName));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    _dir = dir;
    return dir;
  }

  /// 儲存 JPEG 位元組，檔名帶時間戳。
  Future<File> saveJpegBytes(List<int> bytes) async {
    final dir = await outputDirectory;
    final name =
        'compare_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final file = File(p.join(dir.path, name));
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  /// 列出所有 .jpg / .jpeg / .png（依副檔名），新到舊排序。
  Future<List<SavedCompositeItem>> listComposites() async {
    final base = await getApplicationDocumentsDirectory();
    final dirs = <Directory>[
      await outputDirectory,
      Directory(p.join(base.path, _legacyFolderName)),
    ];

    final entities = <File>[];
    for (final dir in dirs) {
      if (!await dir.exists()) continue;
      entities.addAll(
        dir.listSync(followLinks: false).whereType<File>().where((f) {
          final ext = p.extension(f.path).toLowerCase();
          return ext == '.jpg' || ext == '.jpeg' || ext == '.png';
        }),
      );
    }

    entities.sort((a, b) {
      final ta = a.lastModifiedSync();
      final tb = b.lastModifiedSync();
      return tb.compareTo(ta);
    });

    return entities
        .map(
          (f) => SavedCompositeItem(
            file: f,
            name: p.basename(f.path),
            modified: f.lastModifiedSync(),
          ),
        )
        .toList();
  }

  Future<void> deleteFile(File file) async {
    if (await file.exists()) {
      await file.delete();
    }
  }
}

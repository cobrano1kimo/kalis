import 'dart:io';

/// App 內「拼接成果」列表單筆資料。
class SavedCompositeItem {
  SavedCompositeItem({
    required this.file,
    required this.name,
    required this.modified,
  });

  final File file;
  final String name;
  final DateTime modified;

  String get path => file.path;
}

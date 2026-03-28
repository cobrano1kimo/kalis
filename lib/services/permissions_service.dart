import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

/// 相機／相簿相關權限（依平台盡量請求；失敗時由 image_picker 再嘗試）。
class PermissionsService {
  const PermissionsService();

  /// 拍照前請求相機權限。
  Future<bool> ensureCamera() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return true;
    }
    final status = await Permission.camera.request();
    return status.isGranted || status.isLimited;
  }

  /// 從相簿選圖前請求相簿／照片權限。
  Future<bool> ensurePhotos() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return true;
    }
    if (Platform.isIOS) {
      final p = await Permission.photos.request();
      return p.isGranted || p.isLimited;
    }
    // Android 13+
    final photos = await Permission.photos.request();
    if (photos.isGranted || photos.isLimited) return true;
    // 舊版 Android
    final storage = await Permission.storage.request();
    return storage.isGranted;
  }
}

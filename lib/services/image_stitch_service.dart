import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// 前後圖上下拼接。
///
/// 規則：
/// - 兩張圖最終 **寬度相同**（取兩者原始寬度的較大值為目標寬度，各自等比例縮放）。
/// - 維持長寬比、不拉伸變形。
///
/// 預留擴充：左右拼接、Before/After 標籤、日期浮水印、滑桿比較 overlay 等，
/// 可在此類新增方法或策略參數，不必改動 UI 狀態機。
class ImageStitchService {
  const ImageStitchService();

  /// 垂直拼接（上：before，下：after）。輸出 JPEG。
  Future<Uint8List> stitchVerticalJpeg({
    required Uint8List beforeBytes,
    required Uint8List afterBytes,
    int quality = 92,
  }) async {
    final before = img.decodeImage(beforeBytes);
    final after = img.decodeImage(afterBytes);
    if (before == null) {
      throw StateError('無法解碼 Before 圖片');
    }
    if (after == null) {
      throw StateError('無法解碼 After 圖片');
    }

    final targetWidth = before.width > after.width ? before.width : after.width;

    final scaledBefore = _scaleToWidth(before, targetWidth);
    final scaledAfter = _scaleToWidth(after, targetWidth);

    final h = scaledBefore.height + scaledAfter.height;
    final canvas = img.Image(width: targetWidth, height: h);
    img.compositeImage(canvas, scaledBefore, dstX: 0, dstY: 0);
    img.compositeImage(canvas, scaledAfter, dstX: 0, dstY: scaledBefore.height);

    return Uint8List.fromList(img.encodeJpg(canvas, quality: quality));
  }

  img.Image _scaleToWidth(img.Image source, int targetWidth) {
    if (source.width == targetWidth) {
      return source;
    }
    final h = (source.height * targetWidth / source.width).round();
    return img.copyResize(
      source,
      width: targetWidth,
      height: h,
      interpolation: img.Interpolation.linear,
    );
  }
}

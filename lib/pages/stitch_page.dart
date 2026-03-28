import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/composite_storage_service.dart';
import '../services/image_stitch_service.dart';
import '../services/permissions_service.dart';

/// 前後對比拼接：選圖、預覽、產生、儲存。
///
/// 預留擴充：左右拼接、標籤、日期、滑桿比較 — 建議在 [ImageStitchService] 增加策略參數。
class StitchPage extends StatefulWidget {
  const StitchPage({super.key});

  @override
  State<StitchPage> createState() => _StitchPageState();
}

class _StitchPageState extends State<StitchPage> {
  final ImagePicker _picker = ImagePicker();
  final ImageStitchService _stitch = const ImageStitchService();
  final PermissionsService _perms = const PermissionsService();

  XFile? _beforeFile;
  XFile? _afterFile;
  Uint8List? _previewBytes;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _recoverLostPickerData());
  }

  /// Android 記憶體不足時 Activity 可能被回收，需於返回時取回選圖結果。
  Future<void> _recoverLostPickerData() async {
    final response = await _picker.retrieveLostData();
    if (!response.isEmpty && response.file != null) {
      final f = response.file!;
      if (!mounted) return;
      setState(() {
        final hadBefore = _beforeFile != null;
        _beforeFile ??= f;
        if (hadBefore && _afterFile == null) {
          _afterFile = f;
        }
        _previewBytes = null;
      });
    }
  }

  Future<void> _pickImage(ImageSource source, {required bool isBefore}) async {
    if (source == ImageSource.camera) {
      final ok = await _perms.ensureCamera();
      if (!ok && mounted) {
        _showSnack('需要相機權限才能拍照。請到系統設定中開啟。');
        return;
      }
    } else {
      await _perms.ensurePhotos();
    }

    try {
      final file = await _picker.pickImage(
        source: source,
        imageQuality: 92,
        maxWidth: 4096,
        maxHeight: 4096,
      );
      if (file == null) return;
      setState(() {
        if (isBefore) {
          _beforeFile = file;
        } else {
          _afterFile = file;
        }
        _previewBytes = null;
      });
    } catch (e) {
      if (mounted) {
        _showSnack('選取圖片失敗：$e');
      }
    }
  }

  void _showSourceSheet({required bool isBefore}) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('使用相機拍照'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera, isBefore: isBefore);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('從相簿選擇'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery, isBefore: isBefore);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _generate() async {
    final b = _beforeFile;
    final a = _afterFile;
    if (b == null || a == null) {
      _showSnack('請先選擇 Before 與 After 兩張圖片。');
      return;
    }
    setState(() => _busy = true);
    try {
      final beforeBytes = await b.readAsBytes();
      final afterBytes = await a.readAsBytes();
      final out = await _stitch.stitchVerticalJpeg(
        beforeBytes: beforeBytes,
        afterBytes: afterBytes,
      );
      if (mounted) {
        setState(() {
          _previewBytes = out;
          _busy = false;
        });
        _showSnack('拼接完成，可預覽並儲存。');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        _showSnack('拼接失敗：$e');
      }
    }
  }

  Future<void> _save() async {
    final bytes = _previewBytes;
    if (bytes == null) {
      _showSnack('請先按「產生拼接圖」。');
      return;
    }
    setState(() => _busy = true);
    try {
      await CompositeStorageService.instance.saveJpegBytes(bytes);
      if (mounted) {
        setState(() => _busy = false);
        _showSnack('已儲存至 Photo Compare 作品資料夾（卡莉絲 App 內）。');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        _showSnack('儲存失敗：$e');
      }
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Compare · 前後對比拼接'),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                '上下拼接 · 等寬 · 不變形',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 16),
              _SlotCard(
                label: 'Before（上方）',
                file: _beforeFile,
                onTap: () => _showSourceSheet(isBefore: true),
              ),
              const SizedBox(height: 12),
              _SlotCard(
                label: 'After（下方）',
                file: _afterFile,
                onTap: () => _showSourceSheet(isBefore: false),
              ),
              const SizedBox(height: 24),
              Text(
                '預覽',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              AspectRatio(
                aspectRatio: 3 / 4,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: _previewBytes != null
                        ? Image.memory(
                            _previewBytes!,
                            fit: BoxFit.contain,
                            gaplessPlayback: true,
                          )
                        : Center(
                            child: Text(
                              '選好兩張圖後按「產生拼接圖」',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: scheme.onSurfaceVariant),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _busy ? null : _generate,
                icon: const Icon(Icons.auto_fix_high_rounded),
                label: const Text('產生拼接圖'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _busy ? null : _save,
                icon: const Icon(Icons.save_alt_rounded),
                label: const Text('儲存結果'),
              ),
              const SizedBox(height: 24),
              Text(
                '說明：Photo Compare 成果儲存在 App 專用資料夾，可於「Photo Compare｜我的拼接成果」查看。'
                ' 因系統隱私限制，此處不提供開啟全系統檔案管理員。',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.outline,
                      height: 1.4,
                    ),
              ),
            ],
          ),
          if (_busy)
            const ColoredBox(
              color: Color(0x33000000),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

class _SlotCard extends StatelessWidget {
  const _SlotCard({
    required this.label,
    required this.file,
    required this.onTap,
  });

  final String label;
  final XFile? file;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Row(
            children: [
              // 本機路徑在 Android/iOS 不可用 network 載入；此處以圖示表示已選取（避免 dart:io 與 Web 衝突）。
              SizedBox(
                width: 64,
                height: 64,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: file != null
                        ? scheme.primaryContainer.withValues(alpha: 0.45)
                        : scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    file != null
                        ? Icons.check_circle_rounded
                        : Icons.add_photo_alternate_outlined,
                    color: file != null ? scheme.primary : scheme.outline,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      file == null ? '點擊選擇拍照或相簿' : file!.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.tune_rounded, color: scheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}

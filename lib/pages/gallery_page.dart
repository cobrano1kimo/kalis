import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/saved_composite_item.dart';
import '../services/composite_storage_service.dart';
import '../widgets/empty_state.dart';
import 'gallery_detail_page.dart';

/// App 內拼接成果列表（僅讀取 App 指定目錄，非系統檔案總管）。
class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  final _fmt = DateFormat('yyyy-MM-dd HH:mm');

  Future<List<SavedCompositeItem>> _load() =>
      CompositeStorageService.instance.listComposites();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Compare · 我的拼接成果'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: FutureBuilder<List<SavedCompositeItem>>(
          future: _load(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(child: Text('讀取失敗：${snap.error}'));
            }
            final items = snap.data ?? [];
            if (items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  EmptyState(
                    message: '尚無拼接成果。\n請先到「前後對比拼接」製作並儲存。',
                  ),
                ],
              );
            }
            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.82,
              ),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final item = items[i];
                return _GalleryTile(
                  item: item,
                  timeLabel: _fmt.format(item.modified),
                  onTap: () async {
                    await Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => GalleryDetailPage(item: item),
                      ),
                    );
                    if (mounted) setState(() {});
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _GalleryTile extends StatelessWidget {
  const _GalleryTile({
    required this.item,
    required this.timeLabel,
    required this.onTap,
  });

  final SavedCompositeItem item;
  final String timeLabel;
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
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(11)),
                  child: Image.file(
                    File(item.path),
                    fit: BoxFit.cover,
                    cacheWidth: 400,
                    errorBuilder: (context, error, stackTrace) => ColoredBox(
                      color: scheme.surfaceContainerHighest,
                      child: Icon(Icons.broken_image_outlined,
                          color: scheme.outline),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    Text(
                      timeLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

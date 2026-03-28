import 'package:flutter/material.dart';

import '../widgets/feature_card.dart';
import 'gallery_page.dart';
import 'stitch_page.dart';
import 'tutorial_list_page.dart';

/// 首頁：三個主要功能入口。
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Photo Compare',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: scheme.primary,
                            letterSpacing: -0.5,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '團隊產品輔助工具',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '前後對比拼接、作品庫與教學影片，操作簡潔、適合手機日常使用。',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.45,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  FeatureCard(
                    title: '前後對比拼接',
                    subtitle: '拍照或從相簿選擇 Before / After，上下拼接、等寬不變形。',
                    icon: Icons.compare_rounded,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const StitchPage()),
                    ),
                  ),
                  const SizedBox(height: 14),
                  FeatureCard(
                    title: '我的拼接成果',
                    subtitle: '瀏覽本 App 儲存的拼接圖（App 內作品庫，非系統檔案總管）。',
                    icon: Icons.photo_library_outlined,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const GalleryPage()),
                    ),
                  ),
                  const SizedBox(height: 14),
                  FeatureCard(
                    title: '教學影片',
                    subtitle: '觀看線上教學（YouTube 於 App 內嵌播放）。',
                    icon: Icons.play_circle_outline_rounded,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const TutorialListPage(),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

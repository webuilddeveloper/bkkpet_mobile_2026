import 'dart:io';

import 'package:bkkpet/blank_page/app_media_icon.dart';
import 'package:bkkpet/pages/lostpet/lost_found_model.dart';
import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';

class LostFoundMediaPreview extends StatelessWidget {
  const LostFoundMediaPreview({
    super.key,
    required this.mediaPath,
    required this.mediaKind,
    this.mediaName = '',
    this.aspectRatio = 1,
    this.borderRadius = 16,
    this.showName = false,
  });

  final String mediaPath;
  final String mediaKind;
  final String mediaName;
  final double aspectRatio;
  final double borderRadius;
  final bool showName;

  bool get _isImage => mediaKind == LostFoundMediaKind.image;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

    Widget content;
    if (mediaPath.isEmpty) {
      content = _Placeholder(
        icon: Icons.photo_library_outlined,
        iconAsset: appGalleryIconAsset,
        title: 'ไม่มีรูป',
        subtitle: 'ยังไม่ได้แนบสื่อ',
      );
    } else if (_isImage) {
      final file = File(mediaPath);
      final hasFile = mediaPath.startsWith('assets/') || file.existsSync();
      if (!hasFile) {
        content = _Placeholder(
          icon: Icons.photo_library_outlined,
          iconAsset: appGalleryIconAsset,
          title: 'ไม่พบรูป',
          subtitle: 'ไฟล์อาจถูกลบไปแล้ว',
        );
      } else {
        final image =
            mediaPath.startsWith('assets/')
                ? Image.asset(mediaPath, fit: BoxFit.cover)
                : Image.file(file, fit: BoxFit.cover);
        content = Stack(
          fit: StackFit.expand,
          children: [
            image,
            if (showName)
              Positioned(
                left: 10,
                right: 10,
                bottom: 10,
                child: _MediaLabel(
                  icon: Icons.photo_rounded,
                  text: mediaName.isNotEmpty ? mediaName : 'รูปภาพ',
                ),
              ),
          ],
        );
      }
    } else {
      content = Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF324A41), Color(0xFF1D2B26)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppMediaIcon(
                    asset: appVideoGalleryIconAsset,
                    fallbackIcon: Icons.videocam_rounded,
                    size: 38,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    mediaName.isNotEmpty ? mediaName : 'วิดีโอ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (showName)
              Positioned(
                left: 10,
                right: 10,
                bottom: 10,
                child: _MediaLabel(
                  icon: Icons.videocam_rounded,
                  text: mediaName.isNotEmpty ? mediaName : 'วิดีโอแนบ',
                ),
              ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: radius,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Container(color: AppColors.greyscale_50, child: content),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconAsset,
  });

  final IconData icon;
  final String? iconAsset;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.greyscale_50,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconAsset == null
              ? Icon(icon, color: AppColors.greyscale_300, size: 28)
              : AppMediaIcon(
                asset: iconAsset!,
                fallbackIcon: icon,
                size: 28,
                color: AppColors.greyscale_300,
              ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.greyscale_800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11, color: AppColors.greyscale_400),
          ),
        ],
      ),
    );
  }
}

class _MediaLabel extends StatelessWidget {
  const _MediaLabel({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

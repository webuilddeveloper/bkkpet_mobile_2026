import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';

const String appCameraIconAsset = 'assets/images/camera.png';
const String appCameraVideoIconAsset = 'assets/images/video.png';
const String appGalleryIconAsset = 'assets/icons/gallery.png';
const String appVideoGalleryIconAsset = 'assets/images/video_add.png';

class AppMediaIcon extends StatelessWidget {
  const AppMediaIcon({
    super.key,
    required this.asset,
    required this.fallbackIcon,
    this.size = 24,
    this.color = AppColors.primary,
  });

  final String asset;
  final IconData fallbackIcon;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      color: color,
      colorBlendMode: BlendMode.srcIn,
      errorBuilder:
          (_, __, ___) => Icon(fallbackIcon, size: size, color: color),
    );
  }
}

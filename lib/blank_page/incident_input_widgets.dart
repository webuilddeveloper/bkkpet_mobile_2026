import 'dart:typed_data';

import 'package:bkkpet/blank_page/app_media_icon.dart';
import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

enum SharedMediaKind { image, video }

class SharedPickedMedia {
  const SharedPickedMedia({required this.file, required this.kind});

  final XFile file;
  final SharedMediaKind kind;

  bool get isImage => kind == SharedMediaKind.image;
}

class SharedLocationPin {
  const SharedLocationPin({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
  });

  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime timestamp;

  String get coordinateText =>
      '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
}

class IncidentNoticeBanner extends StatelessWidget {
  const IncidentNoticeBanner({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.history_rounded,
    this.showAction = false,
    this.onTap,
    this.actionLabel,
  });

  final String title;
  final String message;
  final IconData icon;
  final bool showAction;
  final VoidCallback? onTap;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.greenlight.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primarySecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primarySecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primarySecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          if (showAction)
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.primarySecondary,
            ),
        ],
      ),
    );

    if (!showAction || onTap == null) return content;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: content,
    );
  }
}

Future<SharedPickedMedia?> pickSharedMediaFromSheet(
  BuildContext context, {
  bool allowCamera = true,
  bool allowGallery = true,
  bool allowVideo = false,
  bool videoOnly = false,
  String sheetTitle = 'เลือกสื่อ',
  String cameraLabel = 'ถ่ายรูป',
  String galleryLabel = 'เลือกจากคลังภาพ',
  String cameraVideoLabel = 'ถ่ายวิดีโอ',
  String galleryVideoLabel = 'เพิ่มวิดีโอ',
  String cameraSubtitle = 'เปิดกล้องเพื่อถ่ายภาพทันที',
  String gallerySubtitle = 'เลือกรูปหรือวิดีโอที่มีอยู่แล้ว',
  String cameraVideoSubtitle = 'เปิดกล้องเพื่อบันทึกวิดีโอทันที',
  String galleryVideoSubtitle = 'เลือกวิดีโอที่มีอยู่ในอุปกรณ์',
}) async {
  final picker = ImagePicker();
  FocusScope.of(context).unfocus();

  final source = await showModalBottomSheet<_SharedMediaChoice>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.greyscale_200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      sheetTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.greyscale_900,
                      ),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => Navigator.pop(sheetContext),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.greyscale_50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: AppColors.greyscale_400,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (allowCamera)
                _MediaSourceTile(
                  icon: Icons.photo_camera_rounded,
                  iconAsset:
                      videoOnly ? appCameraVideoIconAsset : appCameraIconAsset,
                  title: videoOnly ? 'ถ่ายวิดีโอ' : cameraLabel,
                  subtitle: videoOnly ? cameraVideoSubtitle : cameraSubtitle,
                  onTap:
                      () => Navigator.pop(
                        sheetContext,
                        videoOnly
                            ? _SharedMediaChoice.cameraVideo
                            : _SharedMediaChoice.cameraImage,
                      ),
                ),
              if (allowGallery)
                _MediaSourceTile(
                  icon: Icons.photo_library_rounded,
                  iconAsset:
                      videoOnly
                          ? appVideoGalleryIconAsset
                          : appGalleryIconAsset,
                  title: videoOnly ? 'เลือกวิดีโอจากคลัง' : galleryLabel,
                  subtitle: videoOnly ? galleryVideoSubtitle : gallerySubtitle,
                  onTap:
                      () => Navigator.pop(
                        sheetContext,
                        videoOnly
                            ? _SharedMediaChoice.galleryVideo
                            : _SharedMediaChoice.galleryImage,
                      ),
                ),
              if (allowVideo && allowCamera && !videoOnly)
                _MediaSourceTile(
                  icon: Icons.videocam_rounded,
                  iconAsset: appCameraVideoIconAsset,
                  title: cameraVideoLabel,
                  subtitle: cameraVideoSubtitle,
                  onTap:
                      () => Navigator.pop(
                        sheetContext,
                        _SharedMediaChoice.cameraVideo,
                      ),
                ),
              if (allowVideo && allowGallery && !videoOnly)
                _MediaSourceTile(
                  icon: Icons.video_library_rounded,
                  iconAsset: appVideoGalleryIconAsset,
                  title: galleryVideoLabel,
                  subtitle: galleryVideoSubtitle,
                  onTap:
                      () => Navigator.pop(
                        sheetContext,
                        _SharedMediaChoice.galleryVideo,
                      ),
                ),
            ],
          ),
        ),
      );
    },
  );

  if (source == null) return null;

  try {
    switch (source) {
      case _SharedMediaChoice.cameraImage:
        final picked = await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
          maxWidth: 1600,
        );
        if (picked == null) return null;
        return SharedPickedMedia(file: picked, kind: SharedMediaKind.image);
      case _SharedMediaChoice.galleryImage:
        final picked = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
          maxWidth: 1600,
        );
        if (picked == null) return null;
        return SharedPickedMedia(file: picked, kind: SharedMediaKind.image);
      case _SharedMediaChoice.cameraVideo:
        final picked = await picker.pickVideo(source: ImageSource.camera);
        if (picked == null) return null;
        return SharedPickedMedia(file: picked, kind: SharedMediaKind.video);
      case _SharedMediaChoice.galleryVideo:
        final picked = await picker.pickVideo(source: ImageSource.gallery);
        if (picked == null) return null;
        return SharedPickedMedia(file: picked, kind: SharedMediaKind.video);
    }
  } catch (e) {
    if (!context.mounted) return null;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('ไม่สามารถเลือกสื่อได้: $e')));
    return null;
  }
}

Future<SharedLocationPin> resolveCurrentLocation() async {
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw const _LocationLoadException(
      'ยังไม่ได้เปิดบริการตำแหน่งบนเครื่อง',
      needsLocationSettings: true,
    );
  }

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.denied) {
    throw const _LocationLoadException('แอปไม่ได้รับอนุญาตเข้าถึงตำแหน่ง');
  }

  if (permission == LocationPermission.deniedForever) {
    throw const _LocationLoadException(
      'การเข้าถึงตำแหน่งถูกปิดถาวร กรุณาเปิดสิทธิ์ในตั้งค่าแอป',
      needsAppSettings: true,
    );
  }

  final lastKnown = await Geolocator.getLastKnownPosition();
  final position =
      lastKnown ??
      await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

  return SharedLocationPin(
    latitude: position.latitude,
    longitude: position.longitude,
    accuracy: position.accuracy,
    timestamp: DateTime.now(),
  );
}

class SharedMediaPickerField extends StatefulWidget {
  const SharedMediaPickerField({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onChanged,
    this.initialValue,
    this.allowVideo = false,
    this.allowCamera = true,
    this.allowGallery = true,
    this.videoOnly = false,
    this.sheetTitle = 'เลือกสื่อ',
    this.cameraLabel = 'ถ่ายรูป',
    this.galleryLabel = 'เลือกจากคลังภาพ',
    this.cameraVideoLabel = 'ถ่ายวิดีโอ',
    this.galleryVideoLabel = 'เพิ่มวิดีโอ',
    this.showPreview = true,
  });

  final String title;
  final String subtitle;
  final SharedPickedMedia? initialValue;
  final ValueChanged<SharedPickedMedia?> onChanged;
  final bool allowVideo;
  final bool allowCamera;
  final bool allowGallery;
  final bool videoOnly;
  final String sheetTitle;
  final String cameraLabel;
  final String galleryLabel;
  final String cameraVideoLabel;
  final String galleryVideoLabel;
  final bool showPreview;

  @override
  State<SharedMediaPickerField> createState() => _SharedMediaPickerFieldState();
}

class _SharedMediaPickerFieldState extends State<SharedMediaPickerField> {
  SharedPickedMedia? _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  Future<void> _pick() async {
    final picked = await pickSharedMediaFromSheet(
      context,
      allowCamera: widget.allowCamera,
      allowGallery: widget.allowGallery,
      allowVideo: widget.allowVideo,
      videoOnly: widget.videoOnly,
      sheetTitle: widget.sheetTitle,
      cameraLabel: widget.cameraLabel,
      galleryLabel: widget.galleryLabel,
      cameraVideoLabel: widget.cameraVideoLabel,
      galleryVideoLabel: widget.galleryVideoLabel,
    );
    if (!mounted || picked == null) return;
    setState(() => _value = picked);
    widget.onChanged(picked);
  }

  void _clear() {
    setState(() => _value = null);
    widget.onChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = _value != null;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasValue ? AppColors.primary : AppColors.greyscale_200,
        ),
        color:
            hasValue ? AppColors.primary.withValues(alpha: 0.04) : Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color:
                      hasValue
                          ? AppColors.primary.withValues(alpha: 0.12)
                          : AppColors.greyscale_50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    hasValue
                        ? const Icon(
                          Icons.check_circle_rounded,
                          size: 20,
                          color: AppColors.primary,
                        )
                        : Image.asset(
                          appGalleryIconAsset,
                          height: 20,
                          color: AppColors.greyscale_400,
                          colorBlendMode: BlendMode.srcIn,
                          errorBuilder:
                              (_, __, ___) => const Icon(
                                Icons.photo_library_rounded,
                                size: 20,
                                color: AppColors.greyscale_400,
                              ),
                        ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.greyscale_900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasValue ? _value!.file.name : widget.subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            hasValue
                                ? AppColors.primary
                                : AppColors.greyscale_400,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasValue)
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: _clear,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.greyscale_50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: AppColors.greyscale_400,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (hasValue && widget.showPreview)
            SharedPickedMediaPreview(
              media: _value!,
              aspectRatio: 16 / 9,
            ),
          const SizedBox(height: 12),
          SizedBox(
            height: 46,
            child: OutlinedButton.icon(
              onPressed: _pick,
              icon:
                  hasValue
                      ? const Icon(
                        Icons.change_circle_outlined,
                        size: 18,
                        color: AppColors.primary,
                      )
                      : Image.asset(
                        appGalleryIconAsset,
                        width: 18,
                        height: 18,
                        color: AppColors.primary,
                        colorBlendMode: BlendMode.srcIn,
                        errorBuilder:
                            (_, __, ___) => const Icon(
                              Icons.photo_library_rounded,
                              size: 18,
                              color: AppColors.primary,
                            ),
                      ),
              label: Text(hasValue ? 'เปลี่ยนสื่อ' : 'เลือกสื่อ'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.35),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SharedPickedMediaPreview extends StatelessWidget {
  const SharedPickedMediaPreview({
    super.key,
    required this.media,
    this.aspectRatio = 16 / 9,
    this.borderRadius = 12,
    this.showName = true,
    this.emptyMessage = 'ยังไม่มีสื่อแนบ',
  });

  final SharedPickedMedia? media;
  final double aspectRatio;
  final double borderRadius;
  final bool showName;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    final mediaValue = media;
    if (mediaValue == null) {
      return Container(
        constraints: BoxConstraints(minHeight: 120),
        decoration: BoxDecoration(
          color: AppColors.greyscale_50,
          borderRadius: radius,
          border: Border.all(color: AppColors.greyscale_200),
        ),
        child: _SharedMediaEmptyState(message: emptyMessage),
      );
    }

    final preview = mediaValue.isImage
        ? FutureBuilder<Uint8List>(
            future: mediaValue.file.readAsBytes(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Image.memory(snapshot.data!, fit: BoxFit.cover);
              }
              return const Center(child: CircularProgressIndicator(strokeWidth: 2));
            },
          )
        : Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF24332E), Color(0xFF0F1815)],
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppMediaIcon(
                    asset: appVideoGalleryIconAsset,
                    fallbackIcon: Icons.videocam_rounded,
                    size: 42,
                    color: Colors.white,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'ตัวอย่างวิดีโอ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );

    return ClipRRect(
      borderRadius: radius,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: AppColors.greyscale_50, child: preview),
            if (showName)
              Positioned(
                left: 10,
                right: 10,
                bottom: 10,
                child: _MediaNameChip(
                  icon: mediaValue.isImage
                      ? Icons.photo_rounded
                      : Icons.videocam_rounded,
                  text: mediaValue.file.name,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SharedMediaEmptyState extends StatelessWidget {
  const _SharedMediaEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppMediaIcon(
              asset: appGalleryIconAsset,
              fallbackIcon: Icons.photo_library_outlined,
              size: 34,
              color: AppColors.greyscale_300,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.greyscale_400,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MediaNameChip extends StatelessWidget {
  const _MediaNameChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
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

class SharedLocationPinCard extends StatefulWidget {
  const SharedLocationPinCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onChanged,
    this.initialValue,
  });

  final String title;
  final String subtitle;
  final SharedLocationPin? initialValue;
  final ValueChanged<SharedLocationPin?> onChanged;

  @override
  State<SharedLocationPinCard> createState() => _SharedLocationPinCardState();
}

class _SharedLocationPinCardState extends State<SharedLocationPinCard> {
  SharedLocationPin? _value;
  String? _errorText;
  bool _needsAppSettings = false;
  bool _needsLocationSettings = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
    if (_value == null) {
      _loadCurrentLocation();
    }
  }

  Future<void> _openSettings() async {
    if (_needsAppSettings) {
      await Geolocator.openAppSettings();
    } else if (_needsLocationSettings) {
      await Geolocator.openLocationSettings();
    }
  }

  Future<void> _loadCurrentLocation() async {
    setState(() {
      _loading = true;
      _errorText = null;
    });

    try {
      final location = await resolveCurrentLocation();
      if (!mounted) return;
      setState(() {
        _value = location;
        _loading = false;
        _needsAppSettings = false;
        _needsLocationSettings = false;
      });
      widget.onChanged(location);
    } on _LocationLoadException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorText = e.message;
        _needsAppSettings = e.needsAppSettings;
        _needsLocationSettings = e.needsLocationSettings;
      });
      widget.onChanged(null);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorText = 'ไม่สามารถอ่านตำแหน่งได้: $e';
        _needsAppSettings = false;
        _needsLocationSettings = false;
      });
      widget.onChanged(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = _value != null;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasValue ? AppColors.primary : AppColors.greyscale_200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color:
                      hasValue
                          ? AppColors.primary.withValues(alpha: 0.12)
                          : AppColors.greyscale_50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  color: hasValue ? AppColors.primary : AppColors.greyscale_400,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.greyscale_900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.greyscale_400,
                      ),
                    ),
                  ],
                ),
              ),
              if (_loading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (hasValue)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.greyscale_25,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.gps_fixed_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'ใช้ตำแหน่งปัจจุบันเป็นค่าเริ่มต้น',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.greyscale_900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _value!.coordinateText,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.greyscale_800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ความแม่นยำประมาณ ${_value!.accuracy.toStringAsFixed(0)} เมตร',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.greyscale_400,
                    ),
                  ),
                ],
              ),
            )
          else if (_errorText != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.redAccent.withValues(alpha: 0.15),
                ),
              ),
              child: Text(
                _errorText!,
                style: const TextStyle(fontSize: 12.5, color: Colors.redAccent),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _loadCurrentLocation,
                    icon: const Icon(Icons.my_location_rounded, size: 18),
                    label: Text(
                      hasValue ? 'อัปเดตตำแหน่ง' : 'ใช้ตำแหน่งปัจจุบัน',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              if (_errorText != null) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: OutlinedButton(
                      onPressed:
                          (_needsAppSettings || _needsLocationSettings)
                              ? _openSettings
                              : _loadCurrentLocation,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.35),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _needsAppSettings || _needsLocationSettings
                            ? 'เปิดการตั้งค่า'
                            : 'ลองอีกครั้ง',
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _MediaSourceTile extends StatelessWidget {
  const _MediaSourceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconAsset,
  });

  final IconData icon;
  final String? iconAsset;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.greyscale_25,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.greyscale_200),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    iconAsset == null
                        ? Icon(icon, color: AppColors.primary)
                        : AppMediaIcon(asset: iconAsset!, fallbackIcon: icon),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.greyscale_900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.greyscale_400,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.greyscale_300,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _SharedMediaChoice { cameraImage, galleryImage, cameraVideo, galleryVideo }

class _LocationLoadException implements Exception {
  const _LocationLoadException(
    this.message, {
    this.needsAppSettings = false,
    this.needsLocationSettings = false,
  });

  final String message;
  final bool needsAppSettings;
  final bool needsLocationSettings;
}

import 'dart:io';

import 'package:bkkpet/blank_page/appbar.dart';
import 'package:bkkpet/blank_page/custom_dialog.dart';
import 'package:bkkpet/blank_page/incident_input_widgets.dart';
import 'package:bkkpet/pages/adoption/adoption_models.dart';
import 'package:bkkpet/pages/adoption/adoption_storage.dart';
import 'package:bkkpet/pages/adoption/adoption_ui_kit.dart';
import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';

class AdoptionOwnedPetDetailPage extends StatefulWidget {
  const AdoptionOwnedPetDetailPage({super.key, required this.record});

  final AdoptionAdoptedRecord record;

  @override
  State<AdoptionOwnedPetDetailPage> createState() =>
      _AdoptionOwnedPetDetailPageState();
}

class _AdoptionOwnedPetDetailPageState
    extends State<AdoptionOwnedPetDetailPage> {
  final _noteCtrl = TextEditingController();
  String _condition = 'สุขภาพแข็งแรงดี';
  SharedPickedMedia? _media;
  bool _saving = false;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_noteCtrl.text.trim().isEmpty) {
      await showInfoDialog(
        context: context,
        icon: Icons.error_outline_rounded,
        title: 'กรุณากรอกข้อมูล',
        message: 'บอกความคืบหน้าสั้น ๆ ให้เจ้าหน้าที่ทราบด้วยครับ',
        color: Colors.redAccent,
      );
      return;
    }

    setState(() => _saving = true);
    await AdoptionStorage.appendUpdate(
      recordId: widget.record.id,
      condition: _condition,
      note: _noteCtrl.text.trim(),
      mediaPath: _media?.file.path ?? '',
      mediaName: _media?.file.name ?? '',
      mediaKind: _media == null ? '' : (_media!.isImage ? 'image' : 'video'),
    );
    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    setState(() => _saving = false);

    await showInfoDialog(
      context: context,
      icon: Icons.check_circle_outline_rounded,
      title: 'ส่งอัปเดตแล้ว',
      message: 'ข้อมูลของ "${widget.record.pet.name}" ถูกส่งให้เจ้าหน้าที่แล้ว',
      color: AppColors.primary,
    );

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final pet = widget.record.pet;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarMainApp(
        title: 'อัปเดตข้อมูลสัตว์',
        onBack: () => Navigator.pop(context),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.greyscale_200),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: AdoptionPetAvatarPlaceholder(
                    species: pet.species,
                    imageAsset: pet.imageAsset,
                    height: 64,
                    borderRadius: 14,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.greyscale_900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${pet.breed} · ${pet.gender} · ${pet.ageLabel}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.greyscale_400,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.record.lastUpdateLabel,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.primarySecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AdoptionSectionCard(
            icon: Icons.rate_review_outlined,
            title: 'ส่งข้อมูลอัปเดตให้เจ้าหน้าที่',
            children: [
              AdoptionDropdown(
                label: 'สถานะทั่วไป',
                value: _condition,
                options: const [
                  'สุขภาพแข็งแรงดี',
                  'กินอาหารได้ปกติ',
                  'เริ่มคุ้นบ้านใหม่',
                  'มีอาการป่วย',
                ],
                onChanged: (v) => setState(() => _condition = v),
              ),
              AdoptionFormField(
                label: 'รายละเอียดเพิ่มเติม',
                controller: _noteCtrl,
                hint: 'เล่าความคืบหน้าเรื่องการปรับตัว การกิน หรือสุขภาพ',
                icon: Icons.notes_outlined,
                maxLines: 4,
              ),
              SharedMediaPickerField(
                key: ValueKey(_media?.file.path ?? 'empty'),
                title: 'แนบรูปหรือวิดีโอ',
                subtitle:
                    'เพิ่มหลักฐานสั้น ๆ เพื่อให้เจ้าหน้าที่ดูความคืบหน้าได้',
                allowVideo: true,
                sheetTitle: 'แนบรูปหรือวิดีโอ',
                cameraLabel: 'ถ่ายรูป',
                galleryLabel: 'เพิ่มรูป',
                cameraVideoLabel: 'ถ่ายวิดีโอ',
                galleryVideoLabel: 'เพิ่มวิดีโอ',
                showPreview: false,
                initialValue: _media,
                onChanged: (picked) => setState(() => _media = picked),
              ),
              const SizedBox(height: 12),
              SharedPickedMediaPreview(
                media: _media,
                aspectRatio: 16 / 10,
                borderRadius: 16,
                emptyMessage: 'ยังไม่มีรูปหรือวิดีโอแนบ',
              ),
              SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.greenlight),
                ),
                child: Text(
                  'โน๊ต: ข้อมูลนี้จะถูกบันทึกเป็นประวัติการติดตามหลังรับเลี้ยง',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.primarySecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AdoptionSectionCard(
            icon: Icons.history_rounded,
            title: 'ประวัติการอัปเดต',
            children:
                widget.record.updates.isEmpty
                    ? [
                      Text(
                        'ยังไม่มีข้อมูลการติดตาม',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.greyscale_400,
                        ),
                      ),
                    ]
                    : widget.record.updates
                        .map(
                          (entry) => Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.greyscale_25,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.greyscale_200,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        entry.condition,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.greyscale_900,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      _thaiDate(entry.createdAt),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.greyscale_400,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  entry.note,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.greyscale_400,
                                    height: 1.45,
                                  ),
                                ),
                                if (entry.hasMedia) ...[
                                  const SizedBox(height: 10),
                                  _HistoryMediaPreview(entry: entry),
                                ],
                              ],
                            ),
                          ),
                        )
                        .toList(),
          ),
        ],
      ),
      bottomNavigationBar: AdoptionBottomBar(
        child: AdoptionPrimaryButton(
          label: 'ส่งอัปเดตให้เจ้าหน้าที่',
          loading: _saving,
          icon: Icons.send_rounded,
          onPressed: _saving ? null : _submit,
        ),
      ),
    );
  }
}

class _HistoryMediaPreview extends StatelessWidget {
  const _HistoryMediaPreview({required this.entry});

  final AdoptionFollowUpEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.greyscale_200),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 78,
            height: 78,
            child:
                entry.hasVideo
                    ? Container(
                      color: AppColors.greyscale_50,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.play_circle_fill_rounded,
                        color: AppColors.primary,
                        size: 32,
                      ),
                    )
                    : Image.file(
                      File(entry.mediaPath),
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => Container(
                            color: AppColors.greyscale_50,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: AppColors.greyscale_300,
                            ),
                          ),
                    ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.hasVideo ? 'วิดีโอที่แนบไว้' : 'รูปภาพที่แนบไว้',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.greyscale_900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    entry.mediaName.isNotEmpty ? entry.mediaName : 'ไฟล์แนบ',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.greyscale_400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _thaiDate(DateTime date) {
  const months = [
    'ม.ค.',
    'ก.พ.',
    'มี.ค.',
    'เม.ย.',
    'พ.ค.',
    'มิ.ย.',
    'ก.ค.',
    'ส.ค.',
    'ก.ย.',
    'ต.ค.',
    'พ.ย.',
    'ธ.ค.',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year + 543}';
}

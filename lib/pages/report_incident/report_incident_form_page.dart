import 'package:bkkpet/blank_page/appbar.dart';
import 'package:bkkpet/blank_page/app_media_icon.dart';
import 'package:bkkpet/blank_page/custom_dialog.dart';
import 'package:bkkpet/blank_page/incident_input_widgets.dart';
import 'package:bkkpet/pages/report_incident/report_incident_model.dart';
import 'package:bkkpet/pages/report_incident/report_incident_storage.dart';
import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';

class ReportIncidentFormPage extends StatefulWidget {
  const ReportIncidentFormPage({super.key});

  @override
  State<ReportIncidentFormPage> createState() => _ReportIncidentFormPageState();
}

class _ReportIncidentFormPageState extends State<ReportIncidentFormPage> {
  String? incidentType;
  String urgency = 'ปกติ';
  final TextEditingController detailController = TextEditingController();
  SharedPickedMedia? _media;
  SharedLocationPin? _locationPin;
  bool _saving = false;

  final List<String> incidentTypes = [
    'พบสุนัขจรจัด',
    'พบแมวจรจัด',
    'สัตว์บาดเจ็บ/ป่วย',
    'สัตว์ดุร้าย',
    'พบสัตว์เสียชีวิต',
    'อื่น ๆ',
  ];

  final List<_UrgencyOption> _urgencyOptions = const [
    _UrgencyOption(
      value: 'ปกติ',
      label: 'ปกติ',
      description: 'บันทึกไว้ตรวจสอบตามรอบ',
      color: Color(0xff4CAF50),
      tint: Color(0xffEAF6EB),
    ),
    _UrgencyOption(
      value: 'เร่งด่วน',
      label: 'เร่งด่วน',
      description: 'ควรเข้าตรวจสอบเร็วขึ้น',
      color: Color(0xffF59E0B),
      tint: Color(0xffFFF4E1),
    ),
    _UrgencyOption(
      value: 'ฉุกเฉิน',
      label: 'ฉุกเฉิน',
      description: 'มีความเสี่ยงต่อคนหรือสัตว์',
      color: Color(0xffEF4444),
      tint: Color(0xffFDE8E8),
    ),
  ];

  @override
  void dispose() {
    detailController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    final type = incidentType?.trim() ?? '';
    final location = _locationPin;
    final media = _media;

    if (type.isEmpty || location == null || media == null) {
      await showInfoDialog(
        context: context,
        icon: Icons.info_outline_rounded,
        title: 'ข้อมูลยังไม่ครบ',
        message:
            'กรุณาเลือกประเภทเหตุ ปักหมุดตำแหน่ง และแนบรูปหรือวิดีโอให้ครบก่อนส่งเรื่อง',
        color: Colors.orange,
      );
      return;
    }

    setState(() => _saving = true);
    final now = DateTime.now();
    final report = ReportIncidentRecord(
      id: 'IR${now.millisecondsSinceEpoch % 1000000}',
      incidentType: type,
      urgency: urgency,
      detail: detailController.text.trim(),
      locationLatitude: location.latitude,
      locationLongitude: location.longitude,
      locationAccuracy: location.accuracy,
      locationTimestampIso: location.timestamp.toIso8601String(),
      mediaPath: media.file.path,
      mediaName: media.file.name,
      mediaKind:
          media.isImage ? IncidentMediaKind.image : IncidentMediaKind.video,
      status: ReportIncidentStatus.submitted,
      updates: [
        ReportIncidentUpdate(
          status: ReportIncidentStatus.submitted,
          title: 'ส่งเรื่องสำเร็จ',
          message: 'ระบบได้รับข้อมูลและรอการตรวจสอบ',
          timestampIso: now.toIso8601String(),
        ),
      ],
      createdAtIso: now.toIso8601String(),
    );

    await ReportIncidentStorage.add(report);
    if (!mounted) return;
    setState(() => _saving = false);

    await showInfoDialog(
      context: context,
      icon: Icons.check_circle_outline_rounded,
      title: 'ส่งเรื่องเรียบร้อยแล้ว',
      message: 'สามารถดูรายละเอียดและติดตามสถานะได้ที่หน้าติดตามสถานะ',
      color: AppColors.primary,
      onClose: () {
        if (!mounted) return;
        Navigator.pop(context);
      },
    );
  }

  InputDecoration _fieldDecoration({
    required String hintText,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: AppColors.greyscale_300, fontSize: 13),
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: AppColors.greyscale_25,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.greyscale_200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.greyscale_200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
    String? iconAsset,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.greyscale_200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.greyscale_50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    iconAsset == null
                        ? Icon(icon, color: AppColors.primary, size: 20)
                        : Padding(
                          padding: const EdgeInsets.all(8),
                          child: AppMediaIcon(
                            asset: iconAsset,
                            fallbackIcon: icon,
                            size: 24,
                          ),
                        ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.greyscale_900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: AppColors.greyscale_400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _urgencyChip(_UrgencyOption option) {
    final selected = urgency == option.value;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => setState(() => urgency = option.value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? option.tint : AppColors.greyscale_25,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? option.color : AppColors.greyscale_200,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: option.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  option.label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.greyscale_900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  option.description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.greyscale_400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarMainApp(
        title: 'ส่งเรื่องแจ้งเหตุ',
        onBack: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const IncidentNoticeBanner(
              title: 'หมายเหตุ',
              message:
                  'ระบุประเภท เหตุ ตำแหน่ง และแนบรูปหรือวิดีโอเพื่อให้ทีมงานรับเรื่องได้เร็วขึ้น',
              icon: Icons.note_alt_rounded,
            ),
            const SizedBox(height: 14),
            _sectionCard(
              title: 'ประเภทเหตุ',
              subtitle: 'เลือกชนิดเหตุที่พบเพื่อจัดลำดับการดำเนินงาน',
              icon: Icons.category_rounded,
              child: DropdownButtonFormField<String>(
                initialValue: incidentType,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                decoration: _fieldDecoration(
                  hintText: 'เลือกประเภทเหตุ',
                  prefixIcon: const Icon(
                    Icons.pets_rounded,
                    size: 18,
                    color: AppColors.greyscale_400,
                  ),
                ),
                items:
                    incidentTypes
                        .map(
                          (e) => DropdownMenuItem<String>(
                            value: e,
                            child: Text(
                              e,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    incidentType = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 14),
            _sectionCard(
              title: 'ตำแหน่ง',
              subtitle: 'บันทึกจุดเกิดเหตุให้ระบุพื้นที่ได้ชัดเจน',
              icon: Icons.place_rounded,
              child: SharedLocationPinCard(
                title: 'ตำแหน่งปัจจุบัน',
                subtitle: 'ระบบจะใช้จุดปัจจุบันเป็นค่าเริ่มต้น',
                initialValue: _locationPin,
                onChanged: (value) => setState(() => _locationPin = value),
              ),
            ),
            const SizedBox(height: 14),
            _sectionCard(
              title: 'รูปภาพ / วิดีโอ',
              subtitle: 'แนบหลักฐานเพื่อช่วยให้ตรวจสอบเหตุได้ง่ายขึ้น',
              icon: Icons.photo_library_rounded,
              iconAsset: appGalleryIconAsset,
              child: SharedMediaPickerField(
                title: 'แนบรูปภาพ / วิดีโอ',
                subtitle: 'แตะเพื่อถ่ายรูป เพิ่มรูป ถ่ายวีดีโอ หรือเพิ่มวีดีโอ',
                allowVideo: true,
                initialValue: _media,
                videoOnly: false,
                sheetTitle: 'เลือกสื่อ',
                cameraLabel: 'ถ่ายรูป',
                galleryLabel: 'เพิ่มรูป',
                cameraVideoLabel: 'ถ่ายวีดีโอ',
                galleryVideoLabel: 'เพิ่มวีดีโอ',
                onChanged: (value) => setState(() => _media = value),
              ),
            ),
            const SizedBox(height: 14),
            _sectionCard(
              title: 'รายละเอียด',
              subtitle: 'เล่าลักษณะเหตุ จุดสังเกต หรือข้อมูลเพิ่มเติม',
              icon: Icons.notes_rounded,
              child: TextField(
                controller: detailController,
                maxLines: 5,
                textAlignVertical: TextAlignVertical.top,
                decoration: _fieldDecoration(hintText: 'กรอกรายละเอียดเหตุ...'),
              ),
            ),
            const SizedBox(height: 14),
            _sectionCard(
              title: 'ระดับความเร่งด่วน',
              subtitle: 'ช่วยให้ทีมงานจัดลำดับการตอบสนองได้เหมาะสม',
              icon: Icons.priority_high_rounded,
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _urgencyOptions.map(_urgencyChip).toList(),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.greyscale_200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _saving ? null : _submitReport,
                      icon: const Icon(
                        Icons.send_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'ส่งเรื่อง',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _saving
                  ? 'กำลังบันทึกข้อมูล...'
                  : 'ข้อมูลของคุณจะช่วยให้หน่วยงานเข้าถึงจุดเกิดเหตุได้ตรงจุดมากขึ้น',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.greyscale_400),
            ),
          ],
        ),
      ),
    );
  }
}

class _UrgencyOption {
  const _UrgencyOption({
    required this.value,
    required this.label,
    required this.description,
    required this.color,
    required this.tint,
  });

  final String value;
  final String label;
  final String description;
  final Color color;
  final Color tint;
}

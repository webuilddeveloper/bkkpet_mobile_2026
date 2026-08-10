import 'package:bkkpet/blank_page/appbar.dart';
import 'package:bkkpet/blank_page/app_loading.dart';
import 'package:bkkpet/blank_page/incident_input_widgets.dart';
import 'package:bkkpet/mock_data.dart';
import 'package:bkkpet/pages/lostpet/lost_found_detail_page.dart';
import 'package:bkkpet/pages/lostpet/lost_found_media_preview.dart';
import 'package:bkkpet/pages/lostpet/lost_found_model.dart';
import 'package:bkkpet/pages/lostpet/lost_found_storage.dart';
import 'package:bkkpet/pages/pet_verification/form_sheet_widget.dart';
import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ================================================================
/// ตามหาสัตว์เลี้ยง
/// ประกาศตามหาสัตว์เลี้ยง พร้อมกระดานรายการแบบฟีด
/// ================================================================

class LostFoundPage extends StatefulWidget {
  const LostFoundPage({super.key});

  @override
  State<LostFoundPage> createState() => _LostFoundPageState();
}

class _LostFoundPageState extends State<LostFoundPage> {
  String _category = 'all'; // all / สุนัข / แมว
  bool _loading = true;
  List<LostFoundReport> _reports = [];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    if (mounted) setState(() => _loading = true);
    final reports = await LostFoundStorage.getAll();
    if (!mounted) return;
    setState(() {
      _reports = reports;
      _loading = false;
    });
  }

  String _formatDate(DateTime d) {
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
    return '${d.day} ${months[d.month - 1]} ${d.year + 543}';
  }

  Future<void> _openReportSheet() async {
    final speciesCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final colorCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    final chipCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    final contactNameCtrl = TextEditingController();
    final contactPhoneCtrl = TextEditingController();
    SharedPickedMedia? pickedMedia;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return FractionallySizedBox(
          heightFactor: 0.88,
          child: FormBottomSheet(
            title: 'เพิ่มประกาศตามหา',
            subtitle: 'กรอกข้อมูลและแนบรูปหรือวิดีโอเพื่อให้ตามหาได้ง่ายขึ้น',
            confirmLabel: 'ประกาศตามหา',
            confirmColor: Colors.redAccent,
            onConfirm: () async {
              if (speciesCtrl.text.trim().isEmpty ||
                  locationCtrl.text.trim().isEmpty ||
                  contactNameCtrl.text.trim().isEmpty ||
                  contactPhoneCtrl.text.trim().isEmpty) {
                return false;
              }

              final report = LostFoundReport(
                id: 'LF${DateTime.now().millisecondsSinceEpoch % 1000000}',
                type: LostFoundReportType.lost,
                species: speciesCtrl.text.trim(),
                petName: nameCtrl.text.trim(),
                colorDescription: colorCtrl.text.trim(),
                location: locationCtrl.text.trim(),
                dateIso: DateTime.now().toIso8601String(),
                chipId: chipCtrl.text.trim(),
                note: noteCtrl.text.trim(),
                mediaPath: pickedMedia?.file.path ?? '',
                mediaName: pickedMedia?.file.name ?? '',
                mediaKind:
                    pickedMedia == null
                        ? ''
                        : pickedMedia!.kind == SharedMediaKind.image
                        ? LostFoundMediaKind.image
                        : LostFoundMediaKind.video,
                contactName: contactNameCtrl.text.trim(),
                contactPhone: contactPhoneCtrl.text.trim(),
                createdAtIso: DateTime.now().toIso8601String(),
              );
              await LostFoundStorage.add(report);
              return true;
            },
            fields: [
              SheetFormField(
                label: 'ชนิดสัตว์',
                controller: speciesCtrl,
                icon: Icons.pets,
                required: true,
                hint: 'เช่น สุนัข, แมว',
              ),
              SheetFormField(
                label: 'ชื่อสัตว์เลี้ยง (ถ้าทราบ)',
                controller: nameCtrl,
                icon: Icons.badge_outlined,
              ),
              SheetFormField(
                label: 'ลักษณะ/สี',
                controller: colorCtrl,
                icon: Icons.palette_outlined,
                hint: 'เช่น สีน้ำตาล มีปลอกคอสีแดง',
              ),
              SheetFormField(
                label: 'บริเวณที่หายล่าสุด',
                controller: locationCtrl,
                icon: Icons.location_on_outlined,
                required: true,
              ),
              SheetFormField(
                label: 'หมายเลขไมโครชิป (ถ้าทราบ)',
                controller: chipCtrl,
                icon: Icons.memory_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              SheetFormField(
                label: 'รายละเอียดเพิ่มเติม',
                controller: noteCtrl,
                icon: Icons.edit_note_outlined,
                maxLines: 2,
                hint: 'เช่น นิสัย, จุดสังเกตพิเศษ',
              ),
              SheetFormField(
                label: 'ชื่อผู้ติดต่อ',
                controller: contactNameCtrl,
                icon: Icons.person_outline,
                required: true,
              ),
              SheetFormField(
                label: 'เบอร์โทรติดต่อ',
                controller: contactPhoneCtrl,
                icon: Icons.call_outlined,
                required: true,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
              ),
            ],
            additionalChildren: [
              const SizedBox(height: 2),
              Text(
                'หมายเหตุในประกาศจะแสดงในหน้ารายละเอียด เพื่อช่วยให้เจ้าของและผู้พบสัตว์ประสานงานได้ชัดเจนขึ้น',
                style: TextStyle(
                  fontSize: 11.5,
                  height: 1.45,
                  color: AppColors.greyscale_400,
                ),
              ),
              const SizedBox(height: 10),
              SharedMediaPickerField(
                title: 'แนบรูปหรือวิดีโอ',
                subtitle: 'ถ่ายหรือเลือกจากเครื่องได้',
                allowVideo: true,
                videoOnly: false,
                sheetTitle: 'แนบรูปหรือวิดีโอ',
                cameraLabel: 'ถ่ายรูป',
                galleryLabel: 'เลือกรูป',
                cameraVideoLabel: 'ถ่ายวิดีโอ',
                galleryVideoLabel: 'เลือกวิดีโอ',
                onChanged: (picked) => pickedMedia = picked,
              ),
              const SizedBox(height: 10),
              Text(
                'แนบสื่อช่วยให้คนที่พบสัตว์จำตัวได้ง่ายขึ้น',
                style: TextStyle(
                  fontSize: 11.5,
                  color: AppColors.greyscale_400,
                ),
              ),
            ],
          ),
        );
      },
    );

    await _loadReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarMainApp(
        title: 'ตามหาสัตว์เลี้ยง',
        onBack: () => Navigator.pop(context),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openReportSheet,
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('เพิ่มประกาศ'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.greyscale_50,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children:
                    mockLostPetCategories.map((category) {
                      final id = category['id'] as String;
                      return Expanded(
                        child: _CategoryTab(
                          label: category['label'] as String,
                          icon: category['icon'] as String,
                          selected: _category == id,
                          onTap: () => setState(() => _category = id),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
          Expanded(
            child:
                _loading
                    ? const Center(child: AppLoadingIndicator())
                    : AppRefreshIndicator(
                      onRefresh: _loadReports,
                      child: Builder(
                      builder: (context) {
                        var reports = _reports;
                        if (_category != 'all') {
                          reports =
                              reports
                                  .where((r) => r.species == _category)
                                  .toList();
                        }

                        if (reports.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.pets_outlined,
                                    size: 42,
                                    color: AppColors.greyscale_300,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'ยังไม่มีประกาศตามหาสัตว์เลี้ยงในขณะนี้',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      color: AppColors.greyscale_400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                          itemCount: reports.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final report = reports[index];
                            return _LostFoundCard(
                              report: report,
                              dateLabel: _formatDate(report.date),
                              onTap: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (_) =>
                                            LostFoundDetailPage(report: report),
                                  ),
                                );
                                await _loadReports();
                              },
                            );
                          },
                        );
                      },
                    ),
                    ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTab extends StatelessWidget {
  const _CategoryTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(11),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          boxShadow:
              selected
                  ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                    ),
                  ]
                  : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              icon,
              height: 17,
              color: selected ? AppColors.primary : AppColors.greyscale_400,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.primary : AppColors.greyscale_400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LostFoundCard extends StatelessWidget {
  const _LostFoundCard({
    required this.report,
    required this.dateLabel,
    required this.onTap,
  });

  final LostFoundReport report;
  final String dateLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accentColor = Colors.redAccent;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.greyscale_200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 92,
                  child: LostFoundMediaPreview(
                    mediaPath: report.mediaPath,
                    mediaKind: report.mediaKind,
                    mediaName: report.mediaName,
                    aspectRatio: 1,
                    borderRadius: 16,
                    showName: false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'ประกาศตามหา',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: accentColor,
                              ),
                            ),
                          ),
                          if (report.resolved)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.greyscale_200,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'ปิดประกาศแล้ว',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.greyscale_800,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        report.petName.isNotEmpty
                            ? '${report.petName} • ${report.species}'
                            : report.species,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: AppColors.greyscale_900,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (report.colorDescription.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          report.colorDescription,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.greyscale_400,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.greyscale_300,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 13,
                  color: AppColors.greyscale_300,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    report.location,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.greyscale_400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  dateLabel,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.greyscale_300,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

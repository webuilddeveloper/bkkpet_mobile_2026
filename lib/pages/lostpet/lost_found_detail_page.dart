import 'package:bkkpet/blank_page/appbar.dart';
import 'package:bkkpet/blank_page/custom_dialog.dart';
import 'package:bkkpet/pages/lostpet/lost_found_media_preview.dart';
import 'package:bkkpet/pages/lostpet/lost_found_model.dart';
import 'package:bkkpet/pages/lostpet/lost_found_storage.dart';
import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ================================================================
/// หน้าแสดงรายละเอียดประกาศตามหาสัตว์เลี้ยง
/// ================================================================
class LostFoundDetailPage extends StatefulWidget {
  const LostFoundDetailPage({super.key, required this.report});

  final LostFoundReport report;

  @override
  State<LostFoundDetailPage> createState() => _LostFoundDetailPageState();
}

class _LostFoundDetailPageState extends State<LostFoundDetailPage> {
  late LostFoundReport _report;

  static const _months = [
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

  @override
  void initState() {
    super.initState();
    _report = widget.report;
  }

  String _formatDate(DateTime d) {
    return '${d.day} ${_months[d.month - 1]} ${d.year + 543}';
  }

  String _formatDateTime(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final hh = d.hour.toString().padLeft(2, '0');
    final mi = d.minute.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year + 543} $hh:$mi น.';
  }

  Future<void> _copyPhone() async {
    await Clipboard.setData(ClipboardData(text: _report.contactPhone));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('คัดลอกเบอร์โทรแล้ว')));
  }

  Future<void> _closeReport() async {
    await showConfirmDialog(
      context: context,
      icon: Icons.task_alt_rounded,
      title: 'ต้องการปิดประกาศนี้ใช่หรือไม่?',
      message: 'ระบบจะซ่อนประกาศนี้จากฟีด และแสดงสถานะว่า "ปิดประกาศแล้ว"',
      confirmText: 'ปิดประกาศ',
      confirmColor: AppColors.primary,
      onConfirm: () async {
        await LostFoundStorage.remove(_report.id);
        if (!mounted) return;
        setState(() => _report = _report.copyWith(resolved: true));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = Colors.redAccent;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarMainApp(
        title: 'รายละเอียดประกาศ',
        onBack: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.greyscale_200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        LostFoundMediaPreview(
                          mediaPath: _report.mediaPath,
                          mediaKind: _report.mediaKind,
                          mediaName: _report.mediaName,
                          aspectRatio: 16 / 10,
                          borderRadius: 18,
                          showName: true,
                        ),
                        const SizedBox(height: 14),
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
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    _report.resolved
                                        ? AppColors.greyscale_200
                                        : AppColors.primaryLight.withValues(
                                          alpha: 0.4,
                                        ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _report.resolved ? 'ปิดประกาศแล้ว' : 'รอเบาะแส',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      _report.resolved
                                          ? AppColors.greyscale_800
                                          : AppColors.primarySecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _report.petName.isNotEmpty
                              ? '${_report.petName} • ${_report.species}'
                              : _report.species,
                          style: TextStyle(
                            color: AppColors.greyscale_900,
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                          ),
                        ),
                        if (_report.colorDescription.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            _report.colorDescription,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.greyscale_400,
                              height: 1.45,
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          'หมายเลขประกาศ ${_report.id}',
                          style: TextStyle(
                            color: AppColors.greyscale_300,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  _DetailCard(
                    icon: Icons.pets,
                    title: 'ลักษณะสัตว์เลี้ยง',
                    children: [
                      _DetailRow(label: 'ชนิด', value: _report.species),
                      if (_report.petName.isNotEmpty)
                        _DetailRow(label: 'ชื่อ', value: _report.petName),
                      if (_report.colorDescription.isNotEmpty)
                        _DetailRow(
                          label: 'ลักษณะ/สี',
                          value: _report.colorDescription,
                        ),
                      if (_report.chipId.isNotEmpty)
                        _DetailRow(
                          label: 'หมายเลขไมโครชิป',
                          value: _report.chipId,
                        ),
                      if (_report.note.isNotEmpty)
                        _DetailRow(
                          label: 'รายละเอียดเพิ่มเติม',
                          value: _report.note,
                        ),
                    ],
                  ),

                  _DetailCard(
                    icon: Icons.location_on_outlined,
                    title: 'จุดที่หายล่าสุด',
                    children: [
                      _DetailRow(label: 'สถานที่', value: _report.location),
                      _DetailRow(
                        label: 'วันที่หาย',
                        value: _formatDate(_report.date),
                      ),
                      _DetailRow(
                        label: 'ประกาศเมื่อ',
                        value: _formatDateTime(_report.createdAt),
                      ),
                    ],
                  ),

                  _DetailCard(
                    icon: Icons.contact_phone_outlined,
                    title: 'ข้อมูลผู้ติดต่อ',
                    children: [
                      _DetailRow(label: 'ชื่อ', value: _report.contactName),
                      _DetailRow(
                        label: 'เบอร์โทร',
                        value: _report.contactPhone,
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _copyPhone,
                          icon: Icon(
                            Icons.copy_rounded,
                            size: 16,
                            color: accentColor,
                          ),
                          label: Text(
                            'คัดลอกเบอร์โทร',
                            style: TextStyle(color: accentColor),
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 44),
                            side: BorderSide(color: accentColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child:
                    _report.resolved
                        ? Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.greyscale_50,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'ปิดประกาศแล้ว',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        )
                        : ElevatedButton.icon(
                          onPressed: _closeReport,
                          icon: const Icon(
                            Icons.task_alt_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                          label: const Text('ปิดประกาศว่าเจอแล้ว'),
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
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.icon,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyscale_200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.greyscale_900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: AppColors.greyscale_400),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.greyscale_900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

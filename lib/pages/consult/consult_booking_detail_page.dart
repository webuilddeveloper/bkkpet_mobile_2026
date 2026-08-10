import 'package:bkkpet/blank_page/appbar.dart';
import 'package:bkkpet/blank_page/custom_dialog.dart';
import 'package:bkkpet/pages/consult/consult_booking_history_page.dart';
import 'package:bkkpet/pages/consult/consult_booking_model.dart';
import 'package:bkkpet/pages/consult/consult_booking_storage.dart';
import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';

class ConsultBookingDetailPage extends StatelessWidget {
  const ConsultBookingDetailPage({
    super.key,
    required this.record,
    this.justBooked = false,
  });

  final ConsultBookingRecord record;
  final bool justBooked;

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

  Future<void> _cancel(BuildContext context) async {
    await showConfirmDialog(
      context: context,
      icon: Icons.warning_amber_rounded,
      title: 'ยกเลิกนัดปรึกษา',
      message: 'ต้องการยกเลิกนัดปรึกษาสัตวแพทย์นี้ใช่หรือไม่?',
      confirmText: 'ยืนยันยกเลิก',
      confirmColor: Colors.redAccent,
      onConfirm: () async {
        await ConsultBookingStorage.updateStatus(record.id, 'ยกเลิกแล้ว');
        if (context.mounted) Navigator.of(context).pop(true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyscale_25,
      appBar: AppBarMainApp(
        title: justBooked ? 'จองนัดสำเร็จ' : 'รายละเอียดนัดหมาย',
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
                  child: Image.asset(
                    record.doctorImage,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.doctorName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.greyscale_900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        record.specialty,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.greyscale_400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        record.clinicName,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.greyscale_800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.greenlight.withValues(alpha: 0.45),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'เลขที่นัด',
                  style: TextStyle(
                    color: AppColors.primarySecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  record.id,
                  style: TextStyle(
                    color: AppColors.primarySecondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'วันเวลานัดหมาย',
            children: [
              _Row('วันที่', _formatDate(record.bookingDate)),
              _Row('ช่วงเวลา', record.timeSlot),
              _Row('รูปแบบ', record.consultType),
            ],
          ),
          const SizedBox(height: 12),
          _Section(
            title: 'สัตว์เลี้ยง',
            children: [
              _Row('ชื่อ', record.petName),
              _Row('ชนิด', record.petSpecies),
            ],
          ),
          const SizedBox(height: 12),
          _Section(
            title: 'หมายเหตุ',
            children: [
              Text(
                record.note,
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.55,
                  color: AppColors.greyscale_800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (!justBooked && record.status != 'ยกเลิกแล้ว')
            SizedBox(
              height: 50,
              child: OutlinedButton(
                onPressed: () => _cancel(context),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.redAccent),
                  foregroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('ยกเลิกนัด'),
              ),
            ),
          const SizedBox(height: 10),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ConsultBookingHistoryPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('ดูนัดหมายของฉัน'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.greyscale_200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.greyscale_900,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 84,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.greyscale_400,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13.5,
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

import 'package:bkkpet/blank_page/appbar.dart';
import 'package:bkkpet/blank_page/custom_dialog.dart';
import 'package:bkkpet/pages/sterilization/sterilization_booking_model.dart';
import 'package:bkkpet/pages/sterilization/sterilization_booking_storage.dart';
import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';

/// ================================================================
/// รายละเอียดการจองทำหมัน
/// เปิดจากหน้าจองหลังยืนยันสำเร็จ (justBooked = true) หรือจากประวัติการจอง
/// ================================================================
class SterilizationBookingDetailPage extends StatelessWidget {
  const SterilizationBookingDetailPage({
    super.key,
    required this.record,
    this.justBooked = false,
  });

  final SterilizationBookingRecord record;

  /// true เมื่อเพิ่งจองสำเร็จมาจากหน้าจอง เพื่อแสดงแบนเนอร์ยืนยัน
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

  Color _statusColor(String status) {
    switch (status) {
      case 'เสร็จสิ้น':
        return AppColors.primary;
      case 'ยกเลิกแล้ว':
        return Colors.redAccent;
      default:
        return AppColors.primarySecondary;
    }
  }

  Future<void> _cancelBooking(BuildContext context) async {
    await showConfirmDialog(
      context: context,
      icon: Icons.warning_amber_rounded,
      title: 'ยกเลิกการจอง',
      message:
          'ต้องการยกเลิกคิวทำหมันของ "${record.petName}" ใช่หรือไม่?\nการดำเนินการนี้ไม่สามารถย้อนกลับได้',
      confirmText: 'ยืนยันยกเลิก',
      confirmColor: Colors.redAccent,
      onConfirm: () async {
        await SterilizationBookingStorage.updateStatus(record.id, 'ยกเลิกแล้ว');
        if (context.mounted) {
          Navigator.of(context).pop(true);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobilePoint = record.pointType == 'mobile';

    return Scaffold(
      backgroundColor: AppColors.greyscale_25,
      appBar: AppBarMainApp(
        title: 'รายละเอียดการจอง',
        onBack: () => Navigator.pop(context),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          if (justBooked)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.35),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.greenlight.withOpacity(0.6),
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'จองคิวทำหมันสำเร็จ',
                          style: TextStyle(
                            color: AppColors.primarySecondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'กรุณามาตามวันเวลาที่นัดหมาย และนำสัตว์เลี้ยงมาตามความพร้อมที่แจ้งไว้',
                          style: TextStyle(
                            color: AppColors.primarySecondary,
                            fontSize: 12.5,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // ---- รหัสการจอง + สถานะ ----
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.greyscale_200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'รหัสการจอง',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.greyscale_400,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        record.id,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.greyscale_900,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(record.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    record.status,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: _statusColor(record.status),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ---- ข้อมูลสัตว์เลี้ยง ----
          _DetailCard(
            icon: Icons.pets,
            title: 'ข้อมูลสัตว์เลี้ยง',
            rows: [
              _DetailRow('ชื่อ', record.petName),
              _DetailRow('ชนิด', record.species),
              _DetailRow('เพศ', record.gender),
              if (record.age.isNotEmpty) _DetailRow('อายุ', '${record.age} ปี'),
              if (record.weight.isNotEmpty)
                _DetailRow('น้ำหนัก', '${record.weight} กก.'),
            ],
          ),

          const SizedBox(height: 14),

          // ---- วันเวลา + สถานที่ ----
          _DetailCard(
            icon: Icons.event_available_outlined,
            title: 'วันเวลาและสถานที่',
            rows: [
              _DetailRow('วันที่นัดหมาย', _formatDate(record.date)),
              _DetailRow('ช่วงเวลา', record.timeSlot),
              _DetailRow('เขตพื้นที่', record.district),
              _DetailRow(
                'สถานที่',
                '${record.pointName}${isMobilePoint ? ' (หน่วยเคลื่อนที่)' : ''}',
              ),
              _DetailRow('ที่อยู่', record.pointAddress),
            ],
          ),

          const SizedBox(height: 14),

          // ---- ความพร้อมก่อนผ่าตัด ----
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.greyscale_200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.checklist_rtl,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'ความพร้อมก่อนผ่าตัด',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.greyscale_900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _ChecklistRow('งดอาหารก่อนผ่าตัด', record.fasted),
                _ChecklistRow('ตรวจสุขภาพเบื้องต้นแล้ว', record.healthChecked),
                _ChecklistRow('ฉีดวัคซีนครบตามกำหนด', record.vaccinated),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ---- ผู้จอง ----
          _DetailCard(
            icon: Icons.person_outline,
            title: 'ข้อมูลผู้จอง',
            rows: [
              _DetailRow('ชื่อ-นามสกุล', record.ownerName),
              _DetailRow('เบอร์โทรศัพท์', record.ownerPhone),
              if (record.note.isNotEmpty) _DetailRow('หมายเหตุ', record.note),
              _DetailRow(
                'จองเมื่อ',
                '${_formatDate(record.createdAt)} ${record.createdAt.hour.toString().padLeft(2, '0')}:${record.createdAt.minute.toString().padLeft(2, '0')} น.',
              ),
            ],
          ),

          if (record.status == 'รอดำเนินการ') ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () => _cancelBooking(context),
                icon: const Icon(
                  Icons.cancel_outlined,
                  size: 18,
                  color: Colors.redAccent,
                ),
                label: const Text(
                  'ยกเลิกการจอง',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow {
  const _DetailRow(this.label, this.value);
  final String label;
  final String value;
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.icon,
    required this.title,
    required this.rows,
  });

  final IconData icon;
  final String title;
  final List<_DetailRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.greyscale_200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.greyscale_900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 110,
                    child: Text(
                      row.label,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.greyscale_400,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      row.value,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.greyscale_900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow(this.label, this.checked);
  final String label;
  final bool checked;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            checked ? Icons.check_circle : Icons.remove_circle_outline,
            size: 18,
            color: checked ? AppColors.primary : AppColors.greyscale_300,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 13.5, color: AppColors.greyscale_800),
            ),
          ),
        ],
      ),
    );
  }
}

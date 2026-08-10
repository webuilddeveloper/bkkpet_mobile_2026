import 'package:bkkpet/blank_page/appbar.dart';
import 'package:bkkpet/pages/vaccine/vaccine_booking_history_page.dart';
import 'package:bkkpet/pages/vaccine/vaccine_booking_model.dart';
import 'package:bkkpet/pages/vaccine/vaccine_page.dart';

import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';

/// ================================================================
/// หน้าแสดงรายละเอียดการจองฉีดวัคซีน (ใบยืนยัน / ใบเสร็จการจอง)
///
/// ใช้แสดงผลได้ 2 บริบท:
///  - justBooked = true  : แสดงทันทีหลังกดยืนยันการจองสำเร็จ
///  - justBooked = false : แสดงเมื่อกดดูรายการจากประวัติการจอง
/// ================================================================
class VaccineBookingDetailPage extends StatelessWidget {
  const VaccineBookingDetailPage({
    super.key,
    required this.record,
    this.justBooked = false,
  });

  final VaccineBookingRecord record;
  final bool justBooked;

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

  @override
  Widget build(BuildContext context) {
    final isMobilePoint = record.pointType == 'mobile';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarMainApp(
        title: justBooked ? 'จองคิวสำเร็จ' : 'รายละเอียดการจอง',
        onBack: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  // ---- หัวใบยืนยัน ----
                  // Container(
                  //   width: double.infinity,
                  //   padding: const EdgeInsets.symmetric(
                  //     horizontal: 18,
                  //     vertical: 16,
                  //   ),
                  //   decoration: BoxDecoration(
                  //     color: AppColors.primary,
                  //     borderRadius: BorderRadius.circular(20),
                  //   ),
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Text(
                  //         justBooked ? 'จองคิวฉีดวัคซีนสำเร็จ' : record.status,
                  //         style: const TextStyle(
                  //           color: Colors.white,
                  //           fontSize: 16,
                  //           fontWeight: FontWeight.w700,
                  //         ),
                  //       ),
                  //       const SizedBox(height: 10),
                  //       Row(
                  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //         children: [
                  //           Text(
                  //             'เลขที่จอง',
                  //             style: TextStyle(
                  //               color: Colors.white.withOpacity(0.85),
                  //               fontSize: 13,
                  //             ),
                  //           ),
                  //           Text(
                  //             record.id,
                  //             style: const TextStyle(
                  //               color: Colors.white,
                  //               fontSize: 16,
                  //               fontWeight: FontWeight.bold,
                  //               letterSpacing: 0.8,
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.35),
                      border: Border.all(
                        color: AppColors.greenlight.withOpacity(0.6),
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'เลขที่จอง',
                          style: TextStyle(
                            color: AppColors.primarySecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            // color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(14),
                            // color: AppColors.primarySecondary,
                            border: Border.all(
                              color: AppColors.primarySecondary,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            child: Text(
                              record.id,
                              style: const TextStyle(
                                color: AppColors.primarySecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'กรุณานำหมายเลขนี้มาแสดงในวันเข้ารับบริการ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.greyscale_400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ---- วันเวลานัดหมาย ----
                  _DetailCard(
                    icon: Icons.event_available_outlined,
                    title: 'วันเวลานัดหมาย',
                    children: [
                      _DetailRow(
                        label: 'วันที่',
                        value: _formatDate(record.date),
                      ),
                      _DetailRow(label: 'ช่วงเวลา', value: record.timeSlot),
                    ],
                  ),

                  // ---- จุดบริการ ----
                  _DetailCard(
                    icon: Icons.location_on_outlined,
                    title: 'จุดบริการ',
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              record.pointName,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: AppColors.greyscale_900,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: (isMobilePoint
                                      ? AppColors.primarySecondary
                                      : AppColors.primary)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isMobilePoint ? 'หน่วยเคลื่อนที่' : 'จุดประจำ',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color:
                                    isMobilePoint
                                        ? AppColors.primarySecondary
                                        : AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        record.pointAddress,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.greyscale_400,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'เขต${record.district}',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.greyscale_400,
                        ),
                      ),
                    ],
                  ),

                  // ---- สัตว์เลี้ยง ----
                  _DetailCard(
                    icon: Icons.pets,
                    title: 'สัตว์เลี้ยงที่จอง (${record.pets.length} ตัว)',
                    children: [
                      for (final pet in record.pets)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Icon(
                                Icons.circle,
                                size: 5,
                                color: AppColors.greyscale_300,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${pet['name']} • ${pet['species']}',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: AppColors.greyscale_900,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  // ---- วัคซีน ----
                  _DetailCard(
                    icon: Icons.vaccines_outlined,
                    title: 'วัคซีนที่จะได้รับ',
                    children: [
                      _DetailRow(
                        label: 'วัคซีนพิษสุนัขบ้า',
                        value: 'ฟรี (ทุกตัว)',
                        valueColor: AppColors.primary,
                      ),
                      if (record.comboVaccines.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'ไม่ได้เลือกวัคซีนรวมเสริม',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.greyscale_400,
                            ),
                          ),
                        )
                      else ...[
                        const SizedBox(height: 4),
                        for (final v in record.comboVaccines)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.add_circle_outline,
                                  size: 13,
                                  color: AppColors.primarySecondary,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    v,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.greyscale_900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const Divider(height: 18),
                        _DetailRow(
                          label: 'ค่าใช้จ่ายวัคซีนเสริมโดยประมาณ',
                          value: '${record.comboTotalPrice} บาท',
                          valueColor: AppColors.primarySecondary,
                          bold: true,
                        ),
                      ],
                    ],
                  ),

                  // ---- ผู้จอง ----
                  _DetailCard(
                    icon: Icons.person_outline,
                    title: 'ข้อมูลผู้จอง',
                    children: [
                      _DetailRow(
                        label: 'ชื่อ-นามสกุล',
                        value: record.ownerName,
                      ),
                      _DetailRow(label: 'เบอร์โทร', value: record.ownerPhone),
                      if (record.note.trim().isNotEmpty)
                        _DetailRow(label: 'หมายเหตุ', value: record.note),
                      _DetailRow(
                        label: 'จองเมื่อ',
                        value: _formatDateTime(record.createdAt),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ---- ปุ่มด้านล่าง ----
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const VaccineBookingHistoryPage(),
                            ),
                          ),
                      icon: Icon(
                        Icons.history_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      label: const Text('ประวัติการจอง'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        minimumSize: const Size(0, 50),
                        side: BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (justBooked) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const VaccinePage(),
                            ),
                          );
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const VaccinePage(),
                            ),
                          );
                        }
                      },
                      icon: const Icon(
                        Icons.add_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: const Text('จองคิวเพิ่ม'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 50),
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
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            // flex: 4,
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: AppColors.greyscale_400),
            ),
          ),
          Expanded(
            // flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
                color: valueColor ?? AppColors.greyscale_900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

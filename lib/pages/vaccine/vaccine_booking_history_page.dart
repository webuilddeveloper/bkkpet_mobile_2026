import 'package:bkkpet/blank_page/appbar.dart';
import 'package:bkkpet/blank_page/custom_dialog.dart';
import 'package:bkkpet/pages/vaccine/vaccine_booking_detail_page.dart';
import 'package:bkkpet/pages/vaccine/vaccine_booking_model.dart';
import 'package:bkkpet/pages/vaccine/vaccine_booking_storage.dart';
import 'package:bkkpet/pages/vaccine/vaccine_page.dart';

import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';

/// ================================================================
/// ประวัติการจองฉีดวัคซีนทั้งหมด (อ่านจาก local storage)
/// ================================================================
class VaccineBookingHistoryPage extends StatefulWidget {
  const VaccineBookingHistoryPage({super.key});

  @override
  State<VaccineBookingHistoryPage> createState() =>
      _VaccineBookingHistoryPageState();
}

class _VaccineBookingHistoryPageState extends State<VaccineBookingHistoryPage> {
  late Future<List<VaccineBookingRecord>> _future;

  @override
  void initState() {
    super.initState();
    _future = VaccineBookingStorage.getAll();
  }

  void _reload() {
    setState(() {
      _future = VaccineBookingStorage.getAll();
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

  Future<void> _confirmDelete(VaccineBookingRecord record) async {
    await showConfirmDialog(
      context: context,
      icon: Icons.delete_outline_rounded,
      title: 'ลบรายการจองนี้',
      message: 'ต้องการลบรายการจอง ${record.id} ออกจากประวัติหรือไม่?',
      confirmText: 'ลบรายการ',
      confirmColor: Colors.redAccent,
      onConfirm: () async {
        await VaccineBookingStorage.remove(record.id);
        _reload();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarMainApp(
        title: 'ประวัติการจองฉีดวัคซีน',
        onBack: () => Navigator.pop(context),
      ),
      body: FutureBuilder<List<VaccineBookingRecord>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          final bookings = snapshot.data ?? [];
          if (bookings.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.event_busy_outlined,
                      size: 46,
                      color: AppColors.greyscale_300,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'ยังไม่มีประวัติการจองฉีดวัคซีน',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.greyscale_400,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton(
                      onPressed:
                          () => Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const VaccinePage(),
                            ),
                          ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('จองฉีดวัคซีนตอนนี้'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final record = bookings[index];
              return _HistoryCard(
                record: record,
                dateLabel: _formatDate(record.date),
                onTap:
                    () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (_) => VaccineBookingDetailPage(record: record),
                      ),
                    ),
                onDelete: () => _confirmDelete(record),
              );
            },
          );
        },
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.record,
    required this.dateLabel,
    required this.onTap,
    required this.onDelete,
  });

  final VaccineBookingRecord record;
  final String dateLabel;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.greyscale_200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    record.id,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: AppColors.greyscale_900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.greenlight.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    record.status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primarySecondary,
                    ),
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 19,
                    color: Colors.redAccent,
                  ),
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 13,
                  color: AppColors.greyscale_400,
                ),
                const SizedBox(width: 5),
                Text(
                  '$dateLabel • ${record.timeSlot}',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.greyscale_400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 13,
                  color: AppColors.greyscale_400,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    record.pointName,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.greyscale_400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.pets, size: 13, color: AppColors.greyscale_400),
                const SizedBox(width: 5),
                Text(
                  '${record.pets.length} ตัว'
                  '${record.comboVaccines.isNotEmpty ? ' • วัคซีนเสริม ${record.comboVaccines.length} รายการ' : ''}',
                  style: TextStyle(
                    fontSize: 12.5,
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
}

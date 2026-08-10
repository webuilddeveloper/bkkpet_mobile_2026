import 'package:bkkpet/blank_page/appbar.dart';
import 'package:bkkpet/pages/sterilization/sterilization_booking_detail_page.dart';
import 'package:bkkpet/pages/sterilization/sterilization_booking_model.dart';
import 'package:bkkpet/pages/sterilization/sterilization_booking_storage.dart';
import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';

/// ================================================================
/// ประวัติการจองทำหมันทั้งหมดของฉัน
/// ดึงข้อมูลจาก SterilizationBookingStorage (local storage)
/// ================================================================
class SterilizationBookingHistoryPage extends StatefulWidget {
  const SterilizationBookingHistoryPage({super.key});

  @override
  State<SterilizationBookingHistoryPage> createState() =>
      _SterilizationBookingHistoryPageState();
}

class _SterilizationBookingHistoryPageState
    extends State<SterilizationBookingHistoryPage> {
  late Future<List<SterilizationBookingRecord>> _future;

  @override
  void initState() {
    super.initState();
    _future = SterilizationBookingStorage.getAll();
  }

  void _reload() {
    setState(() {
      _future = SterilizationBookingStorage.getAll();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyscale_25,
      appBar: AppBarMainApp(
        title: 'ประวัติการจองทำหมัน',
        onBack: () => Navigator.pop(context),
      ),
      body: FutureBuilder<List<SterilizationBookingRecord>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final records = snapshot.data ?? [];

          if (records.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.event_busy_outlined,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'ยังไม่มีประวัติการจองทำหมัน',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.greyscale_900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'เมื่อคุณจองคิวทำหมัน รายการจะแสดงที่นี่',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.greyscale_400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => _reload(),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _BookingHistoryTile(
                    record: record,
                    formatDate: _formatDate,
                    statusColor: _statusColor(record.status),
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (_) => SterilizationBookingDetailPage(
                                record: record,
                              ),
                        ),
                      );
                      _reload();
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _BookingHistoryTile extends StatelessWidget {
  const _BookingHistoryTile({
    required this.record,
    required this.formatDate,
    required this.statusColor,
    required this.onTap,
  });

  final SterilizationBookingRecord record;
  final String Function(DateTime) formatDate;
  final Color statusColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.greyscale_200),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Icon(
                record.species == 'แมว' ? Icons.pets : Icons.pets_outlined,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          record.petName,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.5,
                            color: AppColors.greyscale_900,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          record.status,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${formatDate(record.date)} • ${record.timeSlot}',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.greyscale_400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    record.pointName,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.greyscale_400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'รหัสการจอง ${record.id}',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.greyscale_300,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.greyscale_300,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:bkkpet/blank_page/appbar.dart';
import 'package:bkkpet/blank_page/custom_dialog.dart';
import 'package:bkkpet/pages/consult/consult_booking_detail_page.dart';
import 'package:bkkpet/pages/consult/consult_booking_model.dart';
import 'package:bkkpet/pages/consult/consult_booking_storage.dart';
import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';

class ConsultBookingHistoryPage extends StatefulWidget {
  const ConsultBookingHistoryPage({super.key});

  @override
  State<ConsultBookingHistoryPage> createState() =>
      _ConsultBookingHistoryPageState();
}

class _ConsultBookingHistoryPageState extends State<ConsultBookingHistoryPage> {
  late Future<List<ConsultBookingRecord>> _future;

  @override
  void initState() {
    super.initState();
    _future = ConsultBookingStorage.getAll();
  }

  void _reload() {
    setState(() => _future = ConsultBookingStorage.getAll());
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

  Future<void> _delete(ConsultBookingRecord record) async {
    await showConfirmDialog(
      context: context,
      icon: Icons.delete_outline_rounded,
      title: 'ลบนัดหมายนี้',
      message: 'ต้องการลบรายการนัดหมาย ${record.id} หรือไม่?',
      confirmText: 'ลบรายการ',
      confirmColor: Colors.redAccent,
      onConfirm: () async {
        await ConsultBookingStorage.remove(record.id);
        _reload();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyscale_25,
      appBar: AppBarMainApp(
        title: 'นัดหมายของฉัน',
        onBack: () => Navigator.pop(context),
      ),
      body: FutureBuilder<List<ConsultBookingRecord>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data ?? <ConsultBookingRecord>[];
          if (items.isEmpty) {
            return Center(
              child: Text(
                'ยังไม่มีนัดหมายปรึกษา',
                style: TextStyle(color: AppColors.greyscale_400),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final record = items[index];
              return InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ConsultBookingDetailPage(record: record),
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.greyscale_200),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(
                          record.doctorImage,
                          width: 56,
                          height: 56,
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
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.greyscale_900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_formatDate(record.bookingDate)} • ${record.timeSlot}',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: AppColors.greyscale_400,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              record.status,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _delete(record),
                        icon: const Icon(Icons.delete_outline_rounded),
                        color: AppColors.greyscale_400,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

import 'dart:io';

import 'package:bkkpet/blank_page/appbar.dart';
import 'package:bkkpet/blank_page/incident_input_widgets.dart';
import 'package:bkkpet/pages/report_incident/report_incident_model.dart';
import 'package:bkkpet/pages/report_incident/report_incident_storage.dart';
import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';

class ReportIncidentDetailPage extends StatefulWidget {
  const ReportIncidentDetailPage({super.key, required this.reportId});

  final String reportId;

  @override
  State<ReportIncidentDetailPage> createState() =>
      _ReportIncidentDetailPageState();
}

class _ReportIncidentDetailPageState extends State<ReportIncidentDetailPage> {
  late Future<ReportIncidentRecord?> _future;

  @override
  void initState() {
    super.initState();
    _future = ReportIncidentStorage.getById(widget.reportId);
  }

  Future<void> _reload() async {
    setState(() {
      _future = ReportIncidentStorage.getById(widget.reportId);
    });
  }

  String _formatDateTime(DateTime dateTime) {
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
    final buddhistYear = dateTime.year + 543;
    return '${dateTime.day} ${months[dateTime.month - 1]} $buddhistYear ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Color _statusColor(String status) {
    switch (status) {
      case ReportIncidentStatus.resolved:
        return AppColors.primary;
      case ReportIncidentStatus.inProgress:
      case ReportIncidentStatus.onSite:
        return const Color(0xffF59E0B);
      case ReportIncidentStatus.reviewing:
      case ReportIncidentStatus.received:
        return const Color(0xff3B82F6);
      default:
        return AppColors.secondary;
    }
  }

  Future<void> _openUpdateSheet(ReportIncidentRecord report) async {
    final noteCtrl = TextEditingController();
    String selectedStatus = report.status;
    final options =
        ReportIncidentStatus.all
            .where(
              (status) =>
                  ReportIncidentStatus.all.indexOf(status) >=
                  ReportIncidentStatus.all.indexOf(report.status),
            )
            .toList();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            ),
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.greyscale_200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'อัปเดตผลการดำเนินงาน',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.greyscale_900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedStatus,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.greyscale_25,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items:
                        options
                            .map(
                              (status) => DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value != null) selectedStatus = value;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: noteCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'ใส่รายละเอียดผลการดำเนินงาน',
                      filled: true,
                      fillColor: AppColors.greyscale_25,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        final note = noteCtrl.text.trim();
                        await ReportIncidentStorage.appendUpdate(
                          report.id,
                          ReportIncidentUpdate(
                            status: selectedStatus,
                            title: 'อัปเดตสถานะ',
                            message:
                                note.isEmpty
                                    ? 'เจ้าหน้าที่อัปเดตสถานะเป็น $selectedStatus'
                                    : note,
                            timestampIso: DateTime.now().toIso8601String(),
                            by: 'เจ้าหน้าที่',
                          ),
                        );
                        if (sheetContext.mounted) {
                          Navigator.pop(sheetContext);
                        }
                        await _reload();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('บันทึกอัปเดต'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: TextStyle(fontSize: 12.5, color: AppColors.greyscale_400),
            ),
          ),
          const SizedBox(width: 8),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarMainApp(
        title: 'รายละเอียดเรื่องแจ้ง',
        onBack: () => Navigator.pop(context),
      ),
      body: FutureBuilder<ReportIncidentRecord?>(
        future: _future,
        builder: (context, snapshot) {
          final report = snapshot.data;
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (report == null) {
            return Center(
              child: Text(
                'ไม่พบรายการเรื่องแจ้ง',
                style: TextStyle(color: AppColors.greyscale_400),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              const IncidentNoticeBanner(
                title: 'หมายเหตุ',
                message:
                    'หน้านี้แสดงสถานะล่าสุด สื่อที่แนบ และไทม์ไลน์การอัปเดตของเรื่องแจ้ง',
                icon: Icons.timeline_rounded,
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.greyscale_200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                report.incidentType,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.greyscale_900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'แจ้งเมื่อ ${_formatDateTime(report.createdAt)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.greyscale_400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor(
                              report.status,
                            ).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            report.status,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _statusColor(report.status),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _infoRow('ระดับความเร่งด่วน', report.urgency),
                    _infoRow('พิกัด', report.coordinateText),
                    _infoRow(
                      'ความแม่นยำ',
                      '${report.locationAccuracy.toStringAsFixed(0)} เมตร',
                    ),
                    _infoRow(
                      'รายละเอียด',
                      report.detail.isEmpty ? '-' : report.detail,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.greyscale_200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'สื่อที่แนบ',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.greyscale_900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (report.mediaPath.isEmpty)
                      Text(
                        'ไม่มีสื่อแนบ',
                        style: TextStyle(color: AppColors.greyscale_400),
                      )
                    else if (report.hasVideo)
                      Container(
                        height: 140,
                        decoration: BoxDecoration(
                          color: AppColors.greyscale_25,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.greyscale_200),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.videocam_rounded,
                              size: 36,
                              color: AppColors.primary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              report.mediaName.isEmpty
                                  ? 'วิดีโอที่แนบไว้'
                                  : report.mediaName,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.greyscale_800,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(
                          File(report.mediaPath),
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.greyscale_200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'ไทม์ไลน์สถานะ',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.greyscale_900,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _openUpdateSheet(report),
                          icon: const Icon(Icons.edit_note_rounded),
                          label: const Text('อัปเดต'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    for (final update in report.updates)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: _statusColor(
                                  update.status,
                                ).withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                update.by == 'เจ้าหน้าที่'
                                    ? Icons.badge_rounded
                                    : Icons.receipt_long_rounded,
                                size: 18,
                                color: _statusColor(update.status),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    update.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.greyscale_900,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    update.message,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: AppColors.greyscale_400,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${update.by} · ${_formatDateTime(update.timestamp)}',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: AppColors.greyscale_300,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

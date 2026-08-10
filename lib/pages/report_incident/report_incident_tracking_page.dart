import 'package:bkkpet/blank_page/appbar.dart';
import 'package:bkkpet/blank_page/app_loading.dart';
import 'package:bkkpet/blank_page/incident_input_widgets.dart';
import 'package:bkkpet/pages/report_incident/report_incident_detail_page.dart';
import 'package:bkkpet/pages/report_incident/report_incident_model.dart';
import 'package:bkkpet/pages/report_incident/report_incident_storage.dart';
import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';

class ReportIncidentTrackingPage extends StatefulWidget {
  const ReportIncidentTrackingPage({super.key});

  @override
  State<ReportIncidentTrackingPage> createState() =>
      _ReportIncidentTrackingPageState();
}

class _ReportIncidentTrackingPageState
    extends State<ReportIncidentTrackingPage> {
  late Future<List<ReportIncidentRecord>> _future;
  String _filter = 'ทั้งหมด';

  @override
  void initState() {
    super.initState();
    _future = ReportIncidentStorage.getAll();
  }

  Future<void> _reload() async {
    setState(() {
      _future = ReportIncidentStorage.getAll();
    });
    await _future;
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
    return '${dateTime.day} ${months[dateTime.month - 1]} $buddhistYear';
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

  List<ReportIncidentRecord> _filteredReports(List<ReportIncidentRecord> list) {
    if (_filter == 'ทั้งหมด') return list;
    return list.where((r) => r.status == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarMainApp(
        title: 'ติดตามสถานะเรื่องแจ้ง',
        onBack: () => Navigator.pop(context),
      ),
      body: AppRefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<List<ReportIncidentRecord>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: const [
                  SizedBox(height: 120),
                  Center(child: AppLoadingIndicator()),
                ],
              );
            }

            final reports = _filteredReports(
              snapshot.data ?? <ReportIncidentRecord>[],
            );
            final counts = <String, int>{};
            for (final status in ReportIncidentStatus.all) {
              counts[status] = 0;
            }
            for (final report in snapshot.data ?? <ReportIncidentRecord>[]) {
              counts[report.status] = (counts[report.status] ?? 0) + 1;
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const IncidentNoticeBanner(
                  title: 'หมายเหตุ',
                  message:
                      'แตะรายการเพื่อเปิดดูรายละเอียดและเช็กความคืบหน้าของเรื่องที่แจ้งไว้',
                  icon: Icons.history_rounded,
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'ทั้งหมด',
                        selected: _filter == 'ทั้งหมด',
                        onTap: () => setState(() => _filter = 'ทั้งหมด'),
                      ),
                      const SizedBox(width: 8),
                      for (final status in ReportIncidentStatus.all) ...[
                        _FilterChip(
                          label: status,
                          count: counts[status] ?? 0,
                          selected: _filter == status,
                          onTap: () => setState(() => _filter = status),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (reports.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.greyscale_200),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.inbox_rounded,
                          size: 42,
                          color: AppColors.greyscale_300,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'ยังไม่มีรายการเรื่องแจ้ง',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.greyscale_900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'เมื่อกดส่งเรื่อง รายการจะมาแสดงที่หน้านี้',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.greyscale_400,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  for (final report in reports)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => ReportIncidentDetailPage(
                                      reportId: report.id,
                                    ),
                              ),
                            ).then((_) => _reload()),
                        child: Container(
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: _statusColor(
                                        report.status,
                                      ).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      report.hasVideo
                                          ? Icons.videocam_rounded
                                          : Icons.image_rounded,
                                      color: _statusColor(report.status),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          report.incidentType,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.greyscale_900,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
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
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: _statusColor(report.status),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                report.detail.isEmpty
                                    ? 'ไม่มีรายละเอียดเพิ่มเติม'
                                    : report.detail,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: AppColors.greyscale_400,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      report.coordinateText,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: AppColors.greyscale_300,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    color: AppColors.greyscale_300,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.count,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.greyscale_200,
          ),
        ),
        child: Text(
          count == null ? label : '$label ($count)',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AppColors.greyscale_800,
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'report_incident_model.dart';

class ReportIncidentStorage {
  ReportIncidentStorage._();

  static const _storageKey = 'incident_reports_v1';

  static Future<List<ReportIncidentRecord>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? <String>[];
    final reports = <ReportIncidentRecord>[];
    for (final item in raw) {
      try {
        reports.add(
          ReportIncidentRecord.fromJson(
            jsonDecode(item) as Map<String, dynamic>,
          ),
        );
      } catch (_) {
        // ข้ามรายการที่อ่านไม่ได้
      }
    }
    reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return reports;
  }

  static Future<ReportIncidentRecord?> getById(String id) async {
    final all = await getAll();
    for (final report in all) {
      if (report.id == id) return report;
    }
    return null;
  }

  static Future<void> add(ReportIncidentRecord report) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? <String>[];
    final updates =
        report.updates.isEmpty
            ? [
              ReportIncidentUpdate(
                status: report.status,
                title: 'ส่งเรื่องสำเร็จ',
                message: 'ระบบได้รับข้อมูลการแจ้งเหตุเรียบร้อยแล้ว',
                timestampIso: report.createdAtIso,
              ),
            ]
            : report.updates;
    final record = report.copyWith(updates: updates);
    raw.add(jsonEncode(record.toJson()));
    await prefs.setStringList(_storageKey, raw);
  }

  static Future<void> update(ReportIncidentRecord report) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? <String>[];
    final updated = <String>[];
    for (final item in raw) {
      try {
        final map = jsonDecode(item) as Map<String, dynamic>;
        if (map['id'] == report.id) {
          updated.add(jsonEncode(report.toJson()));
        } else {
          updated.add(item);
        }
      } catch (_) {
        updated.add(item);
      }
    }
    await prefs.setStringList(_storageKey, updated);
  }

  static Future<void> appendUpdate(
    String id,
    ReportIncidentUpdate update,
  ) async {
    final report = await getById(id);
    if (report == null) return;
    final updated = report.copyWith(
      status: update.status,
      updates: [...report.updates, update],
    );
    await updateReport(updated);
  }

  static Future<void> updateReport(ReportIncidentRecord report) async {
    await update(report);
  }

  static Future<void> remove(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? <String>[];
    raw.removeWhere((item) {
      try {
        final map = jsonDecode(item) as Map<String, dynamic>;
        return map['id'] == id;
      } catch (_) {
        return false;
      }
    });
    await prefs.setStringList(_storageKey, raw);
  }
}

import 'dart:convert';

import 'package:bkkpet/mock_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'lost_found_model.dart';

/// ================================================================
/// เก็บ/อ่าน/ลบ รายงานสัตว์หาย-พบสัตว์ แบบ local (SharedPreferences)
/// ================================================================
class LostFoundStorage {
  LostFoundStorage._();

  static const _storageKey = 'lost_found_reports_v1';

  static const Map<String, ({String path, String name})> _seedMediaById = {
    'LF100001': (path: 'assets/images/dog01.jpeg', name: 'dog01.jpeg'),
    'LF100002': (path: 'assets/images/cat07.jpeg', name: 'cat07.jpeg'),
    'LF100003': (path: 'assets/images/dog04.jpg', name: 'dog04.jpg'),
    'LF100004': (path: 'assets/images/cat04.jpeg', name: 'cat04.jpeg'),
    'LF100005': (path: 'assets/images/dog02.jpeg', name: 'dog02.jpeg'),
  };

  static List<LostFoundReport> _seedReports() {
    final now = DateTime.now();
    return mockLostPetReports.map((json) {
      final dateOffset = Duration(
        days: (json['daysAgo'] as num?)?.toInt() ?? 0,
        hours: (json['hoursAgo'] as num?)?.toInt() ?? 0,
      );
      final createdOffset = Duration(
        hours: (json['createdHoursAgo'] as num?)?.toInt() ?? 0,
      );

      return LostFoundReport(
        id: json['id'] as String,
        type: json['type'] as String? ?? LostFoundReportType.lost,
        species: json['species'] as String? ?? '',
        petName: json['petName'] as String? ?? '',
        mediaPath: json['mediaPath'] as String? ?? '',
        mediaName: json['mediaName'] as String? ?? '',
        mediaKind: json['mediaKind'] as String? ?? LostFoundMediaKind.image,
        colorDescription: json['colorDescription'] as String? ?? '',
        location: json['location'] as String? ?? '',
        dateIso: now.subtract(dateOffset).toIso8601String(),
        chipId: json['chipId'] as String? ?? '',
        contactName: json['contactName'] as String? ?? '',
        contactPhone: json['contactPhone'] as String? ?? '',
        note: json['note'] as String? ?? '',
        createdAtIso: now.subtract(createdOffset).toIso8601String(),
      );
    }).toList();
  }

  static Future<List<LostFoundReport>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? <String>[];
    if (raw.isEmpty) {
      final seed = _seedReports();
      await prefs.setStringList(
        _storageKey,
        seed.map((item) => jsonEncode(item.toJson())).toList(),
      );
      return seed;
    }
    final reports = <LostFoundReport>[];
    var needsRewrite = false;
    for (final item in raw) {
      try {
        final map = jsonDecode(item) as Map<String, dynamic>;
        var report = LostFoundReport.fromJson(map);
        if (report.mediaPath.isEmpty && _seedMediaById.containsKey(report.id)) {
          final media = _seedMediaById[report.id]!;
          report = LostFoundReport(
            id: report.id,
            type: report.type,
            species: report.species,
            petName: report.petName,
            colorDescription: report.colorDescription,
            location: report.location,
            dateIso: report.dateIso,
            chipId: report.chipId,
            contactName: report.contactName,
            contactPhone: report.contactPhone,
            note: report.note,
            mediaPath: media.path,
            mediaName: media.name,
            mediaKind: LostFoundMediaKind.image,
            resolved: report.resolved,
            createdAtIso: report.createdAtIso,
          );
          needsRewrite = true;
        }
        reports.add(report);
      } catch (_) {
        // ข้ามรายการที่ข้อมูลเสียหาย
      }
    }
    reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (needsRewrite) {
      await prefs.setStringList(
        _storageKey,
        reports.map((item) => jsonEncode(item.toJson())).toList(),
      );
    }
    return reports;
  }

  static Future<void> add(LostFoundReport report) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? <String>[];
    raw.add(jsonEncode(report.toJson()));
    await prefs.setStringList(_storageKey, raw);
  }

  /// อัปเดตสถานะ "จบเรื่องแล้ว" ของประกาศ 1 รายการ
  static Future<void> setResolved(String id, bool resolved) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? <String>[];
    final updated = <String>[];
    for (final item in raw) {
      try {
        final map = jsonDecode(item) as Map<String, dynamic>;
        if (map['id'] == id) {
          final report = LostFoundReport.fromJson(
            map,
          ).copyWith(resolved: resolved);
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

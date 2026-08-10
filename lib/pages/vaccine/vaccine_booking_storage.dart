import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'vaccine_booking_model.dart';

/// ================================================================
/// เก็บ/อ่าน/ลบ ข้อมูลการจองฉีดวัคซีนแบบ local (SharedPreferences)
/// หมายเหตุ: เป็นการเก็บข้อมูลไว้ในเครื่องผู้ใช้ชั่วคราวก่อนต่อ API จริง
/// ================================================================
class VaccineBookingStorage {
  VaccineBookingStorage._();

  static const _storageKey = 'vaccine_bookings_v1';

  /// ดึงรายการจองทั้งหมด เรียงจากล่าสุดไปเก่าสุด
  static Future<List<VaccineBookingRecord>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? <String>[];
    final records = <VaccineBookingRecord>[];
    for (final item in raw) {
      try {
        records.add(
          VaccineBookingRecord.fromJson(
            jsonDecode(item) as Map<String, dynamic>,
          ),
        );
      } catch (_) {
        // ข้ามรายการที่ข้อมูลเสียหาย
      }
    }
    records.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return records;
  }

  /// บันทึกการจองใหม่ 1 รายการ
  static Future<void> add(VaccineBookingRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? <String>[];
    raw.add(jsonEncode(record.toJson()));
    await prefs.setStringList(_storageKey, raw);
  }

  /// ดึงรายการจองตาม id
  static Future<VaccineBookingRecord?> getById(String id) async {
    final all = await getAll();
    for (final record in all) {
      if (record.id == id) return record;
    }
    return null;
  }

  /// ลบการจอง 1 รายการ ตามหมายเลขอ้างอิง
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

  /// ล้างประวัติการจองทั้งหมด
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}

import 'dart:convert';

import 'package:bkkpet/pages/sterilization/sterilization_booking_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ================================================================
/// เก็บประวัติการจองทำหมันไว้ในเครื่อง (SharedPreferences)
/// รูปแบบเดียวกับ VaccineBookingStorage เพื่อให้ดูแลง่าย
/// ================================================================
class SterilizationBookingStorage {
  static const _storageKey = 'sterilization_booking_records';

  /// เพิ่มรายการจองใหม่ไว้บนสุดของประวัติ
  static Future<void> add(SterilizationBookingRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getAll();
    list.insert(0, record);
    await _saveAll(prefs, list);
  }

  /// ดึงประวัติการจองทั้งหมด เรียงจากล่าสุดไปเก่าสุด
  static Future<List<SterilizationBookingRecord>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? [];
    return raw
        .map(
          (s) => SterilizationBookingRecord.fromJson(
            jsonDecode(s) as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  /// ดึงรายการจองตาม id (ใช้ในหน้ารายละเอียด)
  static Future<SterilizationBookingRecord?> getById(String id) async {
    final list = await getAll();
    for (final r in list) {
      if (r.id == id) return r;
    }
    return null;
  }

  /// ลบรายการจอง (เช่น กรณียกเลิกนัดหมาย)
  static Future<void> remove(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getAll();
    list.removeWhere((r) => r.id == id);
    await _saveAll(prefs, list);
  }

  /// อัปเดตสถานะของรายการจอง เช่น 'รอดำเนินการ' -> 'เสร็จสิ้น' / 'ยกเลิกแล้ว'
  static Future<void> updateStatus(String id, String status) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getAll();
    final index = list.indexWhere((r) => r.id == id);
    if (index == -1) return;

    final old = list[index];
    list[index] = SterilizationBookingRecord(
      id: old.id,
      petId: old.petId,
      petName: old.petName,
      species: old.species,
      gender: old.gender,
      age: old.age,
      weight: old.weight,
      district: old.district,
      pointName: old.pointName,
      pointAddress: old.pointAddress,
      pointType: old.pointType,
      dateIso: old.dateIso,
      timeSlot: old.timeSlot,
      fasted: old.fasted,
      healthChecked: old.healthChecked,
      vaccinated: old.vaccinated,
      ownerName: old.ownerName,
      ownerPhone: old.ownerPhone,
      note: old.note,
      createdAtIso: old.createdAtIso,
      status: status,
    );
    await _saveAll(prefs, list);
  }

  static Future<void> _saveAll(
    SharedPreferences prefs,
    List<SterilizationBookingRecord> list,
  ) async {
    final raw = list.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList(_storageKey, raw);
  }
}

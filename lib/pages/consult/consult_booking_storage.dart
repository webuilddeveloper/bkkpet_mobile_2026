import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'consult_booking_model.dart';

class ConsultBookingStorage {
  ConsultBookingStorage._();

  static const _storageKey = 'consult_booking_records_v1';

  static Future<List<ConsultBookingRecord>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? <String>[];
    final items = <ConsultBookingRecord>[];
    for (final value in raw) {
      try {
        items.add(
          ConsultBookingRecord.fromJson(
            jsonDecode(value) as Map<String, dynamic>,
          ),
        );
      } catch (_) {
        // skip invalid
      }
    }
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  static Future<ConsultBookingRecord?> getById(String id) async {
    final items = await getAll();
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  static Future<void> add(ConsultBookingRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await getAll();
    items.insert(0, record);
    await _saveAll(prefs, items);
  }

  static Future<void> updateStatus(String id, String status) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await getAll();
    final index = items.indexWhere((item) => item.id == id);
    if (index == -1) return;
    final old = items[index];
    items[index] = ConsultBookingRecord(
      id: old.id,
      doctorId: old.doctorId,
      doctorName: old.doctorName,
      doctorImage: old.doctorImage,
      specialty: old.specialty,
      clinicName: old.clinicName,
      consultType: old.consultType,
      petId: old.petId,
      petName: old.petName,
      petSpecies: old.petSpecies,
      bookingDateIso: old.bookingDateIso,
      timeSlot: old.timeSlot,
      note: old.note,
      createdAtIso: old.createdAtIso,
      status: status,
    );
    await _saveAll(prefs, items);
  }

  static Future<void> remove(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await getAll();
    items.removeWhere((item) => item.id == id);
    await _saveAll(prefs, items);
  }

  static Future<void> _saveAll(
    SharedPreferences prefs,
    List<ConsultBookingRecord> items,
  ) async {
    await prefs.setStringList(
      _storageKey,
      items.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }
}

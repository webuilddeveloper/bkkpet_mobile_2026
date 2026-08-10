import 'dart:convert';

import 'package:bkkpet/pages/adoption/adoption_models.dart';
import 'package:bkkpet/services/mock_user_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdoptionStorageKeys {
  static const String adoptedRecords = 'adoption_adopted_records';
  static const String applications = 'adoption_applications';
}

class AdoptionStorage {
  static Future<List<AdoptionAdoptedRecord>> loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AdoptionStorageKeys.adoptedRecords);
    if (raw == null || raw.trim().isEmpty) {
      final seeded = _seedRecords();
      await saveRecords(seeded);
      return seeded;
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map(
          (item) => AdoptionAdoptedRecord.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  static Future<void> saveRecords(List<AdoptionAdoptedRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(records.map((e) => e.toJson()).toList());
    await prefs.setString(AdoptionStorageKeys.adoptedRecords, raw);
  }

  static Future<List<AdoptionApplication>> loadApplications() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AdoptionStorageKeys.applications);
    if (raw == null || raw.trim().isEmpty) {
      return <AdoptionApplication>[];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map(
          (item) => AdoptionApplication.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  static Future<void> saveApplications(List<AdoptionApplication> apps) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(apps.map((e) => e.toJson()).toList());
    await prefs.setString(AdoptionStorageKeys.applications, raw);
  }

  static Future<void> upsertApplication(AdoptionApplication application) async {
    final apps = await loadApplications();
    final index = apps.indexWhere((item) => item.pet.id == application.pet.id);
    if (index >= 0) {
      apps[index] = application;
    } else {
      apps.insert(0, application);
    }
    await saveApplications(apps);
  }

  static Future<void> upsertFromApplication(
    AdoptionApplication application,
  ) async {
    await upsertApplication(application);
    final records = await loadRecords();
    final existingIndex = records.indexWhere(
      (record) => record.pet.id == application.pet.id,
    );

    final record = AdoptionAdoptedRecord(
      id: application.pet.id,
      pet: application.pet,
      approvedAt: application.appointmentDate ?? DateTime.now(),
      statusText: application.status.label,
      lastUpdateLabel: 'บันทึกจากสถานะ ${application.status.label}',
      updates:
          existingIndex >= 0
              ? records[existingIndex].updates
              : <AdoptionFollowUpEntry>[],
    );

    if (existingIndex >= 0) {
      records[existingIndex] = record;
    } else {
      records.insert(0, record);
    }

    await saveRecords(records);
  }

  static Future<void> appendUpdate({
    required String recordId,
    required String condition,
    required String note,
    String mediaPath = '',
    String mediaName = '',
    String mediaKind = '',
  }) async {
    final records = await loadRecords();
    final index = records.indexWhere((record) => record.id == recordId);
    if (index < 0) return;

    final updated = records[index];
    final newEntry = AdoptionFollowUpEntry(
      createdAt: DateTime.now(),
      condition: condition,
      note: note,
      mediaPath: mediaPath,
      mediaName: mediaName,
      mediaKind: mediaKind,
    );
    records[index] = AdoptionAdoptedRecord(
      id: updated.id,
      pet: updated.pet,
      approvedAt: updated.approvedAt,
      statusText: updated.statusText,
      lastUpdateLabel:
          '${_thaiDate(newEntry.createdAt)} · ${newEntry.condition}',
      updates: [newEntry, ...updated.updates],
    );
    await saveRecords(records);
  }

  static List<AdoptionAdoptedRecord> _seedRecords() {
    final now = DateTime.now();
    return [
      AdoptionAdoptedRecord(
        id: 'adopt-001',
        pet: AdoptionPet(
          id: MockUserStore.pets[0].id,
          name: MockUserStore.pets[0].name,
          species: MockUserStore.pets[0].species,
          imageAsset: MockUserStore.pets[0].image,
          breed: MockUserStore.pets[0].breed,
          gender: MockUserStore.pets[0].gender,
          ageLabel: '2 ปี',
          ageGroup: 'โตเต็มวัย',
          size: 'กลาง',
          temperament: const ['ขี้เล่น', 'เป็นมิตร'],
          district: 'บางกะปิ',
          history: 'รับเลี้ยงจากศูนย์พักพิงและกำลังอยู่ในช่วงปรับตัว',
          sterilized: true,
          vaccinated: true,
        ),
        approvedAt: now.subtract(const Duration(days: 21)),
        statusText: 'รับเลี้ยงสำเร็จ',
        lastUpdateLabel: 'อัปเดตล่าสุดเมื่อ 3 วันก่อน',
        updates: [
          AdoptionFollowUpEntry(
            createdAt: now.subtract(const Duration(days: 3)),
            condition: 'สุขภาพดี',
            note: 'กินอาหารได้ดี ขี้อ้อนมากขึ้น',
          ),
        ],
      ),
      AdoptionAdoptedRecord(
        id: 'adopt-002',
        pet: AdoptionPet(
          id: MockUserStore.pets[1].id,
          name: MockUserStore.pets[1].name,
          species: MockUserStore.pets[1].species,
          imageAsset: MockUserStore.pets[1].image,
          breed: MockUserStore.pets[1].breed,
          gender: MockUserStore.pets[1].gender,
          ageLabel: '1 ปี',
          ageGroup: 'โตเต็มวัย',
          size: 'เล็ก',
          temperament: const ['ขี้อ้อน', 'ขี้เล่น'],
          district: 'จตุจักร',
          history: 'รับเลี้ยงและดูแลต่อจากเครือข่ายอุปถัมภ์สัตว์',
          sterilized: true,
          vaccinated: true,
        ),
        approvedAt: now.subtract(const Duration(days: 52)),
        statusText: 'รับเลี้ยงสำเร็จ',
        lastUpdateLabel: 'อัปเดตล่าสุดเมื่อ 12 วันก่อน',
        updates: [
          AdoptionFollowUpEntry(
            createdAt: now.subtract(const Duration(days: 12)),
            condition: 'แข็งแรงดี',
            note: 'เริ่มคุ้นบ้านใหม่และทานอาหารตามปกติ',
          ),
        ],
      ),
    ];
  }

  static String _thaiDate(DateTime date) {
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
    return '${date.day} ${months[date.month - 1]} ${date.year + 543}';
  }
}

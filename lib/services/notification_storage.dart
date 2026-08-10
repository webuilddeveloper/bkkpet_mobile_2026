import 'dart:convert';

import 'package:bkkpet/pages/sterilization/sterilization_booking_model.dart';
import 'package:bkkpet/pages/vaccine/vaccine_booking_model.dart';
import 'package:bkkpet/services/mock_user_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationRecord {
  const NotificationRecord({
    required this.id,
    required this.kind,
    required this.title,
    required this.message,
    required this.createdAtIso,
    required this.isRead,
    this.petImage,
    this.petName,
    this.petGender,
    this.petSpecies,
    this.petId,
    this.relatedId,
    this.serviceLabel,
    this.scheduleDateIso,
    this.scheduleTime,
    this.locationName,
    this.locationAddress,
  });

  final String id;
  final String kind;
  final String title;
  final String message;
  final String createdAtIso;
  final bool isRead;
  final String? petImage;
  final String? petName;
  final String? petGender;
  final String? petSpecies;
  final String? petId;
  final String? relatedId;
  final String? serviceLabel;
  final String? scheduleDateIso;
  final String? scheduleTime;
  final String? locationName;
  final String? locationAddress;

  DateTime get createdAt => DateTime.parse(createdAtIso);
  DateTime? get scheduleDate =>
      scheduleDateIso == null ? null : DateTime.tryParse(scheduleDateIso!);

  NotificationRecord copyWith({
    String? id,
    String? kind,
    String? title,
    String? message,
    String? createdAtIso,
    bool? isRead,
    String? petImage,
    String? petName,
    String? petGender,
    String? petSpecies,
    String? petId,
    String? relatedId,
    String? serviceLabel,
    String? scheduleDateIso,
    String? scheduleTime,
    String? locationName,
    String? locationAddress,
  }) {
    return NotificationRecord(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAtIso: createdAtIso ?? this.createdAtIso,
      isRead: isRead ?? this.isRead,
      petImage: petImage ?? this.petImage,
      petName: petName ?? this.petName,
      petGender: petGender ?? this.petGender,
      petSpecies: petSpecies ?? this.petSpecies,
      petId: petId ?? this.petId,
      relatedId: relatedId ?? this.relatedId,
      serviceLabel: serviceLabel ?? this.serviceLabel,
      scheduleDateIso: scheduleDateIso ?? this.scheduleDateIso,
      scheduleTime: scheduleTime ?? this.scheduleTime,
      locationName: locationName ?? this.locationName,
      locationAddress: locationAddress ?? this.locationAddress,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kind,
    'title': title,
    'message': message,
    'createdAtIso': createdAtIso,
    'isRead': isRead,
    'petImage': petImage,
    'petName': petName,
    'petGender': petGender,
    'petSpecies': petSpecies,
    'petId': petId,
    'relatedId': relatedId,
    'serviceLabel': serviceLabel,
    'scheduleDateIso': scheduleDateIso,
    'scheduleTime': scheduleTime,
    'locationName': locationName,
    'locationAddress': locationAddress,
  };

  factory NotificationRecord.fromJson(Map<String, dynamic> json) {
    return NotificationRecord(
      id: json['id'] as String,
      kind: json['kind'] as String? ?? 'general',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      createdAtIso: json['createdAtIso'] as String,
      isRead: json['isRead'] as bool? ?? false,
      petImage: json['petImage'] as String?,
      petName: json['petName'] as String?,
      petGender: json['petGender'] as String?,
      petSpecies: json['petSpecies'] as String?,
      petId: json['petId'] as String?,
      relatedId: json['relatedId'] as String?,
      serviceLabel: json['serviceLabel'] as String?,
      scheduleDateIso: json['scheduleDateIso'] as String?,
      scheduleTime: json['scheduleTime'] as String?,
      locationName: json['locationName'] as String?,
      locationAddress: json['locationAddress'] as String?,
    );
  }

  static NotificationRecord registrationSuccess({
    required String petSummary,
    required int petCount,
    String? petId,
  }) {
    final now = DateTime.now();
    final firstPet = MockUserStore.findPetById(petId);
    final petImage = firstPet?.image.trim() ?? '';
    return NotificationRecord(
      id: 'reg-${now.microsecondsSinceEpoch}',
      kind: 'registration',
      title: 'จดทะเบียนสัตว์เลี้ยงสำเร็จ',
      message:
          petCount > 1
              ? 'บันทึกข้อมูลสัตว์เลี้ยง $petSummary และรายการอื่น ๆ เรียบร้อยแล้ว'
              : 'บันทึกข้อมูลสัตว์เลี้ยง $petSummary เรียบร้อยแล้ว',
      createdAtIso: now.toIso8601String(),
      isRead: false,
      petImage: petImage.isEmpty ? 'assets/icons/iconapp.png' : petImage,
      petName: petSummary,
      petGender: firstPet?.gender ?? 'ไม่ระบุ',
      petSpecies: firstPet?.species ?? 'สัตว์เลี้ยง',
      petId: petId,
      serviceLabel: 'จดทะเบียน',
    );
  }

  static NotificationRecord vaccineSuccess(VaccineBookingRecord record) {
    final now = DateTime.now();
    final selectedName =
        record.pets.isNotEmpty ? record.pets.first['name'] : null;
    final selectedId = record.pets.isNotEmpty ? record.pets.first['id'] : null;
    final pet =
        MockUserStore.findPetById(selectedId) ??
        MockUserStore.findPetByName(selectedName) ??
        (MockUserStore.pets.isNotEmpty ? MockUserStore.pets.first : null);
    final petCount = record.pets.length;
    final petLabel =
        petCount > 1 && selectedName != null && selectedName.isNotEmpty
            ? '$selectedName และอีก ${petCount - 1} ตัว'
            : (selectedName?.isNotEmpty == true
                ? selectedName!
                : 'สัตว์เลี้ยงของคุณ');
    return NotificationRecord(
      id: 'vax-${record.id}',
      kind: 'vaccine',
      title: 'จองฉีดวัคซีนสำเร็จ',
      message:
          '$petLabel ได้รับการจองคิวฉีดวัคซีนเรียบร้อยแล้วที่ ${record.pointName}',
      createdAtIso: now.toIso8601String(),
      isRead: false,
      petImage: pet?.image ?? 'assets/icons/iconapp.png',
      petName: petLabel,
      petGender: pet?.gender ?? 'ไม่ระบุ',
      petSpecies: pet?.species ?? 'สัตว์เลี้ยง',
      petId: pet?.id,
      relatedId: record.id,
      serviceLabel: 'ฉีดวัคซีน',
      scheduleDateIso: record.dateIso,
      scheduleTime: record.timeSlot,
      locationName: record.pointName,
      locationAddress: record.pointAddress,
    );
  }

  static NotificationRecord sterilizationSuccess(
    SterilizationBookingRecord record,
  ) {
    final now = DateTime.now();
    final matched =
        MockUserStore.findPetById(record.petId) ??
        MockUserStore.findPetByName(record.petName) ??
        (MockUserStore.pets.isNotEmpty ? MockUserStore.pets.first : null);
    return NotificationRecord(
      id: 'st-${record.id}',
      kind: 'sterilization',
      title: 'จองทำหมันสำเร็จ',
      message:
          '${record.petName} ได้รับการจองคิวทำหมันเรียบร้อยแล้วที่ ${record.pointName}',
      createdAtIso: now.toIso8601String(),
      isRead: false,
      petImage: matched?.image ?? 'assets/icons/iconapp.png',
      petName: record.petName,
      petGender:
          record.gender.isNotEmpty
              ? record.gender
              : matched?.gender ?? 'ไม่ระบุ',
      petSpecies: record.species,
      petId: matched?.id,
      relatedId: record.id,
      serviceLabel: 'ทำหมัน',
      scheduleDateIso: record.dateIso,
      scheduleTime: record.timeSlot,
      locationName: record.pointName,
      locationAddress: record.pointAddress,
    );
  }
}

class NotificationStorage {
  NotificationStorage._();

  static const _storageKey = 'app_notifications_v1';

  static Future<List<NotificationRecord>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? <String>[];
    final items = <NotificationRecord>[];
    for (final item in raw) {
      try {
        items.add(
          NotificationRecord.fromJson(jsonDecode(item) as Map<String, dynamic>),
        );
      } catch (_) {
        // ข้ามรายการที่อ่านไม่ได้
      }
    }
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  static Future<int> unreadCount() async {
    final items = await getAll();
    return items.where((item) => !item.isRead).length;
  }

  static Future<bool> hasUnread() async => (await unreadCount()) > 0;

  static Future<void> add(NotificationRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await getAll();
    items.removeWhere((item) => item.id == record.id);
    items.insert(0, record);
    await _saveAll(prefs, items);
  }

  static Future<void> markRead(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await getAll();
    final index = items.indexWhere((item) => item.id == id);
    if (index == -1) return;
    items[index] = items[index].copyWith(isRead: true);
    await _saveAll(prefs, items);
  }

  static Future<void> markAllRead() async {
    final prefs = await SharedPreferences.getInstance();
    final items = await getAll();
    final updated =
        items
            .map((item) => item.isRead ? item : item.copyWith(isRead: true))
            .toList();
    await _saveAll(prefs, updated);
  }

  static Future<void> remove(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await getAll();
    items.removeWhere((item) => item.id == id);
    await _saveAll(prefs, items);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  static Future<void> _saveAll(
    SharedPreferences prefs,
    List<NotificationRecord> items,
  ) async {
    final raw = items.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(_storageKey, raw);
  }
}

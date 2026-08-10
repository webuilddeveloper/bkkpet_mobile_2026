/// ================================================================
/// โมเดลข้อมูลการจองฉีดวัคซีน 1 รายการ
/// ใช้สำหรับเก็บ/อ่านจาก local storage (SharedPreferences)
/// ================================================================

class VaccineBookingRecord {
  VaccineBookingRecord({
    required this.id,
    required this.pets,
    required this.comboVaccines,
    required this.comboTotalPrice,
    required this.district,
    required this.pointName,
    required this.pointAddress,
    required this.pointType,
    required this.dateIso,
    required this.timeSlot,
    required this.ownerName,
    required this.ownerPhone,
    required this.note,
    required this.createdAtIso,
    this.status = 'จองสำเร็จ',
  });

  /// หมายเลขอ้างอิงการจอง เช่น VC123456
  final String id;

  /// รายชื่อสัตว์เลี้ยง เช่น [{'name': 'โบโบ้', 'species': 'สุนัข'}]
  final List<Map<String, String>> pets;

  /// ชื่อวัคซีนรวมเสริมที่เลือก (ถ้ามี)
  final List<String> comboVaccines;

  /// ราคาประมาณรวมของวัคซีนเสริม (บาท)
  final int comboTotalPrice;

  final String district;
  final String pointName;
  final String pointAddress;

  /// 'fixed' หรือ 'mobile'
  final String pointType;

  /// วันที่นัดหมาย เก็บเป็น ISO8601 string
  final String dateIso;
  final String timeSlot;

  final String ownerName;
  final String ownerPhone;
  final String note;

  /// เวลาที่สร้างรายการจอง เก็บเป็น ISO8601 string
  final String createdAtIso;

  final String status;

  DateTime get date => DateTime.parse(dateIso);
  DateTime get createdAt => DateTime.parse(createdAtIso);

  Map<String, dynamic> toJson() => {
        'id': id,
        'pets': pets,
        'comboVaccines': comboVaccines,
        'comboTotalPrice': comboTotalPrice,
        'district': district,
        'pointName': pointName,
        'pointAddress': pointAddress,
        'pointType': pointType,
        'dateIso': dateIso,
        'timeSlot': timeSlot,
        'ownerName': ownerName,
        'ownerPhone': ownerPhone,
        'note': note,
        'createdAtIso': createdAtIso,
        'status': status,
      };

  factory VaccineBookingRecord.fromJson(Map<String, dynamic> json) {
    return VaccineBookingRecord(
      id: json['id'] as String,
      pets: (json['pets'] as List)
          .map((e) => Map<String, String>.from(e as Map))
          .toList(),
      comboVaccines: List<String>.from(json['comboVaccines'] as List? ?? []),
      comboTotalPrice: (json['comboTotalPrice'] as num?)?.toInt() ?? 0,
      district: json['district'] as String? ?? '',
      pointName: json['pointName'] as String? ?? '',
      pointAddress: json['pointAddress'] as String? ?? '',
      pointType: json['pointType'] as String? ?? 'fixed',
      dateIso: json['dateIso'] as String,
      timeSlot: json['timeSlot'] as String? ?? '',
      ownerName: json['ownerName'] as String? ?? '',
      ownerPhone: json['ownerPhone'] as String? ?? '',
      note: json['note'] as String? ?? '',
      createdAtIso: json['createdAtIso'] as String,
      status: json['status'] as String? ?? 'จองสำเร็จ',
    );
  }
}

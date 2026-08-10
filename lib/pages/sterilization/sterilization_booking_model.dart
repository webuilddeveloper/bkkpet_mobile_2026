/// ================================================================
/// โมเดลข้อมูลการจองทำหมัน
/// ================================================================
class SterilizationBookingRecord {
  SterilizationBookingRecord({
    required this.id,
    required this.petName,
    required this.species,
    required this.gender,
    required this.age,
    required this.weight,
    required this.district,
    required this.pointName,
    required this.pointAddress,
    required this.pointType, // 'fixed' หรือ 'mobile'
    required this.dateIso,
    required this.timeSlot,
    required this.fasted,
    required this.healthChecked,
    required this.vaccinated,
    required this.ownerName,
    required this.ownerPhone,
    required this.note,
    required this.createdAtIso,
    this.petId,
    this.status = 'รอดำเนินการ',
  });

  final String id;
  final String? petId;
  final String petName;
  final String species;
  final String gender;
  final String age;
  final String weight;

  final String district;
  final String pointName;
  final String pointAddress;
  final String pointType;

  final String dateIso;
  final String timeSlot;

  final bool fasted;
  final bool healthChecked;
  final bool vaccinated;

  final String ownerName;
  final String ownerPhone;
  final String note;

  final String createdAtIso;
  final String status;

  DateTime get date => DateTime.parse(dateIso);
  DateTime get createdAt => DateTime.parse(createdAtIso);

  Map<String, dynamic> toJson() => {
    'id': id,
    'petId': petId,
    'petName': petName,
    'species': species,
    'gender': gender,
    'age': age,
    'weight': weight,
    'district': district,
    'pointName': pointName,
    'pointAddress': pointAddress,
    'pointType': pointType,
    'dateIso': dateIso,
    'timeSlot': timeSlot,
    'fasted': fasted,
    'healthChecked': healthChecked,
    'vaccinated': vaccinated,
    'ownerName': ownerName,
    'ownerPhone': ownerPhone,
    'note': note,
    'createdAtIso': createdAtIso,
    'status': status,
  };

  factory SterilizationBookingRecord.fromJson(Map<String, dynamic> json) {
    return SterilizationBookingRecord(
      id: json['id'] as String,
      petId: json['petId'] as String?,
      petName: json['petName'] as String,
      species: json['species'] as String,
      gender: json['gender'] as String,
      age: json['age'] as String? ?? '',
      weight: json['weight'] as String? ?? '',
      district: json['district'] as String,
      pointName: json['pointName'] as String,
      pointAddress: json['pointAddress'] as String,
      pointType: json['pointType'] as String? ?? 'fixed',
      dateIso: json['dateIso'] as String,
      timeSlot: json['timeSlot'] as String,
      fasted: json['fasted'] as bool? ?? false,
      healthChecked: json['healthChecked'] as bool? ?? false,
      vaccinated: json['vaccinated'] as bool? ?? false,
      ownerName: json['ownerName'] as String? ?? '',
      ownerPhone: json['ownerPhone'] as String? ?? '',
      note: json['note'] as String? ?? '',
      createdAtIso: json['createdAtIso'] as String,
      status: json['status'] as String? ?? 'รอดำเนินการ',
    );
  }
}

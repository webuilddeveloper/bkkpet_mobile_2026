class AdoptionPet {
  const AdoptionPet({
    required this.id,
    required this.name,
    required this.species,
    this.imageAsset = '',
    required this.breed,
    required this.gender,
    required this.ageLabel,
    required this.ageGroup,
    required this.size,
    required this.temperament,
    required this.district,
    required this.history,
    this.sterilized = false,
    this.vaccinated = false,
    this.healthNote = '',
  });

  final String id;
  final String name;
  final String species; // 'สุนัข' | 'แมว'
  final String imageAsset;
  final String breed;
  final String gender; // 'เพศผู้' | 'เพศเมีย'
  final String ageLabel; // แสดงผล เช่น '1 ปี'
  final String ageGroup; // 'ลูกสัตว์' | 'โตเต็มวัย' | 'สูงวัย'
  final String size; // 'เล็ก' | 'กลาง' | 'ใหญ่'
  final List<String> temperament;
  final String district;
  final String history;
  final bool sterilized;
  final bool vaccinated;
  final String healthNote;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'species': species,
    'imageAsset': imageAsset,
    'breed': breed,
    'gender': gender,
    'ageLabel': ageLabel,
    'ageGroup': ageGroup,
    'size': size,
    'temperament': temperament,
    'district': district,
    'history': history,
    'sterilized': sterilized,
    'vaccinated': vaccinated,
    'healthNote': healthNote,
  };

  factory AdoptionPet.fromJson(Map<String, dynamic> json) {
    return AdoptionPet(
      id: json['id'] as String,
      name: json['name'] as String,
      species: json['species'] as String,
      imageAsset: json['imageAsset'] as String? ?? '',
      breed: json['breed'] as String,
      gender: json['gender'] as String,
      ageLabel: json['ageLabel'] as String,
      ageGroup: json['ageGroup'] as String,
      size: json['size'] as String,
      temperament:
          (json['temperament'] as List<dynamic>? ?? const [])
              .map((e) => e as String)
              .toList(),
      district: json['district'] as String,
      history: json['history'] as String,
      sterilized: json['sterilized'] as bool? ?? false,
      vaccinated: json['vaccinated'] as bool? ?? false,
      healthNote: json['healthNote'] as String? ?? '',
    );
  }
}

enum AdoptionStatus {
  submitted,
  appointment,
  review,
  approved,
  completed,
}

extension AdoptionStatusLabel on AdoptionStatus {
  String get label {
    switch (this) {
      case AdoptionStatus.submitted:
        return 'ส่งใบสมัครแล้ว';
      case AdoptionStatus.appointment:
        return 'นัดหมายดูตัว';
      case AdoptionStatus.review:
        return 'อยู่ระหว่างพิจารณา';
      case AdoptionStatus.approved:
        return 'อนุมัติการรับเลี้ยง';
      case AdoptionStatus.completed:
        return 'รับเลี้ยงสำเร็จ';
    }
  }
}

class AdoptionApplication {
  AdoptionApplication({required this.pet});

  final AdoptionPet pet;

  // ---- ผู้สมัคร ----
  String applicantName = '';
  String applicantIdCard = '';
  String applicantPhone = '';
  String applicantAddress = '';

  // ---- ที่พักอาศัย ----
  String residenceType = 'บ้านเดี่ยว';
  bool ownResidence = true;
  bool hasYard = false;
  bool familyAgrees = true;
  bool hasOtherPets = false;
  String otherPetsDetail = '';

  // ---- ประสบการณ์และเหตุผล ----
  String experience = '';
  String reason = '';
  bool agreeFollowUp = false;

  DateTime? appointmentDate;
  String? appointmentTimeSlot;
  String appointmentLocation = 'ศูนย์รับเลี้ยงสัตว์ กทม. บางกะปิ';

  AdoptionStatus status = AdoptionStatus.submitted;

  Map<String, dynamic> toJson() => {
    'pet': pet.toJson(),
    'applicantName': applicantName,
    'applicantIdCard': applicantIdCard,
    'applicantPhone': applicantPhone,
    'applicantAddress': applicantAddress,
    'residenceType': residenceType,
    'ownResidence': ownResidence,
    'hasYard': hasYard,
    'familyAgrees': familyAgrees,
    'hasOtherPets': hasOtherPets,
    'otherPetsDetail': otherPetsDetail,
    'experience': experience,
    'reason': reason,
    'agreeFollowUp': agreeFollowUp,
    'appointmentDate': appointmentDate?.toIso8601String(),
    'appointmentTimeSlot': appointmentTimeSlot,
    'appointmentLocation': appointmentLocation,
    'status': status.name,
  };

  factory AdoptionApplication.fromJson(Map<String, dynamic> json) {
    final app = AdoptionApplication(
      pet: AdoptionPet.fromJson(json['pet'] as Map<String, dynamic>),
    );
    app.applicantName = json['applicantName'] as String? ?? '';
    app.applicantIdCard = json['applicantIdCard'] as String? ?? '';
    app.applicantPhone = json['applicantPhone'] as String? ?? '';
    app.applicantAddress = json['applicantAddress'] as String? ?? '';
    app.residenceType = json['residenceType'] as String? ?? 'บ้านเดี่ยว';
    app.ownResidence = json['ownResidence'] as bool? ?? true;
    app.hasYard = json['hasYard'] as bool? ?? false;
    app.familyAgrees = json['familyAgrees'] as bool? ?? true;
    app.hasOtherPets = json['hasOtherPets'] as bool? ?? false;
    app.otherPetsDetail = json['otherPetsDetail'] as String? ?? '';
    app.experience = json['experience'] as String? ?? '';
    app.reason = json['reason'] as String? ?? '';
    app.agreeFollowUp = json['agreeFollowUp'] as bool? ?? false;
    final appointmentDate = json['appointmentDate'] as String?;
    app.appointmentDate =
        appointmentDate == null || appointmentDate.isEmpty
            ? null
            : DateTime.parse(appointmentDate);
    app.appointmentTimeSlot = json['appointmentTimeSlot'] as String?;
    app.appointmentLocation =
        json['appointmentLocation'] as String? ??
        'ศูนย์รับเลี้ยงสัตว์ กทม. บางกะปิ';
    app.status = AdoptionStatus.values.firstWhere(
      (item) => item.name == (json['status'] as String? ?? 'submitted'),
      orElse: () => AdoptionStatus.submitted,
    );
    return app;
  }
}

class AdoptionFollowUpEntry {
  AdoptionFollowUpEntry({
    required this.createdAt,
    required this.condition,
    required this.note,
    this.mediaPath = '',
    this.mediaName = '',
    this.mediaKind = '',
  });

  final DateTime createdAt;
  final String condition;
  final String note;
  final String mediaPath;
  final String mediaName;
  final String mediaKind;

  bool get hasMedia => mediaPath.isNotEmpty;
  bool get hasVideo => mediaKind == 'video';

  Map<String, dynamic> toJson() => {
    'createdAt': createdAt.toIso8601String(),
    'condition': condition,
    'note': note,
    'mediaPath': mediaPath,
    'mediaName': mediaName,
    'mediaKind': mediaKind,
  };

  factory AdoptionFollowUpEntry.fromJson(Map<String, dynamic> json) {
    return AdoptionFollowUpEntry(
      createdAt: DateTime.parse(json['createdAt'] as String),
      condition: json['condition'] as String? ?? '',
      note: json['note'] as String? ?? '',
      mediaPath: json['mediaPath'] as String? ?? '',
      mediaName: json['mediaName'] as String? ?? '',
      mediaKind: json['mediaKind'] as String? ?? '',
    );
  }
}

class AdoptionAdoptedRecord {
  AdoptionAdoptedRecord({
    required this.id,
    required this.pet,
    required this.approvedAt,
    required this.statusText,
    required this.lastUpdateLabel,
    required this.updates,
  });

  final String id;
  final AdoptionPet pet;
  final DateTime approvedAt;
  final String statusText;
  final String lastUpdateLabel;
  final List<AdoptionFollowUpEntry> updates;

  Map<String, dynamic> toJson() => {
    'id': id,
    'pet': {
      'id': pet.id,
      'name': pet.name,
      'species': pet.species,
      'imageAsset': pet.imageAsset,
      'breed': pet.breed,
      'gender': pet.gender,
      'ageLabel': pet.ageLabel,
      'ageGroup': pet.ageGroup,
      'size': pet.size,
      'temperament': pet.temperament,
      'district': pet.district,
      'history': pet.history,
      'sterilized': pet.sterilized,
      'vaccinated': pet.vaccinated,
      'healthNote': pet.healthNote,
    },
    'approvedAt': approvedAt.toIso8601String(),
    'statusText': statusText,
    'lastUpdateLabel': lastUpdateLabel,
    'updates': updates.map((e) => e.toJson()).toList(),
  };

  factory AdoptionAdoptedRecord.fromJson(Map<String, dynamic> json) {
    final petJson = json['pet'] as Map<String, dynamic>;
    final pet = AdoptionPet(
      id: petJson['id'] as String,
      name: petJson['name'] as String,
      species: petJson['species'] as String,
      imageAsset: petJson['imageAsset'] as String? ?? '',
      breed: petJson['breed'] as String,
      gender: petJson['gender'] as String,
      ageLabel: petJson['ageLabel'] as String,
      ageGroup: petJson['ageGroup'] as String,
      size: petJson['size'] as String,
      temperament:
          (petJson['temperament'] as List<dynamic>? ?? const [])
              .map((e) => e as String)
              .toList(),
      district: petJson['district'] as String,
      history: petJson['history'] as String,
      sterilized: petJson['sterilized'] as bool? ?? false,
      vaccinated: petJson['vaccinated'] as bool? ?? false,
      healthNote: petJson['healthNote'] as String? ?? '',
    );

    return AdoptionAdoptedRecord(
      id: json['id'] as String,
      pet: pet,
      approvedAt: DateTime.parse(json['approvedAt'] as String),
      statusText: json['statusText'] as String? ?? 'รับเลี้ยงสำเร็จ',
      lastUpdateLabel: json['lastUpdateLabel'] as String? ?? 'ยังไม่มีการอัปเดต',
      updates:
          (json['updates'] as List<dynamic>? ?? const [])
              .map(
                (item) => AdoptionFollowUpEntry.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList(),
    );
  }
}

class FollowUpCheckpoint {
  FollowUpCheckpoint({
    required this.label,
    required this.dueDayLabel,
    this.completed = false,
  });

  final String label;
  final String dueDayLabel;
  bool completed;
  String? petCondition;
  String? note;
}

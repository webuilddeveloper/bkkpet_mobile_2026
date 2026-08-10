// ================================================================
// โมเดลข้อมูล "ตามหาสัตว์เลี้ยง"
// ================================================================

class LostFoundReportType {
  static const lost = 'lost';
}

class LostFoundMediaKind {
  static const image = 'image';
  static const video = 'video';
}

class LostFoundReport {
  LostFoundReport({
    required this.id,
    required this.type,
    required this.species,
    required this.colorDescription,
    required this.location,
    required this.dateIso,
    required this.contactName,
    required this.contactPhone,
    required this.createdAtIso,
    this.petName = '',
    this.chipId = '',
    this.note = '',
    this.mediaPath = '',
    this.mediaName = '',
    this.mediaKind = '',
    this.resolved = false,
  });

  final String id;

  /// LostFoundReportType.lost
  final String type;

  final String species;
  final String petName;
  final String colorDescription;
  final String location;

  /// วันที่หาย/พบ เก็บเป็น ISO8601 string
  final String dateIso;

  /// หมายเลขไมโครชิป (ถ้าทราบ)
  final String chipId;

  final String contactName;
  final String contactPhone;
  final String note;
  final String mediaPath;
  final String mediaName;
  final String mediaKind;

  /// true เมื่อเจอเจ้าของ/เจอสัตว์แล้ว จบเรื่อง
  final bool resolved;

  final String createdAtIso;

  DateTime get date => DateTime.parse(dateIso);
  DateTime get createdAt => DateTime.parse(createdAtIso);

  bool get isLost => type == LostFoundReportType.lost;
  bool get hasMedia => mediaPath.isNotEmpty;
  bool get hasImage => mediaKind == LostFoundMediaKind.image;
  bool get hasVideo => mediaKind == LostFoundMediaKind.video;

  LostFoundReport copyWith({bool? resolved}) {
    return LostFoundReport(
      id: id,
      type: type,
      species: species,
      petName: petName,
      colorDescription: colorDescription,
      location: location,
      dateIso: dateIso,
      chipId: chipId,
      contactName: contactName,
      contactPhone: contactPhone,
      note: note,
      mediaPath: mediaPath,
      mediaName: mediaName,
      mediaKind: mediaKind,
      resolved: resolved ?? this.resolved,
      createdAtIso: createdAtIso,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'species': species,
        'petName': petName,
        'colorDescription': colorDescription,
        'location': location,
        'dateIso': dateIso,
        'chipId': chipId,
        'contactName': contactName,
        'contactPhone': contactPhone,
        'note': note,
        'mediaPath': mediaPath,
        'mediaName': mediaName,
        'mediaKind': mediaKind,
        'resolved': resolved,
        'createdAtIso': createdAtIso,
      };

  factory LostFoundReport.fromJson(Map<String, dynamic> json) {
    return LostFoundReport(
      id: json['id'] as String,
      type: json['type'] as String? ?? LostFoundReportType.lost,
      species: json['species'] as String? ?? '',
      petName: json['petName'] as String? ?? '',
      colorDescription: json['colorDescription'] as String? ?? '',
      location: json['location'] as String? ?? '',
      dateIso: json['dateIso'] as String,
      chipId: json['chipId'] as String? ?? '',
      contactName: json['contactName'] as String? ?? '',
      contactPhone: json['contactPhone'] as String? ?? '',
      note: json['note'] as String? ?? '',
      mediaPath: json['mediaPath'] as String? ?? '',
      mediaName: json['mediaName'] as String? ?? '',
      mediaKind: json['mediaKind'] as String? ?? '',
      resolved: json['resolved'] as bool? ?? false,
      createdAtIso: json['createdAtIso'] as String,
    );
  }
}

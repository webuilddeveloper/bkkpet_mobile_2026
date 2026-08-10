class ReportIncidentStatus {
  static const submitted = 'ส่งเรื่องแล้ว';
  static const received = 'รับเรื่องแล้ว';
  static const reviewing = 'กำลังตรวจสอบ';
  static const onSite = 'กำลังลงพื้นที่';
  static const inProgress = 'กำลังดำเนินการ';
  static const resolved = 'ปิดเรื่องแล้ว';

  static const all = <String>[
    submitted,
    received,
    reviewing,
    onSite,
    inProgress,
    resolved,
  ];
}

class IncidentMediaKind {
  static const image = 'image';
  static const video = 'video';
}

class ReportIncidentUpdate {
  ReportIncidentUpdate({
    required this.status,
    required this.title,
    required this.message,
    required this.timestampIso,
    this.by = 'ระบบ',
  });

  final String status;
  final String title;
  final String message;
  final String timestampIso;
  final String by;

  DateTime get timestamp => DateTime.parse(timestampIso);

  Map<String, dynamic> toJson() => {
        'status': status,
        'title': title,
        'message': message,
        'timestampIso': timestampIso,
        'by': by,
      };

  factory ReportIncidentUpdate.fromJson(Map<String, dynamic> json) {
    return ReportIncidentUpdate(
      status: json['status'] as String? ?? ReportIncidentStatus.submitted,
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      timestampIso: json['timestampIso'] as String,
      by: json['by'] as String? ?? 'ระบบ',
    );
  }
}

class ReportIncidentRecord {
  ReportIncidentRecord({
    required this.id,
    required this.incidentType,
    required this.urgency,
    required this.detail,
    required this.locationLatitude,
    required this.locationLongitude,
    required this.locationAccuracy,
    required this.locationTimestampIso,
    required this.mediaPath,
    required this.mediaName,
    required this.mediaKind,
    required this.status,
    required this.updates,
    required this.createdAtIso,
  });

  final String id;
  final String incidentType;
  final String urgency;
  final String detail;
  final double locationLatitude;
  final double locationLongitude;
  final double locationAccuracy;
  final String locationTimestampIso;
  final String mediaPath;
  final String mediaName;
  final String mediaKind;
  final String status;
  final List<ReportIncidentUpdate> updates;
  final String createdAtIso;

  DateTime get createdAt => DateTime.parse(createdAtIso);
  DateTime get locationTimestamp => DateTime.parse(locationTimestampIso);

  String get coordinateText =>
      '${locationLatitude.toStringAsFixed(6)}, ${locationLongitude.toStringAsFixed(6)}';

  String get urgencyLabel => urgency;

  bool get hasMedia => mediaPath.isNotEmpty;

  bool get hasVideo => mediaKind == IncidentMediaKind.video;

  ReportIncidentRecord copyWith({
    String? status,
    List<ReportIncidentUpdate>? updates,
  }) {
    return ReportIncidentRecord(
      id: id,
      incidentType: incidentType,
      urgency: urgency,
      detail: detail,
      locationLatitude: locationLatitude,
      locationLongitude: locationLongitude,
      locationAccuracy: locationAccuracy,
      locationTimestampIso: locationTimestampIso,
      mediaPath: mediaPath,
      mediaName: mediaName,
      mediaKind: mediaKind,
      status: status ?? this.status,
      updates: updates ?? this.updates,
      createdAtIso: createdAtIso,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'incidentType': incidentType,
        'urgency': urgency,
        'detail': detail,
        'locationLatitude': locationLatitude,
        'locationLongitude': locationLongitude,
        'locationAccuracy': locationAccuracy,
        'locationTimestampIso': locationTimestampIso,
        'mediaPath': mediaPath,
        'mediaName': mediaName,
        'mediaKind': mediaKind,
        'status': status,
        'updates': updates.map((e) => e.toJson()).toList(),
        'createdAtIso': createdAtIso,
      };

  factory ReportIncidentRecord.fromJson(Map<String, dynamic> json) {
    return ReportIncidentRecord(
      id: json['id'] as String,
      incidentType: json['incidentType'] as String? ?? '',
      urgency: json['urgency'] as String? ?? 'ปกติ',
      detail: json['detail'] as String? ?? '',
      locationLatitude:
          (json['locationLatitude'] as num?)?.toDouble() ?? 0.0,
      locationLongitude:
          (json['locationLongitude'] as num?)?.toDouble() ?? 0.0,
      locationAccuracy: (json['locationAccuracy'] as num?)?.toDouble() ?? 0.0,
      locationTimestampIso:
          json['locationTimestampIso'] as String? ?? DateTime.now().toIso8601String(),
      mediaPath: json['mediaPath'] as String? ?? '',
      mediaName: json['mediaName'] as String? ?? '',
      mediaKind: json['mediaKind'] as String? ?? IncidentMediaKind.video,
      status: json['status'] as String? ?? ReportIncidentStatus.submitted,
      updates:
          (json['updates'] as List? ?? const [])
              .map(
                (e) => ReportIncidentUpdate.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList(),
      createdAtIso: json['createdAtIso'] as String,
    );
  }
}

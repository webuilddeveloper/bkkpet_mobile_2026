class ConsultBookingRecord {
  ConsultBookingRecord({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.doctorImage,
    required this.specialty,
    required this.clinicName,
    required this.consultType,
    required this.petId,
    required this.petName,
    required this.petSpecies,
    required this.bookingDateIso,
    required this.timeSlot,
    required this.note,
    required this.createdAtIso,
    this.status = 'รอการยืนยัน',
  });

  final String id;
  final String doctorId;
  final String doctorName;
  final String doctorImage;
  final String specialty;
  final String clinicName;
  final String consultType;
  final String petId;
  final String petName;
  final String petSpecies;
  final String bookingDateIso;
  final String timeSlot;
  final String note;
  final String createdAtIso;
  final String status;

  DateTime get bookingDate => DateTime.parse(bookingDateIso);
  DateTime get createdAt => DateTime.parse(createdAtIso);

  Map<String, dynamic> toJson() => {
        'id': id,
        'doctorId': doctorId,
        'doctorName': doctorName,
        'doctorImage': doctorImage,
        'specialty': specialty,
        'clinicName': clinicName,
        'consultType': consultType,
        'petId': petId,
        'petName': petName,
        'petSpecies': petSpecies,
        'bookingDateIso': bookingDateIso,
        'timeSlot': timeSlot,
        'note': note,
        'createdAtIso': createdAtIso,
        'status': status,
      };

  factory ConsultBookingRecord.fromJson(Map<String, dynamic> json) {
    return ConsultBookingRecord(
      id: json['id'] as String,
      doctorId: json['doctorId'] as String? ?? '',
      doctorName: json['doctorName'] as String? ?? '',
      doctorImage: json['doctorImage'] as String? ?? 'assets/images/doctor.png',
      specialty: json['specialty'] as String? ?? '',
      clinicName: json['clinicName'] as String? ?? '',
      consultType: json['consultType'] as String? ?? 'แชท',
      petId: json['petId'] as String? ?? '',
      petName: json['petName'] as String? ?? '',
      petSpecies: json['petSpecies'] as String? ?? '',
      bookingDateIso: json['bookingDateIso'] as String,
      timeSlot: json['timeSlot'] as String? ?? '',
      note: json['note'] as String? ?? '',
      createdAtIso: json['createdAtIso'] as String,
      status: json['status'] as String? ?? 'รอการยืนยัน',
    );
  }
}

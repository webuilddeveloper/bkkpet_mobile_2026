class ConsultDoctor {
  const ConsultDoctor({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.specialty,
    required this.clinic,
    required this.area,
    required this.description,
    required this.rating,
    required this.experienceYears,
    required this.fee,
    required this.languages,
    required this.isOnlineNow,
  });

  final String id;
  final String name;
  final String imageUrl;
  final String specialty;
  final String clinic;
  final String area;
  final String description;
  final double rating;
  final int experienceYears;
  final int fee;
  final List<String> languages;
  final bool isOnlineNow;
}

const consultDoctors = <ConsultDoctor>[
  ConsultDoctor(
    id: 'vet-1',
    name: 'น.สพ. ดลชัย จงภักดี',
    imageUrl: 'assets/images/doctor.png',
    specialty: 'โรคผิวหนังและภูมิแพ้',
    clinic: 'คลินิกสัตวแพทย์ สุขุมวิท',
    area: 'วัฒนา',
    description:
        'ให้คำปรึกษาเรื่องผิวหนัง คัน ขนร่วง แพ้อาหาร และการดูแลระยะยาว',
    rating: 4.9,
    experienceYears: 12,
    fee: 350,
    languages: ['ไทย', 'อังกฤษ'],
    isOnlineNow: true,
  ),
  ConsultDoctor(
    id: 'vet-2',
    name: 'ส.พญ. อรุณ แจ่งใส',
    imageUrl: 'assets/images/doctor2.png',
    specialty: 'อายุรกรรมและแมว',
    clinic: 'ศูนย์รักษาสัตว์ อารีย์',
    area: 'พญาไท',
    description:
        'เชี่ยวชาญแมวป่วย เบื่ออาหาร อาเจียน ไข้ และการดูแลสัตว์สูงวัย',
    rating: 5.0,
    experienceYears: 9,
    fee: 400,
    languages: ['ไทย'],
    isOnlineNow: false,
  ),
  ConsultDoctor(
    id: 'vet-3',
    name: 'น.สพ. ภาคิน ศรีทอง',
    imageUrl: 'assets/images/doc01.png',
    specialty: 'ศัลยกรรมและอุบัติเหตุ',
    clinic: 'โรงพยาบาลสัตว์รัชดา',
    area: 'ห้วยขวาง',
    description:
        'ดูแลเคสฉุกเฉิน บาดเจ็บ กระดูก และแผลผ่าตัด พร้อมนัดติดตามอาการ',
    rating: 4.8,
    experienceYears: 11,
    fee: 450,
    languages: ['ไทย', 'อังกฤษ'],
    isOnlineNow: true,
  ),
  ConsultDoctor(
    id: 'vet-4',
    name: 'ส.พญ. ปรียา สุขสบาย',
    imageUrl: 'assets/images/doc02.png',
    specialty: 'พฤติกรรมและการฝึก',
    clinic: 'Pet Behavior Clinic',
    area: 'จตุจักร',
    description:
        'แนะนำเรื่องการกัด แยกบ้าน ปัสสาวะไม่เป็นที่ และพฤติกรรมก้าวร้าว',
    rating: 4.7,
    experienceYears: 8,
    fee: 320,
    languages: ['ไทย', 'อังกฤษ'],
    isOnlineNow: true,
  ),
];

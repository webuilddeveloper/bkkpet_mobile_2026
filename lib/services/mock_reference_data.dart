class ThaiLocationMock {
  const ThaiLocationMock({
    required this.subdistrict,
    required this.district,
    required this.province,
    required this.zipCode,
  });

  final String subdistrict;
  final String district;
  final String province;
  final String zipCode;

  String get displayLabel => '$subdistrict / $district / $province';
}

class MockReferenceData {
  static const List<ThaiLocationMock> locations = [
    ThaiLocationMock(
      subdistrict: 'ลุมพินี',
      district: 'ปทุมวัน',
      province: 'กรุงเทพมหานคร',
      zipCode: '10330',
    ),
    ThaiLocationMock(
      subdistrict: 'วังใหม่',
      district: 'ปทุมวัน',
      province: 'กรุงเทพมหานคร',
      zipCode: '10330',
    ),
    ThaiLocationMock(
      subdistrict: 'คลองเตย',
      district: 'คลองเตย',
      province: 'กรุงเทพมหานคร',
      zipCode: '10110',
    ),
    ThaiLocationMock(
      subdistrict: 'คลองตัน',
      district: 'คลองเตย',
      province: 'กรุงเทพมหานคร',
      zipCode: '10110',
    ),
    ThaiLocationMock(
      subdistrict: 'ลาดพร้าว',
      district: 'ลาดพร้าว',
      province: 'กรุงเทพมหานคร',
      zipCode: '10230',
    ),
    ThaiLocationMock(
      subdistrict: 'จอมพล',
      district: 'จตุจักร',
      province: 'กรุงเทพมหานคร',
      zipCode: '10900',
    ),
    ThaiLocationMock(
      subdistrict: 'ห้วยขวาง',
      district: 'ห้วยขวาง',
      province: 'กรุงเทพมหานคร',
      zipCode: '10310',
    ),
    ThaiLocationMock(
      subdistrict: 'บางกะปิ',
      district: 'บางกะปิ',
      province: 'กรุงเทพมหานคร',
      zipCode: '10240',
    ),
    ThaiLocationMock(
      subdistrict: 'หัวหมาก',
      district: 'บางกะปิ',
      province: 'กรุงเทพมหานคร',
      zipCode: '10240',
    ),
    ThaiLocationMock(
      subdistrict: 'พระโขนงเหนือ',
      district: 'วัฒนา',
      province: 'กรุงเทพมหานคร',
      zipCode: '10110',
    ),
  ];

  static const List<String> dogBreeds = [
    'พันธุ์ทาง',
    'ไทยหลังอาน',
    'ชิบะอินุ',
    'ปอมเมอเรเนียน',
    'พุดเดิ้ล',
    'ชิวาวา',
    'โกลเด้น รีทรีฟเวอร์',
    'ลาบราดอร์ รีทรีฟเวอร์',
    'เฟรนช์ บูลด็อก',
    'บีเกิล',
    'อื่นๆ',
  ];

  static const List<String> catBreeds = [
    'พันธุ์ทาง',
    'ไทย',
    'เปอร์เซีย',
    'สก็อตติช โฟลด์',
    'บริติช ชอร์ตแฮร์',
    'อเมริกัน ชอร์ตแฮร์',
    'วิเชียรมาศ',
    'สฟิงซ์',
    'อื่นๆ',
  ];

  static const List<String> petColors = [
    'ดำ',
    'ขาว',
    'น้ำตาล',
    'เทา',
    'ครีม',
    'ทอง',
    'ส้ม',
    'ลายสลิด',
    'สองสี',
    'สามสี',
    'อื่นๆ',
  ];

  static List<String> uniqueSubdistricts() {
    final values = locations.map((e) => e.subdistrict).toSet().toList()..sort();
    return values;
  }

  static List<String> uniqueDistricts() {
    final values = locations.map((e) => e.district).toSet().toList()..sort();
    return values;
  }

  static List<String> uniqueProvinces() {
    final values = locations.map((e) => e.province).toSet().toList()..sort();
    return values;
  }

  static ThaiLocationMock? findBySubdistrict(String value) {
    for (final item in locations) {
      if (item.subdistrict == value) return item;
    }
    return null;
  }

  static ThaiLocationMock? findByDistrict(String value) {
    for (final item in locations) {
      if (item.district == value) return item;
    }
    return null;
  }

  static ThaiLocationMock? findByProvince(String value) {
    for (final item in locations) {
      if (item.province == value) return item;
    }
    return null;
  }
}

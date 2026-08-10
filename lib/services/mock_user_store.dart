import 'package:bkkpet/mock_data.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppAuthKeys {
  static const String isLogin = 'islogin';
}

class MockOwnerProfile {
  const MockOwnerProfile({
    required this.fullName,
    required this.idCard,
    required this.phone,
    required this.email,
    required this.address,
    required this.subdistrict,
    required this.district,
    required this.province,
    required this.zipCode,
    required this.profileImage,
  });

  final String fullName;
  final String idCard;
  final String phone;
  final String email;
  final String address;
  final String subdistrict;
  final String district;
  final String province;
  final String zipCode;
  final String profileImage;

  String get shortAddress =>
      '$address $subdistrict $district $province $zipCode';
}

class MockPetProfile {
  const MockPetProfile({
    required this.id,
    required this.name,
    required this.species,
    required this.image,
    required this.gender,
    required this.breed,
    required this.ageYears,
    required this.weightKg,
    required this.color,
    required this.traits,
    required this.microchipNumber,
    required this.microchipLocation,
    required this.birthDate,
    required this.chipDate,
  });

  final String id;
  final String name;
  final String species;
  final String image;
  final String gender;
  final String breed;
  final String ageYears;
  final String weightKg;
  final String color;
  final String traits;
  final String microchipNumber;
  final String microchipLocation;
  final DateTime? birthDate;
  final DateTime? chipDate;

  Map<String, dynamic> toJson() => {
    'id': id,
    'chipNumber': microchipNumber,
    'name': name,
    'type': species,
    'species': species,
    'breed': breed,
    'gender': gender,
    'birthDate': birthDate?.toIso8601String(),
    'ageYears': ageYears,
    'weightKg': weightKg,
    'color': color,
    'traits': traits,
    'ownerId': 'user_001',
    'image': image,
    'microchipLocation': microchipLocation,
    'chipDate': chipDate?.toIso8601String(),
  };

  factory MockPetProfile.fromJson(Map<String, dynamic> json) {
    return MockPetProfile(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      species:
          json['species'] as String? ??
          json['type'] as String? ??
          'สัตว์เลี้ยง',
      image: json['image'] as String? ?? 'assets/icons/iconapp.png',
      gender: json['gender'] as String? ?? 'ไม่ระบุ',
      breed: json['breed'] as String? ?? '',
      ageYears: json['ageYears'] as String? ?? '',
      weightKg: json['weightKg'] as String? ?? '',
      color: json['color'] as String? ?? '',
      traits: json['traits'] as String? ?? '',
      microchipNumber: json['chipNumber'] as String? ?? '',
      microchipLocation: json['microchipLocation'] as String? ?? '',
      birthDate: _parseDate(json['birthDate']),
      chipDate: _parseDate(json['chipDate']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}

class MockUserStore {
  static MockOwnerProfile _owner = const MockOwnerProfile(
    fullName: 'นายทดสอบ ระบบจริง',
    idCard: '1103700000001',
    phone: '0812345678',
    email: 'demo@bkkpet.go.th',
    address: '19/1-2 อาคารวังเด็ก ชั้น 8 ซอยยาสูบ 1 ถนนวิภาวดีรังสิต',
    subdistrict: 'จอมพล',
    district: 'จตุจักร',
    province: 'กรุงเทพมหานคร',
    zipCode: '10900',
    profileImage: 'assets/images/profile_test.png',
  );

  static MockOwnerProfile get owner => _owner;

  static void updateOwner(MockOwnerProfile owner) {
    _owner = owner;
  }

  static List<MockPetProfile> get pets =>
      mockPets.map(MockPetProfile.fromJson).toList();

  static MockPetProfile? findPetById(String? id) {
    if (id == null || id.isEmpty) return null;
    for (final pet in pets) {
      if (pet.id == id) return pet;
    }
    return null;
  }

  static MockPetProfile? findPetByName(String? name) {
    if (name == null || name.trim().isEmpty) return null;
    final normalized = name.trim();
    for (final pet in pets) {
      if (pet.name == normalized) return pet;
    }
    return null;
  }

  static void upsertPet(MockPetProfile pet) {
    final petJson = pet.toJson();
    final chip = pet.microchipNumber.trim();
    final index = mockPets.indexWhere((item) {
      final sameId = item['id'] == pet.id;
      final sameChip = chip.isNotEmpty && item['chipNumber'] == chip;
      return sameId || sameChip;
    });

    if (index == -1) {
      mockPets.add(petJson);
    } else {
      mockPets[index] = {...mockPets[index], ...petJson};
    }
  }
}

class AppAuthService {
  AppAuthService._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<bool> isLoggedIn() async {
    final value = await _storage.read(key: AppAuthKeys.isLogin);
    return value == 'true';
  }

  static Future<void> setLoggedIn(bool value) async {
    await _storage.write(key: AppAuthKeys.isLogin, value: value.toString());
  }

  static Future<void> loginMock() => setLoggedIn(true);

  static Future<void> logout() => setLoggedIn(false);
}

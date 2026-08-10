import 'dart:convert';

import 'package:bkkpet/services/mock_user_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditableOwnerProfile {
  const EditableOwnerProfile({
    required this.fullName,
    required this.idCard,
    required this.phone,
    required this.email,
    required this.address,
    required this.subdistrict,
    required this.district,
    required this.province,
    required this.zipCode,
    required this.profileImagePath,
    required this.password,
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
  final String profileImagePath;
  final String password;

  String get shortAddress =>
      '$address $subdistrict $district $province $zipCode';

  MockOwnerProfile toMockOwnerProfile() {
    return MockOwnerProfile(
      fullName: fullName,
      idCard: idCard,
      phone: phone,
      email: email,
      address: address,
      subdistrict: subdistrict,
      district: district,
      province: province,
      zipCode: zipCode,
      profileImage: profileImagePath,
    );
  }

  EditableOwnerProfile copyWith({
    String? fullName,
    String? idCard,
    String? phone,
    String? email,
    String? address,
    String? subdistrict,
    String? district,
    String? province,
    String? zipCode,
    String? profileImagePath,
    String? password,
  }) {
    return EditableOwnerProfile(
      fullName: fullName ?? this.fullName,
      idCard: idCard ?? this.idCard,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      subdistrict: subdistrict ?? this.subdistrict,
      district: district ?? this.district,
      province: province ?? this.province,
      zipCode: zipCode ?? this.zipCode,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      password: password ?? this.password,
    );
  }

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'idCard': idCard,
        'phone': phone,
        'email': email,
        'address': address,
        'subdistrict': subdistrict,
        'district': district,
        'province': province,
        'zipCode': zipCode,
        'profileImagePath': profileImagePath,
        'password': password,
      };

  factory EditableOwnerProfile.fromJson(Map<String, dynamic> json) {
    return EditableOwnerProfile(
      fullName: json['fullName'] as String? ?? MockUserStore.owner.fullName,
      idCard: json['idCard'] as String? ?? MockUserStore.owner.idCard,
      phone: json['phone'] as String? ?? MockUserStore.owner.phone,
      email: json['email'] as String? ?? MockUserStore.owner.email,
      address: json['address'] as String? ?? MockUserStore.owner.address,
      subdistrict:
          json['subdistrict'] as String? ?? MockUserStore.owner.subdistrict,
      district: json['district'] as String? ?? MockUserStore.owner.district,
      province: json['province'] as String? ?? MockUserStore.owner.province,
      zipCode: json['zipCode'] as String? ?? MockUserStore.owner.zipCode,
      profileImagePath:
          json['profileImagePath'] as String? ??
          MockUserStore.owner.profileImage,
      password: json['password'] as String? ?? '123456',
    );
  }
}

class ProfileStorage {
  ProfileStorage._();

  static const _storageKey = 'mock_owner_profile_v1';

  static EditableOwnerProfile _defaultProfile() {
    final owner = MockUserStore.owner;
    return EditableOwnerProfile(
      fullName: owner.fullName,
      idCard: owner.idCard,
      phone: owner.phone,
      email: owner.email,
      address: owner.address,
      subdistrict: owner.subdistrict,
      district: owner.district,
      province: owner.province,
      zipCode: owner.zipCode,
      profileImagePath: owner.profileImage,
      password: '123456',
    );
  }

  static Future<EditableOwnerProfile> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      final def = _defaultProfile();
      await save(def);
      return def;
    }
    return EditableOwnerProfile.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  static Future<void> save(EditableOwnerProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(profile.toJson()));
    MockUserStore.updateOwner(profile.toMockOwnerProfile());
  }

  static Future<void> updateProfileImage(String imagePath) async {
    final profile = await load();
    await save(profile.copyWith(profileImagePath: imagePath));
  }

  static Future<void> updateProfile({
    required String fullName,
    required String phone,
    required String email,
    required String address,
    required String subdistrict,
    required String district,
    required String province,
    required String zipCode,
  }) async {
    final profile = await load();
    await save(
      profile.copyWith(
        fullName: fullName,
        phone: phone,
        email: email,
        address: address,
        subdistrict: subdistrict,
        district: district,
        province: province,
        zipCode: zipCode,
      ),
    );
  }

  static Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final profile = await load();
    if (profile.password != currentPassword) return false;
    await save(profile.copyWith(password: newPassword));
    return true;
  }
}

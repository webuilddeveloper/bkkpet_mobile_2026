import 'dart:io';

import 'package:bkkpet/blank_page/appbar.dart';
import 'package:bkkpet/blank_page/app_media_icon.dart';
import 'package:bkkpet/blank_page/custom_dialog.dart';
import 'package:bkkpet/pages/login.dart';
import 'package:bkkpet/pages/profile/profile_account_page.dart';
import 'package:bkkpet/pages/profile/profile_change_password_page.dart';
import 'package:bkkpet/pages/profile/profile_pets_page.dart';
import 'package:bkkpet/services/mock_user_store.dart';
import 'package:bkkpet/services/profile_storage.dart';
import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.onTabChange});
  final void Function(int index) onTabChange;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _picker = ImagePicker();
  EditableOwnerProfile? _profile;
  bool _loading = true;
  bool _pickingImage = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await ProfileStorage.load();
    MockUserStore.updateOwner(profile.toMockOwnerProfile());
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _loading = false;
    });
  }

  Future<void> _pickProfileImage() async {
    if (_pickingImage) return;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.greyscale_200,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 14),
              ListTile(
                leading: const AppMediaIcon(
                  asset: appCameraIconAsset,
                  fallbackIcon: Icons.photo_camera_outlined,
                ),
                title: const Text('ถ่ายรูปใหม่'),
                onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
              ),
              ListTile(
                leading: const AppMediaIcon(
                  asset: appGalleryIconAsset,
                  fallbackIcon: Icons.photo_library_outlined,
                ),
                title: const Text('เลือกรูปจากคลัง'),
                onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    setState(() => _pickingImage = true);
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1600,
      );
      if (picked == null) return;
      await ProfileStorage.updateProfileImage(picked.path);
      await _loadProfile();
    } finally {
      if (mounted) setState(() => _pickingImage = false);
    }
  }

  Future<void> _openAccountPage() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const ProfileAccountPage()),
    );
    if (changed == true) {
      await _loadProfile();
    }
  }

  Future<void> _openPasswordPage() async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const ProfileChangePasswordPage()),
    );
  }

  Future<void> _openAllPets() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfilePetsPage()),
    );
  }

  ImageProvider _profileImageProvider(String path) {
    if (path.startsWith('assets/')) {
      return AssetImage(path);
    }
    final file = File(path);
    if (file.existsSync()) {
      return FileImage(file);
    }
    return const AssetImage('assets/images/profile_test.png');
  }

  Widget _profileAvatar(String path) {
    return Container(
      width: 132,
      height: 132,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: AppColors.greyscale_200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipOval(
        child: Image(image: _profileImageProvider(path), fit: BoxFit.cover),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;
    final pets = MockUserStore.pets;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarMainApp(
        title: 'โปรไฟล์',
        onBack: () => widget.onTabChange(0),
      ),
      body:
          _loading || profile == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        _profileAvatar(profile.profileImagePath),
                        GestureDetector(
                          onTap: _pickProfileImage,
                          child: Container(
                            height: 38,
                            width: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                              border: Border.all(
                                color: Colors.white,
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: const AppMediaIcon(
                                asset: appCameraIconAsset,
                                fallbackIcon: Icons.photo_camera_outlined,
                                size: 22,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      profile.fullName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      profile.email,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.greyscale_400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 34),
                  Row(
                    children: [
                      Text(
                        'สัตว์เลี้ยงของฉัน',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.greyscale_900,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _openAllPets,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 28),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'ดูทั้งหมด',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  for (final pet in pets.take(2)) ...[
                    _PetCard(
                      name: pet.name,
                      age: pet.ageYears,
                      gender: pet.gender,
                      species: pet.species,
                      image: pet.image,
                    ),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    'บัญชีของฉัน',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.greyscale_900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _AccountRow(title: 'บัญชีผู้ใช้งาน', onTap: _openAccountPage),
                  Divider(height: 1, color: AppColors.greyscale_200),
                  _AccountRow(
                    title: 'เปลี่ยนรหัสผ่าน',
                    onTap: _openPasswordPage,
                  ),
                  Divider(height: 1, color: AppColors.greyscale_200),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed:
                          () => showConfirmDialog(
                            context: context,
                            icon: Icons.logout_rounded,
                            title: 'ออกจากระบบ',
                            message:
                                'คุณต้องการออกจากระบบใช่หรือไม่?\nคุณสามารถเข้าสู่ระบบอีกครั้งได้ทุกเมื่อ',
                            confirmText: 'ออกจากระบบ',
                            confirmColor: Colors.red,
                            onConfirm: () async {
                              await logout();
                              if (!context.mounted) return;
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginPage(),
                                ),
                                (route) => false,
                              );
                            },
                          ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red[400],
                        side: BorderSide(color: Colors.red[400]!),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.logout, size: 18, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(
                            'ออกจากระบบ',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.red[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: TextButton(
                      onPressed:
                          () => showConfirmDialog(
                            context: context,
                            icon: Icons.delete_forever_rounded,
                            title: 'ลบบัญชี',
                            message:
                                'คุณต้องการลบบัญชีนี้ใช่หรือไม่?\nการกระทำนี้ไม่สามารถย้อนกลับได้',
                            confirmText: 'ลบบัญชี',
                            confirmColor: Colors.red,
                            barrierDismissible: false,
                            onConfirm: () async {
                              // รองรับไว้ก่อน
                            },
                          ),
                      child: const Text(
                        'ลบบัญชี',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.red,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 65),
                ],
              ),
    );
  }
}

class _PetCard extends StatelessWidget {
  const _PetCard({
    required this.name,
    required this.age,
    required this.gender,
    required this.species,
    required this.image,
  });

  final String name;
  final String age;
  final String gender;
  final String species;
  final String image;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.greyscale_200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Image.asset(image, height: 82, width: 82, fit: BoxFit.cover),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),

                Text(
                  'อายุ:  $age',
                  style: TextStyle(fontSize: 14.5, color: Colors.black),
                ),

                Text(
                  'เพศ:  $gender',
                  style: TextStyle(fontSize: 14.5, color: Colors.black),
                ),

                Text(
                  'ประเภทพ:  $species',
                  style: TextStyle(fontSize: 14.5, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 15, color: AppColors.greyscale_900),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> logout() async {
  await AppAuthService.logout();
}

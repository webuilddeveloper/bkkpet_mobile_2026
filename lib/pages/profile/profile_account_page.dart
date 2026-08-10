import 'package:bkkpet/blank_page/appbar.dart';
import 'package:bkkpet/blank_page/custom_dialog.dart';
import 'package:bkkpet/services/profile_storage.dart';
import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';

class ProfileAccountPage extends StatefulWidget {
  const ProfileAccountPage({super.key});

  @override
  State<ProfileAccountPage> createState() => _ProfileAccountPageState();
}

class _ProfileAccountPageState extends State<ProfileAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _subdistrictCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _provinceCtrl = TextEditingController();
  final _zipCodeCtrl = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile = await ProfileStorage.load();
    _fullNameCtrl.text = profile.fullName;
    _phoneCtrl.text = profile.phone;
    _emailCtrl.text = profile.email;
    _addressCtrl.text = profile.address;
    _subdistrictCtrl.text = profile.subdistrict;
    _districtCtrl.text = profile.district;
    _provinceCtrl.text = profile.province;
    _zipCodeCtrl.text = profile.zipCode;
    if (!mounted) return;
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _subdistrictCtrl.dispose();
    _districtCtrl.dispose();
    _provinceCtrl.dispose();
    _zipCodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;
    setState(() => _saving = true);
    await ProfileStorage.updateProfile(
      fullName: _fullNameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      subdistrict: _subdistrictCtrl.text.trim(),
      district: _districtCtrl.text.trim(),
      province: _provinceCtrl.text.trim(),
      zipCode: _zipCodeCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    await showInfoDialog(
      context: context,
      icon: Icons.check_circle_outline_rounded,
      title: 'บันทึกข้อมูลแล้ว',
      message: 'ข้อมูลบัญชีผู้ใช้ถูกอัปเดตเรียบร้อยแล้ว',
      color: AppColors.primary,
    );
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarMainApp(
        title: 'บัญชีผู้ใช้งาน',
        onBack: () => Navigator.pop(context),
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    _SectionCard(
                      title: 'ข้อมูลส่วนตัว',
                      child: Column(
                        children: [
                          _Field(
                            controller: _fullNameCtrl,
                            // label: 'ชื่อ-นามสกุล',
                          ),
                          const SizedBox(height: 12),
                          _Field(
                            controller: _phoneCtrl,
                            // label: 'เบอร์โทรศัพท์',
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 12),
                          _Field(
                            controller: _emailCtrl,
                            // label: 'อีเมล',
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'ที่อยู่',
                      child: Column(
                        children: [
                          _Field(
                            controller: _addressCtrl,
                            // label: 'บ้านเลขที่ / รายละเอียดที่อยู่',
                            maxLines: 2,
                          ),
                          const SizedBox(height: 12),
                          _Field(
                            controller: _subdistrictCtrl,
                            // label: 'แขวง / ตำบล',
                          ),
                          const SizedBox(height: 12),
                          _Field(
                            controller: _districtCtrl,
                            // label: 'เขต / อำเภอ',
                          ),
                          const SizedBox(height: 12),
                          _Field(
                            controller: _provinceCtrl,
                            // label: 'จังหวัด',
                          ),
                          const SizedBox(height: 12),
                          _Field(
                            controller: _zipCodeCtrl,
                            // label: 'รหัสไปรษณีย์',
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child:
                            _saving
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Text(
                                  'บันทึกข้อมูล',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.greyscale_200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.greyscale_900,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    // required this.label,
    this.keyboardType,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  // final String label;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        // labelText: label,
        filled: true,
        fillColor: const Color(0xffFAFAFA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.greyscale_200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.greyscale_200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
      validator:
          (v) => (v == null || v.trim().isEmpty) ? 'กรุณากรอกข้อมูล' : null,
    );
  }
}

import 'package:bkkpet/blank_page/appbar.dart';
import 'package:bkkpet/blank_page/custom_dialog.dart';
import 'package:bkkpet/services/profile_storage.dart';
import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';

class ProfileChangePasswordPage extends StatefulWidget {
  const ProfileChangePasswordPage({super.key});

  @override
  State<ProfileChangePasswordPage> createState() =>
      _ProfileChangePasswordPageState();
}

class _ProfileChangePasswordPageState extends State<ProfileChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _saving = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;
    if (_newCtrl.text != _confirmCtrl.text) {
      await showInfoDialog(
        context: context,
        icon: Icons.error_outline_rounded,
        title: 'รหัสผ่านไม่ตรงกัน',
        message: 'กรุณายืนยันรหัสผ่านใหม่ให้ตรงกันอีกครั้ง',
        color: Colors.redAccent,
      );
      return;
    }
    setState(() => _saving = true);
    final ok = await ProfileStorage.changePassword(
      currentPassword: _currentCtrl.text,
      newPassword: _newCtrl.text,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (!ok) {
      await showInfoDialog(
        context: context,
        icon: Icons.lock_outline_rounded,
        title: 'รหัสผ่านเดิมไม่ถูกต้อง',
        message: 'กรุณาตรวจสอบรหัสผ่านปัจจุบันอีกครั้ง',
        color: Colors.redAccent,
      );
      return;
    }
    await showInfoDialog(
      context: context,
      icon: Icons.check_circle_outline_rounded,
      title: 'เปลี่ยนรหัสผ่านแล้ว',
      message: 'ระบบบันทึกรหัสผ่านใหม่เรียบร้อยแล้ว',
      color: AppColors.primary,
    );
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarMainApp(
        title: 'เปลี่ยนรหัสผ่าน',
        onBack: () => Navigator.pop(context),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.24),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.greenlight.withValues(alpha: 0.55),
                ),
              ),
              child: Text(
                'ใช้รหัสผ่านเดิมเพื่อยืนยันก่อนตั้งรหัสใหม่',
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primarySecondary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _Field(
              controller: _currentCtrl,
              label: 'รหัสผ่านปัจจุบัน',
              obscureText: _obscureCurrent,
              suffix: IconButton(
                onPressed:
                    () => setState(() => _obscureCurrent = !_obscureCurrent),
                icon: Icon(
                  _obscureCurrent
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _Field(
              controller: _newCtrl,
              label: 'รหัสผ่านใหม่',
              obscureText: _obscureNew,
              suffix: IconButton(
                onPressed: () => setState(() => _obscureNew = !_obscureNew),
                icon: Icon(
                  _obscureNew
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _Field(
              controller: _confirmCtrl,
              label: 'ยืนยันรหัสผ่านใหม่',
              obscureText: _obscureConfirm,
              suffix: IconButton(
                onPressed:
                    () => setState(() => _obscureConfirm = !_obscureConfirm),
                icon: Icon(
                  _obscureConfirm
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
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
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : const Text(
                          'บันทึกรหัสผ่านใหม่',
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

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.suffix,
  });

  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        suffixIcon: suffix,
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
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'กรุณากรอกข้อมูล';
        return null;
      },
    );
  }
}

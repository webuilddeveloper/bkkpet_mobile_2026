import 'package:bkkpet/blank_page/appbar.dart';
import 'package:bkkpet/menu.dart';
import 'package:bkkpet/pages/policy_page.dart';
import 'package:bkkpet/services/mock_user_store.dart';
import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.pageIndex});
  final int? pageIndex;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  /// Tracks which action is currently in flight: 'login', 'thaid',
  /// 'google', 'line', or null when nothing is loading.
  String? _loading;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------
  // Auth actions
  // ---------------------------------------------------------------------

  Future<void> _goToHome() async {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => Menu(pageIndex: null)),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> _handleBack() async {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }
    await Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => Menu(pageIndex: null)),
      (Route<dynamic> route) => false,
    );
  }

  /// Runs [action] while showing a loading state on the [key] button,
  /// then navigates home. Ignores taps while any other action is loading.
  Future<void> _runLoginAction(
    String key,
    Future<void> Function() action,
  ) async {
    if (_loading != null) return;
    setState(() => _loading = key);
    await action();
    if (!mounted) return;
    setState(() => _loading = null);
    if (!mounted) return;
      await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => PolicyPage(
              type: PolicyType.appLogin,
              onAccept: _goToHome,
            ),
      ),
    );
  }

  Future<void> _login() {
    return _runLoginAction('login', () async {
      // TODO: ตรวจสอบ username/password ก่อน
      await AppAuthService.loginMock();
      await Future.delayed(const Duration(milliseconds: 900));
    });
  }

  Future<void> _loginWithThaId() {
    // TODO: ThaID (DOPA OAuth2) flow — deep link + verification screen
    // will replace this stand-in once it's built.
    return _runLoginAction(
      'thaid',
      () async {
        await AppAuthService.loginMock();
        await Future.delayed(const Duration(milliseconds: 900));
      },
    );
  }

  Future<void> _loginWithGoogle() {
    // TODO: Google OAuth flow.
    return _runLoginAction(
      'google',
      () async {
        await AppAuthService.loginMock();
        await Future.delayed(const Duration(milliseconds: 900));
      },
    );
  }

  Future<void> _loginWithLine() {
    // TODO: LINE Login OAuth flow.
    return _runLoginAction(
      'line',
      () async {
        await AppAuthService.loginMock();
        await Future.delayed(const Duration(milliseconds: 900));
      },
    );
  }

  // ---------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // MediaQuery.sizeOf only rebuilds this widget when the size actually
    // changes, and reads more simply than MediaQuery.of(context).size.
    final size = MediaQuery.sizeOf(context);
    final height = size.height;
    final width = size.width;
    final isSmallScreen = height < 650;

    return Scaffold(
      // Soft light grey background so the white card floats on top of it.
      appBar: AppBarMainApp(title: '', onBack: _handleBack),
      backgroundColor: AppColors.greyscale_25,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            width * 0.06,
            height * (isSmallScreen ? 0.03 : 0.05),
            width * 0.06,
            height * 0.03,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildLoginCard(
                height: height,
                width: width,
                isSmallScreen: isSmallScreen,
              ),
              SizedBox(height: height * 0.024),

              // สมัครสมาชิก - เว้นไว้ก่อน ยังไม่เปิดใช้งาน
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'ท่านเป็นผู้ใช้ใหม่ ',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                  ),
                  TextButton(
                    onPressed: null,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 28),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'ต้องการสมัครสมาชิก',
                      style: TextStyle(
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w400,
                        fontSize: isSmallScreen ? 12 : 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The white, elevated card containing the whole login form.
  Widget _buildLoginCard({
    required double height,
    required double width,
    required bool isSmallScreen,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.06,
        vertical: height * 0.035,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ---- Logo ----
          SizedBox(
            height: height * (isSmallScreen ? 0.13 : 0.16),
            child: Center(
              child: Image.asset(
                'assets/icons/logo_bkk.png',
                height: height * (isSmallScreen ? 0.11 : 0.14),
              ),
            ),
          ),
          SizedBox(height: height * 0.032),

          // ---- Email ----
          _SimpleField(
            label: 'อีเมล',
            hint: 'BKKPet@gmail.com',
            controller: _usernameController,
          ),
          SizedBox(height: height * 0.018),

          // ---- Password ----
          _SimpleField(
            label: 'รหัสผ่าน',
            hint: 'BKKP@t1234',
            controller: _passwordController,
            obscureText: _obscurePassword,
            suffix: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 20,
                color: AppColors.greyscale_400,
              ),
              onPressed:
                  () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          SizedBox(height: height * 0.008),

          // ลืมรหัสผ่าน
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: null,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 28),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'ลืมรหัสผ่าน',
                style: TextStyle(
                  color: AppColors.greyscale_400,
                  decoration: TextDecoration.underline,
                  fontSize: isSmallScreen ? 12 : 14,
                ),
              ),
            ),
          ),
          SizedBox(height: height * 0.022),

          // ---- Divider ----
          Row(
            children: [
              Expanded(
                child: Divider(color: AppColors.greyscale_200, thickness: 2),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  'หรือเข้าสู่ระบบด้วย',
                  style: TextStyle(
                    color: AppColors.greyscale_300,
                    fontSize: isSmallScreen ? 12 : 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Expanded(
                child: Divider(color: AppColors.greyscale_200, thickness: 2),
              ),
            ],
          ),
          SizedBox(height: height * 0.024),

          _buildSocialIconRow(width: width),
          SizedBox(height: height * 0.03),

          // ---- Primary login button ----
          _PrimaryButton(
            label: 'เข้าสู่ระบบ',
            isLoading: _loading == 'login',
            enabled: _loading == null,
            onPressed: _login,
            verticalPadding: height * 0.018,
            fontSize: isSmallScreen ? 16 : 18,
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIconRow({required double width}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SocialIconButton(
          assetPath: 'assets/icons/iocn_google.avif',
          isLoading: _loading == 'google',
          enabled: _loading == null,
          onPressed: _loginWithGoogle,
        ),
        SizedBox(width: width * 0.05),
        _SocialIconButton(
          assetPath: 'assets/icons/icons_line.png',
          isLoading: _loading == 'line',
          enabled: _loading == null,
          onPressed: _loginWithLine,
        ),
        SizedBox(width: width * 0.05),
        _SocialIconButton(
          assetPath: 'assets/images/thaid.png',
          isLoading: _loading == 'thaid',
          enabled: _loading == null,
          onPressed: _loginWithThaId,
        ),
      ],
    );
  }
}

// ===========================================================================
// Reusable widgets
// ===========================================================================

/// A labeled text field with a rounded outline border and no leading icon,
/// matching the reference design.
class _SimpleField extends StatelessWidget {
  const _SimpleField({
    required this.label,
    required this.hint,
    required this.controller,
    this.obscureText = false,
    this.suffix,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.greyscale_900,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.greyscale_900,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.greyscale_200, fontSize: 12),
            suffixIcon: suffix,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: _fieldBorder(AppColors.greyscale_200),
            enabledBorder: _fieldBorder(AppColors.greyscale_200),
            focusedBorder: _fieldBorder(AppColors.primary, width: 1.4),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _fieldBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

/// A circular social-login button (Google / LINE / ThaID) whose icon image
/// fills the circle edge-to-edge.
class _SocialIconButton extends StatelessWidget {
  const _SocialIconButton({
    required this.assetPath,
    required this.isLoading,
    required this.enabled,
    required this.onPressed,
  });
  final String assetPath;
  final bool isLoading;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.greyscale_50),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: enabled ? onPressed : null,
          child: SizedBox(
            width: 56,
            height: 56,
            child: isLoading ? _buildSpinner() : _buildIcon(),
          ),
        ),
      ),
    );
  }

  Widget _buildSpinner() {
    return Container(
      color: AppColors.greyscale_25,
      alignment: Alignment.center,
      child: SizedBox(
        height: 18,
        width: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Image.asset(assetPath, fit: BoxFit.cover);
  }
}

/// The main green pill-shaped submit button with an inline loading spinner.
class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.isLoading,
    required this.enabled,
    required this.onPressed,
    required this.verticalPadding,
    required this.fontSize,
  });

  final String label;
  final bool isLoading;
  final bool enabled;
  final VoidCallback onPressed;
  final double verticalPadding;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow:
            enabled
                ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.22),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
                : [],
      ),
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: verticalPadding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
        child:
            isLoading
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : Text(
                  label,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
      ),
    );
  }
}

// ignore_for_file: unused_element_parameter

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MessageCall extends StatefulWidget {
  const MessageCall({
    super.key,
    this.doctorName = 'น.สพ. ดลชัย จงภักดี',
    this.doctorImage = 'assets/images/doctor.png',
    this.selfPreviewImage = 'assets/images/pet.jpg',
  });

  /// รูปพื้นหลังเต็มจอ (วิดีโอฝั่งหมอ) — เปลี่ยนเป็น widget ของ SDK
  /// วิดีโอจริง (agora/webrtc renderer) แทน Image.asset ได้ภายหลัง
  final String doctorName;
  final String doctorImage;

  /// รูปมุมเล็ก (self preview / กล้องฝั่งเรา)
  final String selfPreviewImage;

  @override
  State<MessageCall> createState() => _MessageCallState();
}

class _MessageCallState extends State<MessageCall> {
  Timer? _durationTimer;
  Duration _elapsed = Duration.zero;

  bool _cameraOn = true;
  bool _micOn = true;

  @override
  void initState() {
    super.initState();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    super.dispose();
  }

  String get _formattedDuration {
    final h = _elapsed.inHours;
    final m = _elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  void _toggleCamera() {
    HapticFeedback.selectionClick();
    setState(() => _cameraOn = !_cameraOn);
  }

  void _toggleMic() {
    HapticFeedback.selectionClick();
    setState(() => _micOn = !_micOn);
  }

  Future<void> _endCall() async {
    HapticFeedback.heavyImpact();
    _durationTimer?.cancel();
    // เล็กน้อยให้แอนิเมชันปุ่มวางสายเล่นจบก่อนค่อยออกจากหน้า
    await Future.delayed(const Duration(milliseconds: 160));
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ---- วิดีโอเต็มจอฝั่งคู่สนทนา ----
          _cameraOn
              ? Image.asset(
                widget.doctorImage,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) =>
                        Container(color: const Color(0xff2B2B2B)),
              )
              : Container(
                color: const Color(0xff1C1C1E),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.videocam_off_rounded,
                      color: Colors.white38,
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.doctorName,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

          // เงาไล่สีบนล่างให้ตัวหนังสือ/ปุ่มอ่านง่ายขึ้นบนวิดีโอสดใดๆ
          const _TopBottomScrim(),

          // ---- แถบเวลาโทร (มุมซ้ายบน) ----
          Positioned(
            top: 8,
            left: 16,
            child: SafeArea(
              bottom: false,
              child: _CallTimerBadge(duration: _formattedDuration),
            ),
          ),

          // ---- self preview มุมขวาบน ----
          Positioned(
            top: 8,
            right: 16,
            child: SafeArea(
              bottom: false,
              child: _SelfPreview(
                imagePath: widget.selfPreviewImage,
                cameraOn: _cameraOn,
              ),
            ),
          ),

          // ---- แถบควบคุมด้านล่าง ----
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 28, top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _CallControlButton(
                      icon:
                          _cameraOn
                              ? Icons.videocam_rounded
                              : Icons.videocam_off_rounded,
                      background: Colors.white.withOpacity(0.18),
                      iconColor: Colors.white,
                      onTap: _toggleCamera,
                    ),
                    const SizedBox(width: 28),
                    _HangUpButton(onTap: _endCall),
                    const SizedBox(width: 28),
                    _CallControlButton(
                      icon: _micOn ? Icons.mic_rounded : Icons.mic_off_rounded,
                      background: Colors.white.withOpacity(0.18),
                      iconColor: Colors.white,
                      onTap: _toggleMic,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// เงาไล่สีดำบาง ๆ บน-ล่าง ให้อ่านตัวหนังสือ/ปุ่มง่ายขึ้นบนพื้นวิดีโอ
class _TopBottomScrim extends StatelessWidget {
  const _TopBottomScrim();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Column(
        children: [
          Container(
            height: 110,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withOpacity(0.45), Colors.transparent],
              ),
            ),
          ),
          const Spacer(),
          Container(
            height: 160,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.5), Colors.transparent],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ป้ายจับเวลาสาย พร้อมจุดแดงกะพริบเบา ๆ แบบกำลังอัด/สาย
class _CallTimerBadge extends StatefulWidget {
  const _CallTimerBadge({required this.duration});

  final String duration;

  @override
  State<_CallTimerBadge> createState() => _CallTimerBadgeState();
}

class _CallTimerBadgeState extends State<_CallTimerBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _blinkController;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FadeTransition(
          opacity: Tween(begin: 0.3, end: 1.0).animate(_blinkController),
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xffFF4D4D),
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          widget.duration,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            shadows: [Shadow(color: Colors.black38, blurRadius: 4)],
          ),
        ),
      ],
    );
  }
}

/// กรอบ self preview มุมขวาบน
class _SelfPreview extends StatelessWidget {
  const _SelfPreview({required this.imagePath, required this.cameraOn});

  final String imagePath;
  final bool cameraOn;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xff3A3A3C),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child:
          cameraOn
              ? Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => const Center(
                      child: Icon(Icons.pets, color: Colors.white54),
                    ),
              )
              : const Center(
                child: Icon(
                  Icons.videocam_off_rounded,
                  color: Colors.white54,
                  size: 22,
                ),
              ),
    );
  }
}

/// ปุ่มควบคุมกล้อง/ไมค์ — มีลูกเล่นกดยุบตัวและสลับไอคอนแบบนุ่ม ๆ
class _CallControlButton extends StatefulWidget {
  const _CallControlButton({
    required this.icon,
    required this.background,
    required this.iconColor,
    required this.onTap,
    this.size = 56,
  });

  final IconData icon;
  final Color background;
  final Color iconColor;
  final VoidCallback onTap;
  final double size;

  @override
  State<_CallControlButton> createState() => _CallControlButtonState();
}

class _CallControlButtonState extends State<_CallControlButton> {
  bool _pressed = false;

  void _setPressed(bool value) => setState(() => _pressed = value);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.86 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.background,
          ),
          alignment: Alignment.center,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 160),
            transitionBuilder:
                (child, anim) => ScaleTransition(scale: anim, child: child),
            child: Icon(
              widget.icon,
              key: ValueKey(widget.icon),
              color: widget.iconColor,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}

/// ปุ่มวางสาย — สีแดง ยุบตัวแรงกว่าปุ่มอื่นตอนกด ให้ความรู้สึก "จบสาย" ชัดเจน
class _HangUpButton extends StatefulWidget {
  const _HangUpButton({required this.onTap});

  final Future<void> Function() onTap;

  @override
  State<_HangUpButton> createState() => _HangUpButtonState();
}

class _HangUpButtonState extends State<_HangUpButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.8 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xffFF4D4D),
            boxShadow: [
              BoxShadow(
                color: const Color(0xffFF4D4D).withOpacity(0.45),
                blurRadius: _pressed ? 4 : 14,
                spreadRadius: _pressed ? 0 : 1,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Transform.rotate(
            angle: 3.4, // ~135° ให้หูฟังชี้ลง เหมือนไอคอนวางสาย
            child: const Icon(
              Icons.call_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}

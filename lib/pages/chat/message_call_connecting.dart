import 'dart:async';

import 'package:bkkpet/pages/chat/message_call.dart';
import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';

class MessageCallConnectingPage extends StatefulWidget {
  const MessageCallConnectingPage({
    super.key,
    required this.doctorName,
    required this.doctorImage,
    this.selfPreviewImage = 'assets/images/pet.jpg',
  });

  final String doctorName;
  final String doctorImage;
  final String selfPreviewImage;

  @override
  State<MessageCallConnectingPage> createState() =>
      _MessageCallConnectingPageState();
}

class _MessageCallConnectingPageState extends State<MessageCallConnectingPage>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  late final AnimationController _pulseController;
  bool _isConnecting = true;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _timer = Timer(const Duration(seconds: 3), _connect);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    if (!mounted) return;
    setState(() => _isConnecting = false);
    await Future.delayed(const Duration(milliseconds: 550));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder:
            (_) => MessageCall(
              doctorName: widget.doctorName,
              doctorImage: widget.doctorImage,
              selfPreviewImage: widget.selfPreviewImage,
            ),
      ),
    );
  }

  Future<void> _cancel() async {
    _timer?.cancel();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            children: [
              const Spacer(),
              ScaleTransition(
                scale: Tween(begin: 0.96, end: 1.04).animate(
                  CurvedAnimation(
                    parent: _pulseController,
                    curve: Curves.easeInOut,
                  ),
                ),
                child: Container(
                  width: 126,
                  height: 126,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryLight.withValues(alpha: 0.18),
                    border: Border.all(color: AppColors.greyscale_200),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      widget.doctorImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.greyscale_50,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.medical_services_outlined,
                          color: AppColors.greyscale_400,
                          size: 42,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                widget.doctorName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.greyscale_900,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isConnecting ? 'กำลังโทร...' : 'กำลังเชื่อมต่อ',
                style: TextStyle(
                  color: AppColors.greyscale_400,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _Dot(delay: 0, controller: _pulseController),
                  const SizedBox(width: 8),
                  _Dot(delay: 1, controller: _pulseController),
                  const SizedBox(width: 8),
                  _Dot(delay: 2, controller: _pulseController),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'ระบบกำลังติดต่อปลายสายให้...',
                style: TextStyle(
                  color: AppColors.greyscale_400,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _cancel,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.greyscale_300),
                        foregroundColor: AppColors.greyscale_900,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('ยกเลิก'),
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
}

class _Dot extends StatelessWidget {
  const _Dot({required this.delay, required this.controller});

  final int delay;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final anim = Tween<double>(begin: 0.35, end: 1).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          0.15 * delay,
          0.6 + (0.15 * delay),
          curve: Curves.easeInOut,
        ),
      ),
    );
    return FadeTransition(
      opacity: anim,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

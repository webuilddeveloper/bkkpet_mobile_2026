import 'dart:async';
import 'dart:math';

import 'package:bkkpet/pages/chat/message_chat.dart';
import 'package:bkkpet/pages/consult/consult_page_models.dart';
import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';

class ConsultChatWaitingPage extends StatefulWidget {
  const ConsultChatWaitingPage({
    super.key,
    required this.petName,
    required this.petSpecies,
    required this.symptom,
    this.doctor,
  });

  final String petName;
  final String petSpecies;
  final String symptom;
  final ConsultDoctor? doctor;

  @override
  State<ConsultChatWaitingPage> createState() => _ConsultChatWaitingPageState();
}

class _ConsultChatWaitingPageState extends State<ConsultChatWaitingPage>
    with SingleTickerProviderStateMixin {
  Timer? _searchTimer;
  Timer? _handoffTimer;
  late final AnimationController _pulseController;
  late final ConsultDoctor _doctor;
  bool _foundDoctor = false;

  @override
  void initState() {
    super.initState();
    final random = Random();
    final availableDoctors =
        consultDoctors.where((doctor) => doctor.isOnlineNow).toList();
    _doctor =
        widget.doctor ??
        (availableDoctors.isNotEmpty
            ? availableDoctors[random.nextInt(availableDoctors.length)]
            : consultDoctors[random.nextInt(consultDoctors.length)]);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _searchTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _foundDoctor = true);
      _handoffTimer = Timer(const Duration(milliseconds: 1200), _openChat);
    });
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _handoffTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _openChat() async {
    if (!mounted) return;

    final initialMessages = <ChatMessage>[
      ChatMessage(
        text: 'สวัสดีครับ หมอได้รับข้อมูลอาการของ ${widget.petName} แล้วครับ',
        isMe: false,
      ),
      ChatMessage(
        text: 'อาการเบื้องต้น: ${widget.symptom}',
        isMe: true,
      ),
      ChatMessage(
        text: 'เดี๋ยวหมอช่วยประเมินอาการให้อย่างละเอียดครับ',
        isMe: false,
      ),
    ];

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder:
            (_) => MessageChatPage(
              doctorName: _doctor.name,
              profileImage: _doctor.imageUrl,
              isOnline: _doctor.isOnlineNow,
              initialMessages: initialMessages,
            ),
      ),
    );
  }

  Future<void> _cancel() async {
    _searchTimer?.cancel();
    _handoffTimer?.cancel();
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final titleText = _foundDoctor ? 'พบแพทย์แล้ว' : 'กำลังหาแพทย์';
    final subtitleText =
        _foundDoctor
            ? 'กำลังนำคุณเข้าสู่ห้องแชทของ ${_doctor.name}'
            : 'ระบบกำลังคัดเลือกแพทย์ที่เหมาะสมกับอาการของสัตว์เลี้ยง';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.greenlight.withValues(alpha: 0.6),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.verified_outlined,
                    size: 18,
                    color: AppColors.primarySecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ระบบกำลังตรวจสอบและคัดเลือกแพทย์ให้',
                      style: TextStyle(
                        color: AppColors.primarySecondary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    _foundDoctor ? 'เชื่อมต่อแล้ว' : 'กำลังค้นหา',
                    style: TextStyle(
                      color: AppColors.greyscale_400,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ScaleTransition(
                scale: Tween(begin: 0.985, end: 1.015).animate(
                  CurvedAnimation(
                    parent: _pulseController,
                    curve: Curves.easeInOut,
                  ),
                ),
                child: Container(
                  width: 136,
                  height: 136,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: AppColors.greyscale_200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      _doctor.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.greyscale_50,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.medical_services_outlined,
                          color: AppColors.greyscale_300,
                          size: 42,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              titleText,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.greyscale_900,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitleText,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.greyscale_400,
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.greyscale_200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'รายละเอียดการค้นหา',
                        style: TextStyle(
                          color: AppColors.greyscale_900,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _foundDoctor ? 'เตรียมเปิดแชท' : 'กำลังประมวลผล',
                        style: TextStyle(
                          color: AppColors.primarySecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 8,
                      value: _foundDoctor ? 1 : null,
                      backgroundColor: AppColors.greyscale_50,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _foundDoctor ? AppColors.greenlight : AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatusCard(
                          title: 'สัตว์เลี้ยง',
                          value: widget.petName,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatusCard(
                          title: 'อาการ',
                          value: widget.symptom,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.greyscale_25,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.greyscale_200),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.asset(
                            _doctor.imageUrl,
                            width: 54,
                            height: 54,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 54,
                              height: 54,
                              color: AppColors.greyscale_50,
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.medical_services_outlined,
                                color: AppColors.greyscale_300,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _doctor.name,
                                style: TextStyle(
                                  color: AppColors.greyscale_900,
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_doctor.specialty} • ${_doctor.clinic}',
                                style: TextStyle(
                                  color: AppColors.greyscale_400,
                                  fontSize: 12.4,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withValues(alpha: 0.24),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            _doctor.isOnlineNow ? 'ออนไลน์' : 'รอออนไลน์',
                            style: TextStyle(
                              color: AppColors.primarySecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
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
            const SizedBox(height: 12),
            Text(
              _foundDoctor
                  ? 'กำลังพาไปยังห้องแชท...'
                  : 'ระบบกำลังค้นหาแพทย์ที่เหมาะสมให้คุณ',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.greyscale_400,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.title,
    required this.value,
    this.maxLines = 1,
  });

  final String title;
  final String value;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyscale_200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.greyscale_400,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.greyscale_900,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:io';

import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';

class ChatThreadInfoPage extends StatefulWidget {
  const ChatThreadInfoPage({
    super.key,
    required this.doctorName,
    required this.profileImage,
    required this.isOnline,
    required this.isMuted,
    required this.sentImages,
    required this.onMutedChanged,
  });

  final String doctorName;
  final String profileImage;
  final bool isOnline;
  final bool isMuted;
  final List<String> sentImages;
  final ValueChanged<bool> onMutedChanged;

  @override
  State<ChatThreadInfoPage> createState() => _ChatThreadInfoPageState();
}

class _ChatThreadInfoPageState extends State<ChatThreadInfoPage> {
  late bool _muted;

  @override
  void initState() {
    super.initState();
    _muted = widget.isMuted;
  }

  void _toggleMuted(bool value) {
    setState(() => _muted = value);
    widget.onMutedChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final panelWidth = width * 0.84;

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.42),
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const SizedBox.expand(),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: panelWidth,
                height: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    bottomLeft: Radius.circular(24),
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'ข้อมูลห้องแชท',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.greyscale_900,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close_rounded),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _HeaderCard(
                          doctorName: widget.doctorName,
                          profileImage: widget.profileImage,
                          isOnline: widget.isOnline,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          children: [
                            _SectionTitle(
                              title: 'การแจ้งเตือน',
                              subtitle: 'ตั้งค่าห้องแชทนี้ได้ตามต้องการ',
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.greyscale_25,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.greyscale_200),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _muted
                                              ? 'ปิดแจ้งเตือนแล้ว'
                                              : 'เปิดแจ้งเตือนอยู่',
                                          style: TextStyle(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.greyscale_900,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _muted
                                              ? 'จะไม่แสดงการแจ้งเตือนจากห้องนี้'
                                              : 'จะได้รับการแจ้งเตือนจากห้องนี้ตามปกติ',
                                          style: TextStyle(
                                            fontSize: 12.3,
                                            height: 1.4,
                                            color: AppColors.greyscale_400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch.adaptive(
                                    value: _muted,
                                    activeThumbColor: AppColors.primary,
                                    activeTrackColor: AppColors.primaryLight,
                                    onChanged: _toggleMuted,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                            _SectionTitle(
                              title: 'รูปที่ส่งในแชท',
                              subtitle: 'ดูรูปทั้งหมดที่ส่งถึงกันในห้องนี้',
                            ),
                            if (widget.sentImages.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.greyscale_25,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.greyscale_200),
                                ),
                                child: Text(
                                  'ยังไม่มีรูปที่ส่งในห้องแชทนี้',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.greyscale_400,
                                  ),
                                ),
                              )
                            else
                              GridView.builder(
                                itemCount: widget.sentImages.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8,
                                      childAspectRatio: 0.92,
                                    ),
                                itemBuilder: (context, index) {
                                  final path = widget.sentImages[index];
                                  return GestureDetector(
                                    onTap: () => _openImage(context, path),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Image.file(
                                        File(path),
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (_, __, ___) => Container(
                                              color: AppColors.greyscale_25,
                                              alignment: Alignment.center,
                                              child: const Icon(
                                                Icons.broken_image_outlined,
                                              ),
                                            ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openImage(BuildContext context, String path) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) {
        return GestureDetector(
          onTap: () => Navigator.pop(ctx),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: InteractiveViewer(child: Image.file(File(path))),
            ),
          ),
        );
      },
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.doctorName,
    required this.profileImage,
    required this.isOnline,
  });

  final String doctorName;
  final String profileImage;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.greyscale_200),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              profileImage,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) => Container(
                    width: 60,
                    height: 60,
                    color: AppColors.greyscale_50,
                    alignment: Alignment.center,
                    child: const Icon(Icons.person, color: AppColors.greyscale_400),
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctorName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.greyscale_900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isOnline ? 'ออนไลน์อยู่ตอนนี้' : 'ออฟไลน์',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isOnline ? AppColors.greenlight : AppColors.greyscale_400,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: AppColors.greyscale_900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12.3,
              color: AppColors.greyscale_400,
            ),
          ),
        ],
      ),
    );
  }
}

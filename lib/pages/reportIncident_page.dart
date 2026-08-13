import 'package:bkkpet/blank_page/appbar.dart';
import 'package:bkkpet/blank_page/app_media_icon.dart';
import 'package:bkkpet/blank_page/incident_input_widgets.dart';
import 'package:bkkpet/pages/report_incident/report_incident_form_page.dart';
import 'package:bkkpet/pages/report_incident/report_incident_tracking_page.dart';
import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';

class ReportIncidentPage extends StatelessWidget {
  const ReportIncidentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarMainApp(
        title: 'แจ้งเหตุ',
        onBack: () => Navigator.pop(context),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          const IncidentNoticeBanner(
            title: 'หมายเหตุ',
            message:
                'หน้านี้ใช้เลือกทางเข้าใช้งานก่อนส่งเรื่องหรือเช็กสถานะเรื่องเดิม',
            icon: Icons.info_outline_rounded,
            showAction: false,
          ),
          _ActionCard(
            icon: Icons.edit_note_rounded,
            title: 'ส่งเรื่องใหม่',
            subtitle:
                'แจ้งพบสุนัขจร แมวจร สัตว์ป่วย สัตว์ดุร้าย หรือสัตว์ตายผิดปกติ พร้อมปักหมุดและแนบวิดีโอ',
            buttonLabel: 'เริ่มส่งเรื่อง',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ReportIncidentFormPage(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _ActionCard(
            icon: Icons.history_rounded,
            title: 'ติดตามสถานะ',
            subtitle:
                'ดูรายการเรื่องที่แจ้งไว้ก่อนหน้า และเปิดรายละเอียดของแต่ละเรื่องเพื่อเช็กความคืบหน้า',
            buttonLabel: 'ดูรายการแจ้ง',
            outlined: true,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ReportIncidentTrackingPage(),
                ),
              );
            },
          ),
          const SizedBox(height: 18),
          const Text(
            'สิ่งที่ทำได้',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.greyscale_900,
            ),
          ),
          const SizedBox(height: 10),
          const _FeatureBullet(
            icon: Icons.location_on_rounded,
            text: 'ปักหมุดตำแหน่งปัจจุบันอัตโนมัติ',
          ),
          const _FeatureBullet(
            icon: Icons.videocam_rounded,
            iconAsset: appVideoGalleryIconAsset,
            text: 'แนบวิดีโอจากกล้องหรือคลังในเครื่อง ',
          ),
          const _FeatureBullet(
            icon: Icons.priority_high_rounded,
            text: 'เลือกความเร่งด่วนของเหตุได้',
          ),
          const _FeatureBullet(
            icon: Icons.timeline_rounded,
            text: 'ติดตามสถานะและดูประวัติการอัปเดต',
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onPressed,
    this.outlined = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onPressed;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.greyscale_200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color:
                      outlined
                          ? AppColors.greyscale_50
                          : AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: outlined ? AppColors.primary : AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.greyscale_900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12.5,
                        height: 1.45,
                        color: AppColors.greyscale_400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 48,
            child:
                outlined
                    ? OutlinedButton(
                      onPressed: onPressed,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.35),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        buttonLabel,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    )
                    : ElevatedButton(
                      onPressed: onPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        buttonLabel,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}

class _FeatureBullet extends StatelessWidget {
  const _FeatureBullet({
    required this.icon,
    required this.text,
    this.iconAsset,
  });

  final IconData icon;
  final String? iconAsset;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child:
                iconAsset == null
                    ? Icon(icon, size: 16, color: AppColors.primary)
                    : Padding(
                      padding: const EdgeInsets.all(6),
                      child: AppMediaIcon(
                        asset: iconAsset!,
                        fallbackIcon: icon,
                        size: 16,
                      ),
                    ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: AppColors.greyscale_800),
            ),
          ),
        ],
      ),
    );
  }
}

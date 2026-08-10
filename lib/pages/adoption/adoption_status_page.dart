import 'package:bkkpet/blank_page/appbar.dart';
import 'package:bkkpet/pages/adoption/adoption_models.dart';
import 'package:bkkpet/pages/adoption/adoption_storage.dart';
import 'package:bkkpet/pages/adoption/adoption_ui_kit.dart';
import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';

class AdoptionStatusPage extends StatefulWidget {
  const AdoptionStatusPage({super.key, required this.application});

  final AdoptionApplication application;

  @override
  State<AdoptionStatusPage> createState() => _AdoptionStatusPageState();
}

class _AdoptionStatusPageState extends State<AdoptionStatusPage> {
  static const _steps = [
    AdoptionStatus.submitted,
    AdoptionStatus.appointment,
    AdoptionStatus.review,
    AdoptionStatus.approved,
    AdoptionStatus.completed,
  ];

  Future<void> _saveCurrentState() async {
    await AdoptionStorage.upsertApplication(widget.application);
    if (widget.application.status == AdoptionStatus.completed) {
      await AdoptionStorage.upsertFromApplication(widget.application);
    }
  }

  Future<void> _changeStatus(AdoptionStatus status) async {
    setState(() {
      widget.application.status = status;
    });
    await _saveCurrentState();
    if (mounted) setState(() {});
  }

  Future<void> _advanceStatus() async {
    final currentIndex = _steps.indexOf(widget.application.status);
    if (currentIndex < 0 || currentIndex >= _steps.length - 1) return;
    await _changeStatus(_steps[currentIndex + 1]);
  }

  @override
  Widget build(BuildContext context) {
    final pet = widget.application.pet;
    final currentIndex = _steps.indexOf(widget.application.status);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarMainApp(
        title: 'ติดตามสถานะการรับเลี้ยง',
        onBack: () => Navigator.pop(context),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.greyscale_200),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AdoptionPetAvatarPlaceholder(
                    species: pet.species,
                    imageAsset: pet.imageAsset,
                    height: 60,
                    borderRadius: 12,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.greyscale_900,
                        ),
                      ),
                      Text(
                        '${pet.breed} · ${pet.gender} · ${pet.ageLabel}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.greyscale_400,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          widget.application.status.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
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
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.greyscale_200),
            ),
            child: Column(
              children: [
                Align(
                  alignment: AlignmentGeometry.topRight,
                  child: TextButton(
                    onPressed:
                        widget.application.status == AdoptionStatus.completed
                            ? null
                            : _advanceStatus,
                    child: Text(
                      widget.application.status == AdoptionStatus.completed
                          ? 'เสร็จแล้ว'
                          : 'อัปเดตถัดไป',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color:
                            widget.application.status ==
                                    AdoptionStatus.completed
                                ? AppColors.greyscale_300
                                : AppColors.primary,
                      ),
                    ),
                  ),
                ),
                for (int i = 0; i < _steps.length; i++)
                  _StatusStepRow(
                    step: _steps[i],
                    state:
                        i < currentIndex
                            ? _StepState.done
                            : i == currentIndex
                            ? _StepState.current
                            : _StepState.upcoming,
                    isLast: i == _steps.length - 1,
                    detail: _detailFor(_steps[i], widget.application),
                  ),
              ],
            ),
          ),
          if (widget.application.status == AdoptionStatus.appointment) ...[
            const SizedBox(height: 14),
            _InfoBanner(
              icon: Icons.event_available_outlined,
              text:
                  'นัดดูตัวสัตว์เลี้ยงที่ ${widget.application.appointmentLocation}'
                  '${widget.application.appointmentTimeSlot != null ? ' ช่วง ${widget.application.appointmentTimeSlot}' : ''}',
            ),
          ],
          // const SizedBox(height: 14),
          // AdoptionSectionCard(
          //   icon: Icons.tips_and_updates_outlined,
          //   title: 'อัปเดตเล็กๆ',
          //   trailing: TextButton(
          //     onPressed:
          //         widget.application.status == AdoptionStatus.completed
          //             ? null
          //             : _advanceStatus,
          //     child: Text(
          //       widget.application.status == AdoptionStatus.completed
          //           ? 'เสร็จแล้ว'
          //           : 'อัปเดตถัดไป',
          //       style: TextStyle(
          //         fontSize: 12,
          //         fontWeight: FontWeight.w700,
          //         color:
          //             widget.application.status == AdoptionStatus.completed
          //                 ? AppColors.greyscale_300
          //                 : AppColors.primary,
          //       ),
          //     ),
          //   ),
          //   children: [
          //     Text(
          //       'กดปุ่มด้านขวาเพื่อขยับสถานะทีละขั้น เหมือนการอัปเดตผลในหน้าแจ้งเหตุ',
          //       style: TextStyle(
          //         fontSize: 12.5,
          //         height: 1.45,
          //         color: AppColors.greyscale_400,
          //       ),
          //     ),
          //     const SizedBox(height: 10),
          //     Container(
          //       padding: const EdgeInsets.symmetric(
          //         horizontal: 12,
          //         vertical: 10,
          //       ),
          //       decoration: BoxDecoration(
          //         color: AppColors.greyscale_25,
          //         borderRadius: BorderRadius.circular(12),
          //         border: Border.all(color: AppColors.greyscale_200),
          //       ),
          //       child: Row(
          //         children: [
          //           Icon(
          //             Icons.info_outline_rounded,
          //             size: 18,
          //             color: AppColors.primary,
          //           ),
          //           const SizedBox(width: 8),
          //           Expanded(
          //             child: Text(
          //               'สถานะปัจจุบัน: ${widget.application.status.label}',
          //               style: TextStyle(
          //                 fontSize: 12.5,
          //                 fontWeight: FontWeight.w600,
          //                 color: AppColors.greyscale_800,
          //               ),
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ],
          // ),
          const SizedBox(height: 14),
          AdoptionSectionCard(
            icon: Icons.support_agent_outlined,
            title: 'ต้องการความช่วยเหลือ',
            children: [
              Text(
                'ติดต่อศูนย์บริการสัตวแพทย์สาธารณสุข กทม.',
                style: TextStyle(fontSize: 12, color: AppColors.greyscale_800),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.call_outlined, size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    '02-xxx-xxxx',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _detailFor(AdoptionStatus step, AdoptionApplication app) {
    switch (step) {
      case AdoptionStatus.submitted:
        return 'ระบบได้รับใบสมัครของคุณแล้ว';
      case AdoptionStatus.appointment:
        return app.appointmentDate != null
            ? 'นัดหมายดูตัวเรียบร้อยแล้ว'
            : 'รอเลือกวันเวลานัดดูตัว';
      case AdoptionStatus.review:
        return 'เจ้าหน้าที่กำลังพิจารณาความเหมาะสมของผู้รับเลี้ยง';
      case AdoptionStatus.approved:
        return 'ผ่านการพิจารณา เตรียมรับสัตว์เลี้ยงกลับบ้านได้เลย';
      case AdoptionStatus.completed:
        return 'รับเลี้ยงสำเร็จ ยินดีด้วยกับสมาชิกใหม่ในครอบครัว';
    }
  }
}

enum _StepState { done, current, upcoming }

class _StatusStepRow extends StatelessWidget {
  const _StatusStepRow({
    required this.step,
    required this.state,
    required this.isLast,
    required this.detail,
  });

  final AdoptionStatus step;
  final _StepState state;
  final bool isLast;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final color =
        state == _StepState.upcoming
            ? AppColors.greyscale_300
            : AppColors.primary;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      state == _StepState.upcoming
                          ? Colors.white
                          : AppColors.primary,
                  border: Border.all(color: color, width: 1.6),
                ),
                child: Icon(
                  state == _StepState.done
                      ? Icons.check
                      : state == _StepState.current
                      ? Icons.radio_button_checked
                      : Icons.circle_outlined,
                  size: 14,
                  color: state == _StepState.upcoming ? color : Colors.white,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color:
                        state == _StepState.done
                            ? AppColors.primary
                            : AppColors.greyscale_200,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color:
                          state == _StepState.upcoming
                              ? AppColors.greyscale_400
                              : AppColors.greyscale_900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    detail,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.greyscale_400,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primarySecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

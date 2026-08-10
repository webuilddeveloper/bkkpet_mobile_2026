import 'package:bkkpet/blank_page/appbar.dart';
import 'package:bkkpet/blank_page/custom_dialog.dart';
import 'package:bkkpet/blank_page/incident_input_widgets.dart';
import 'package:bkkpet/pages/adoption/adoption_models.dart';
import 'package:bkkpet/pages/adoption/adoption_ui_kit.dart';
import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';

class AdoptionFollowUpPage extends StatefulWidget {
  const AdoptionFollowUpPage({super.key, required this.application});

  final AdoptionApplication application;

  @override
  State<AdoptionFollowUpPage> createState() => _AdoptionFollowUpPageState();
}

class _AdoptionFollowUpPageState extends State<AdoptionFollowUpPage> {
  late final List<FollowUpCheckpoint> _checkpoints = [
    FollowUpCheckpoint(
      label: 'ติดตามครั้งที่ 1',
      dueDayLabel: '7 วันหลังรับเลี้ยง',
    ),
    FollowUpCheckpoint(
      label: 'ติดตามครั้งที่ 2',
      dueDayLabel: '30 วันหลังรับเลี้ยง',
    ),
    FollowUpCheckpoint(
      label: 'ติดตามครั้งที่ 3',
      dueDayLabel: '90 วันหลังรับเลี้ยง',
    ),
  ];

  Future<void> _openCheckpoint(FollowUpCheckpoint checkpoint) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => _FollowUpForm(
            pet: widget.application.pet,
            checkpoint: checkpoint,
          ),
    );
    if (result == true) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final pet = widget.application.pet;
    final completedCount = _checkpoints.where((c) => c.completed).length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarMainApp(
        title: 'ติดตามหลังรับเลี้ยง',
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
                    height: 56,
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
                        'ทำแบบติดตามแล้ว $completedCount / ${_checkpoints.length} ครั้ง',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.greyscale_400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Text(
            'กำหนดการติดตาม',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.greyscale_900,
            ),
          ),
          const SizedBox(height: 10),

          for (final checkpoint in _checkpoints)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => _openCheckpoint(checkpoint),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color:
                          checkpoint.completed
                              ? AppColors.primary
                              : AppColors.greyscale_200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color:
                              checkpoint.completed
                                  ? AppColors.primary.withValues(alpha: 0.12)
                                  : AppColors.greyscale_50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          checkpoint.completed
                              ? Icons.check_circle
                              : Icons.assignment_outlined,
                          size: 18,
                          color:
                              checkpoint.completed
                                  ? AppColors.primary
                                  : AppColors.greyscale_400,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              checkpoint.label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.greyscale_900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              checkpoint.completed
                                  ? 'ส่งแบบติดตามแล้ว'
                                  : 'กำหนด: ${checkpoint.dueDayLabel}',
                              style: TextStyle(
                                fontSize: 11,
                                color:
                                    checkpoint.completed
                                        ? AppColors.primary
                                        : AppColors.greyscale_400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: AppColors.greyscale_300,
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

// ================================================================
// แบบฟอร์มติดตามหลังรับเลี้ยง (ต่อ checkpoint)
// ================================================================

class _FollowUpForm extends StatefulWidget {
  const _FollowUpForm({required this.pet, required this.checkpoint});

  final AdoptionPet pet;
  final FollowUpCheckpoint checkpoint;

  @override
  State<_FollowUpForm> createState() => _FollowUpFormState();
}

class _FollowUpFormState extends State<_FollowUpForm> {
  final _noteCtrl = TextEditingController();

  String _condition = 'สุขภาพแข็งแรงดี';
  SharedPickedMedia? _photo;
  bool _saving = false;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _saving = true);
    // TODO: เรียก API บันทึกผลการติดตามจริง
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    widget.checkpoint
      ..completed = true
      ..petCondition = _condition
      ..note = _noteCtrl.text.trim();

    setState(() => _saving = false);

    await showInfoDialog(
      context: context,
      icon: Icons.check_circle_outline_rounded,
      title: 'ส่งแบบติดตามสำเร็จ',
      message: 'ขอบคุณที่แจ้งความคืบหน้าการเลี้ยงดู "${widget.pet.name}"',
      color: AppColors.primary,
    );
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.greyscale_200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${widget.checkpoint.label} · ${widget.checkpoint.dueDayLabel}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.greyscale_900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  children: [
                    Text(
                      'สภาพความเป็นอยู่ของ ${widget.pet.name}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.greyscale_900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AdoptionDropdown(
                      label: 'สุขภาพและความเป็นอยู่โดยรวม',
                      value: _condition,
                      options: const [
                        'สุขภาพแข็งแรงดี',
                        'มีอาการป่วยเล็กน้อย',
                        'ต้องพบสัตวแพทย์',
                        'ปรับตัวเข้ากับบ้านใหม่ได้ดี',
                      ],
                      onChanged: (v) => setState(() => _condition = v),
                    ),
                    AdoptionFormField(
                      label: 'บันทึกเพิ่มเติม',
                      controller: _noteCtrl,
                      hint:
                          'พฤติกรรม การกินอาหาร การปรับตัว หรือข้อสังเกตอื่น ๆ',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 4),
                    SharedMediaPickerField(
                      title: 'แนบรูปถ่ายล่าสุด',
                      subtitle: 'แตะเพื่อเลือกรูปภาพจากคลังหรือถ่ายใหม่',
                      allowVideo: false,
                      initialValue: _photo,
                      onChanged: (value) => setState(() => _photo = value),
                    ),
                  ],
                ),
              ),
              AdoptionBottomBar(
                child: AdoptionPrimaryButton(
                  label: 'ส่งแบบติดตาม',
                  loading: _saving,
                  onPressed: _saving ? null : _submit,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

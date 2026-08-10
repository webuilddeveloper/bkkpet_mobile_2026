import 'package:bkkpet/blank_page/appbar.dart';
import 'package:bkkpet/blank_page/custom_dialog.dart';
import 'package:bkkpet/pages/adoption/adoption_appointment_page.dart';
import 'package:bkkpet/pages/adoption/adoption_models.dart';
import 'package:bkkpet/pages/adoption/adoption_storage.dart';
import 'package:bkkpet/pages/adoption/adoption_ui_kit.dart';
import 'package:bkkpet/services/mock_user_store.dart';
import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AdoptionApplicationPage extends StatefulWidget {
  const AdoptionApplicationPage({super.key, required this.application});

  final AdoptionApplication application;

  @override
  State<AdoptionApplicationPage> createState() =>
      _AdoptionApplicationPageState();
}

class _AdoptionApplicationPageState extends State<AdoptionApplicationPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _idCardCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _otherPetsDetailCtrl = TextEditingController();
  final _experienceCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();

  String _residenceType = 'บ้านเดี่ยว';
  bool _ownResidence = true;
  bool _hasYard = false;
  bool _familyAgrees = true;
  bool _hasOtherPets = false;
  bool _agreeFollowUp = false;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final owner = MockUserStore.owner;
    _nameCtrl.text = owner.fullName;
    _idCardCtrl.text = owner.idCard;
    _phoneCtrl.text = owner.phone;
    _addressCtrl.text =
        '${owner.address} ${owner.subdistrict} ${owner.district} ${owner.province} ${owner.zipCode}';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _idCardCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _otherPetsDetailCtrl.dispose();
    _experienceCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final formOk = _formKey.currentState?.validate() ?? false;
    if (!formOk) {
      await showInfoDialog(
        context: context,
        icon: Icons.error_outline_rounded,
        title: 'ข้อมูลไม่ครบถ้วน',
        message: 'กรุณากรอกข้อมูลที่จำเป็น (ช่องที่มีเครื่องหมาย *) ให้ครบถ้วน',
        color: Colors.redAccent,
      );
      return;
    }
    if (!_agreeFollowUp) {
      await showInfoDialog(
        context: context,
        icon: Icons.error_outline_rounded,
        title: 'กรุณายืนยันการยินยอม',
        message: 'กรุณากดยอมรับการติดตามผลหลังรับเลี้ยงก่อนส่งใบสมัคร',
        color: Colors.redAccent,
      );
      return;
    }

    await showConfirmDialog(
      context: context,
      icon: Icons.help_outline_rounded,
      title: 'ยืนยันการส่งใบสมัคร',
      message:
          'ตรวจสอบข้อมูลเรียบร้อยแล้วใช่หรือไม่?\nขั้นตอนถัดไปคือนัดหมายดูตัวสัตว์เลี้ยง',
      confirmText: 'ส่งใบสมัคร',
      confirmColor: AppColors.primary,
      onConfirm: _save,
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    // TODO: เรียก API บันทึกใบสมัครจริง
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    final app = widget.application;
    app.applicantName = _nameCtrl.text.trim();
    app.applicantIdCard = _idCardCtrl.text.trim();
    app.applicantPhone = _phoneCtrl.text.trim();
    app.applicantAddress = _addressCtrl.text.trim();
    app.residenceType = _residenceType;
    app.ownResidence = _ownResidence;
    app.hasYard = _hasYard;
    app.familyAgrees = _familyAgrees;
    app.hasOtherPets = _hasOtherPets;
    app.otherPetsDetail = _otherPetsDetailCtrl.text.trim();
    app.experience = _experienceCtrl.text.trim();
    app.reason = _reasonCtrl.text.trim();
    app.agreeFollowUp = _agreeFollowUp;
    app.status = AdoptionStatus.submitted;

    await AdoptionStorage.upsertApplication(app);
    if (!mounted) return;
    setState(() => _saving = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AdoptionAppointmentPage(application: app),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pet = widget.application.pet;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarMainApp(
        title: 'สมัครขอรับเลี้ยง',
        onBack: () => Navigator.pop(context),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.greyscale_200),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: AdoptionPetAvatarPlaceholder(
                              species: pet.species,
                              imageAsset: pet.imageAsset,
                              borderRadius: 10,
                            ),
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
                                  fontSize: 14,
                                  color: AppColors.greyscale_900,
                                ),
                              ),
                              Text(
                                '${pet.breed} · ${pet.gender} · ${pet.ageLabel}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.greyscale_400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  AdoptionSectionCard(
                    icon: Icons.person_outline,
                    title: 'ข้อมูลผู้สมัคร',
                    children: [
                      AdoptionFormField(
                        label: 'ชื่อ-นามสกุล',
                        controller: _nameCtrl,
                        hint: 'กรอกชื่อ-นามสกุลผู้สมัคร',
                        icon: Icons.badge_outlined,
                        required: true,
                      ),
                      AdoptionFormField(
                        label: 'เลขบัตรประชาชน',
                        controller: _idCardCtrl,
                        hint: 'x-xxxx-xxxxx-xx-x',
                        icon: Icons.credit_card_outlined,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(13),
                        ],
                        required: true,
                      ),
                      AdoptionFormField(
                        label: 'เบอร์โทรศัพท์',
                        controller: _phoneCtrl,
                        hint: '08xxxxxxxx',
                        icon: Icons.call_outlined,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        required: true,
                      ),
                      AdoptionFormField(
                        label: 'ที่อยู่ปัจจุบัน',
                        controller: _addressCtrl,
                        hint: 'บ้านเลขที่ / หมู่ / ซอย / ถนน / แขวง / เขต',
                        icon: Icons.home_outlined,
                        maxLines: 2,
                        required: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  AdoptionSectionCard(
                    icon: Icons.house_outlined,
                    title: 'ลักษณะที่พักอาศัย',
                    children: [
                      AdoptionDropdown(
                        label: 'ประเภทที่พัก',
                        value: _residenceType,
                        options: const [
                          'บ้านเดี่ยว',
                          'ทาวน์เฮาส์',
                          'คอนโดมิเนียม',
                          'อพาร์ตเมนต์/หอพัก',
                        ],
                        onChanged: (v) => setState(() => _residenceType = v),
                      ),
                      AdoptionCheckRow(
                        label: 'เป็นที่พักของตนเอง (ไม่ใช่เช่า)',
                        value: _ownResidence,
                        onChanged: (v) => setState(() => _ownResidence = v),
                      ),
                      AdoptionCheckRow(
                        label: 'มีพื้นที่สนามหรือระเบียงให้สัตว์เดินเล่น',
                        value: _hasYard,
                        onChanged: (v) => setState(() => _hasYard = v),
                      ),
                      AdoptionCheckRow(
                        label: 'สมาชิกในบ้านทุกคนยินยอมให้เลี้ยง',
                        value: _familyAgrees,
                        onChanged: (v) => setState(() => _familyAgrees = v),
                      ),
                      AdoptionCheckRow(
                        label: 'มีสัตว์เลี้ยงอื่นอยู่แล้วในบ้าน',
                        value: _hasOtherPets,
                        onChanged: (v) => setState(() => _hasOtherPets = v),
                      ),
                      if (_hasOtherPets)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: AdoptionFormField(
                            label: 'รายละเอียดสัตว์เลี้ยงที่มีอยู่',
                            controller: _otherPetsDetailCtrl,
                            hint: 'ชนิด พันธุ์ จำนวน และการทำหมัน/วัคซีน',
                            maxLines: 2,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  AdoptionSectionCard(
                    icon: Icons.edit_note_outlined,
                    title: 'ประสบการณ์และเหตุผล',
                    children: [
                      AdoptionFormField(
                        label: 'ประสบการณ์การเลี้ยงสัตว์',
                        controller: _experienceCtrl,
                        hint: 'เคยเลี้ยงสัตว์ชนิดใดมาก่อนบ้าง',
                        maxLines: 2,
                      ),
                      AdoptionFormField(
                        label: 'เหตุผลที่ต้องการรับเลี้ยง',
                        controller: _reasonCtrl,
                        hint: 'บอกเราสั้น ๆ ว่าทำไมถึงอยากรับเลี้ยงตัวนี้',
                        maxLines: 3,
                        required: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.greyscale_200),
                    ),
                    child: AdoptionCheckRow(
                      label:
                          'ยินยอมให้เจ้าหน้าที่ติดตามผลการเลี้ยงดูหลังรับเลี้ยงตามระยะที่กำหนด',
                      value: _agreeFollowUp,
                      onChanged: (v) => setState(() => _agreeFollowUp = v),
                    ),
                  ),
                ],
              ),
            ),
            AdoptionBottomBar(
              child: AdoptionPrimaryButton(
                label: 'ส่งใบสมัครและนัดดูตัว',
                loading: _saving,
                onPressed: _saving ? null : _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

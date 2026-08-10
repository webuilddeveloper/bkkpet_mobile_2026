import 'package:bkkpet/blank_page/appbar.dart';
import 'package:bkkpet/blank_page/custom_dialog.dart';
import 'package:bkkpet/blank_page/shared_thai_date_picker.dart';
import 'package:bkkpet/pages/adoption/adoption_ui_kit.dart';
import 'package:bkkpet/pages/consult/consult_booking_detail_page.dart';
import 'package:bkkpet/pages/consult/consult_booking_model.dart';
import 'package:bkkpet/pages/consult/consult_booking_storage.dart';
import 'package:bkkpet/pages/consult/consult_page_models.dart';
import 'package:bkkpet/services/mock_user_store.dart';
import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';

class ConsultBookingPage extends StatefulWidget {
  const ConsultBookingPage({super.key, required this.doctor});

  final ConsultDoctor doctor;

  @override
  State<ConsultBookingPage> createState() => _ConsultBookingPageState();
}

class _ConsultBookingPageState extends State<ConsultBookingPage> {
  final _formKey = GlobalKey<FormState>();
  final _noteCtrl = TextEditingController();
  DateTime? _bookingDate;
  String? _timeSlot;
  String _consultType = 'แชท';
  String? _selectedPetId;
  bool _saving = false;

  final List<String> _timeSlots = const [
    '09:00 - 10:00',
    '10:00 - 11:00',
    '11:00 - 12:00',
    '13:00 - 14:00',
    '14:00 - 15:00',
    '15:00 - 16:00',
  ];

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final formOk = _formKey.currentState?.validate() ?? false;
    if (_selectedPetId == null) {
      await showInfoDialog(
        context: context,
        icon: Icons.error_outline_rounded,
        title: 'ยังไม่ได้เลือกสัตว์เลี้ยง',
        message: 'กรุณาเลือกสัตว์เลี้ยงที่ต้องการปรึกษา',
        color: Colors.redAccent,
      );
      return;
    }
    if (_bookingDate == null || _timeSlot == null) {
      await showInfoDialog(
        context: context,
        icon: Icons.error_outline_rounded,
        title: 'ยังไม่ได้เลือกวันเวลา',
        message: 'กรุณาเลือกวันที่และช่วงเวลาที่ต้องการจองนัด',
        color: Colors.redAccent,
      );
      return;
    }
    if (!formOk) return;

    await showConfirmDialog(
      context: context,
      icon: Icons.help_outline_rounded,
      title: 'ยืนยันการจองนัด',
      message:
          'ตรวจสอบข้อมูลเรียบร้อยแล้วใช่หรือไม่?\nต้องการยืนยันการจองนัดปรึกษาสัตวแพทย์นี้',
      confirmText: 'ยืนยันการจอง',
      confirmColor: AppColors.primary,
      onConfirm: _saveBooking,
    );
  }

  Future<void> _saveBooking() async {
    setState(() => _saving = true);
    final pet = MockUserStore.pets.firstWhere((p) => p.id == _selectedPetId);
    final now = DateTime.now();
    final record = ConsultBookingRecord(
      id: 'CT${now.microsecondsSinceEpoch % 1000000}',
      doctorId: widget.doctor.id,
      doctorName: widget.doctor.name,
      doctorImage: widget.doctor.imageUrl,
      specialty: widget.doctor.specialty,
      clinicName: widget.doctor.clinic,
      consultType: _consultType,
      petId: pet.id,
      petName: pet.name,
      petSpecies: pet.species,
      bookingDateIso: _bookingDate!.toIso8601String(),
      timeSlot: _timeSlot!,
      note: _noteCtrl.text.trim(),
      createdAtIso: now.toIso8601String(),
    );
    await ConsultBookingStorage.add(record);
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder:
            (_) => ConsultBookingDetailPage(record: record, justBooked: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarMainApp(
        title: 'จองนัดปรึกษา',
        onBack: () => Navigator.pop(context),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _DoctorSummary(doctor: widget.doctor),
            const SizedBox(height: 16),
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
                'เลือกสัตว์เลี้ยง วันที่ เวลา และระบุอาการให้ครบก่อนยืนยันนัดหมาย',
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primarySecondary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'เลือกสัตว์เลี้ยง',
              child: Column(
                children: [
                  for (final pet in MockUserStore.pets) ...[
                    _PetChoiceTile(
                      petName: pet.name,
                      species: pet.species,
                      gender: pet.gender,
                      image: pet.image,
                      selected: _selectedPetId == pet.id,
                      onTap: () => setState(() => _selectedPetId = pet.id),
                    ),
                    if (pet != MockUserStore.pets.last)
                      const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'รูปแบบการปรึกษา',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final type in const ['แชท', 'โทร', 'พบที่คลินิก'])
                    ChoiceChip(
                      label: Text(type),
                      selected: _consultType == type,
                      selectedColor: AppColors.primary,
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color:
                            _consultType == type
                                ? AppColors.primary
                                : AppColors.greyscale_200,
                      ),
                      labelStyle: TextStyle(
                        color:
                            _consultType == type
                                ? Colors.white
                                : AppColors.greyscale_800,
                        fontWeight: FontWeight.w700,
                      ),
                      checkmarkColor: Colors.white,
                      onSelected: (_) => setState(() => _consultType = type),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'วันและเวลา',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SharedThaiDatePickerField(
                    label: 'วันที่ต้องการนัด',
                    date: _bookingDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                    required: true,
                    onPicked: (date) => setState(() => _bookingDate = date),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final slot in _timeSlots)
                        AdoptionChoiceChip(
                          label: slot,
                          selected: _timeSlot == slot,
                          onTap: () => setState(() => _timeSlot = slot),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteCtrl,
              minLines: 3,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'อธิบายอาการหรือสิ่งที่อยากปรึกษา',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              validator:
                  (v) =>
                      (v == null || v.trim().isEmpty)
                          ? 'กรุณาระบุรายละเอียด'
                          : null,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : _submit,
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
                            strokeWidth: 2.4,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : const Text(
                          'ยืนยันการจองนัด',
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

class _DoctorSummary extends StatelessWidget {
  const _DoctorSummary({required this.doctor});
  final ConsultDoctor doctor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.greyscale_200),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              doctor.imageUrl,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.greyscale_900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  doctor.specialty,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.greyscale_400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  doctor.clinic,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.greyscale_800,
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.greyscale_200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.greyscale_900,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _PetChoiceTile extends StatelessWidget {
  const _PetChoiceTile({
    required this.petName,
    required this.species,
    required this.gender,
    required this.image,
    required this.selected,
    required this.onTap,
  });

  final String petName;
  final String species;
  final String gender;
  final String image;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              selected
                  ? AppColors.primaryLight.withValues(alpha: 0.18)
                  : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.greyscale_200,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                image,
                width: 54,
                height: 54,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    petName,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.greyscale_900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$species • $gender',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.greyscale_400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: selected ? AppColors.primary : AppColors.greyscale_300,
            ),
          ],
        ),
      ),
    );
  }
}

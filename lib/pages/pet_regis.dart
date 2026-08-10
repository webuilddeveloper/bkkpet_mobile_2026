import 'package:bkkpet/blank_page/appbar.dart';
import 'package:bkkpet/blank_page/app_media_icon.dart';
import 'package:bkkpet/blank_page/custom_dialog.dart';
import 'package:bkkpet/blank_page/shared_thai_date_picker.dart';
import 'package:bkkpet/blank_page/shared_search_dropdown.dart';
import 'package:bkkpet/services/notification_storage.dart';
import 'package:bkkpet/services/mock_reference_data.dart';
import 'package:bkkpet/services/mock_user_store.dart';
import 'package:bkkpet/style_theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class PetRegisPage extends StatefulWidget {
  const PetRegisPage({super.key});

  @override
  State<PetRegisPage> createState() => _PetRegisPageState();
}

enum _AttachmentFallbackChoice {
  cameraImage,
  galleryImage,
  cameraVideo,
  galleryVideo,
}

class _PetRegisPageState extends State<PetRegisPage> {
  final _formKey = GlobalKey<FormState>();

  // ---- ข้อมูลผู้ครอบครอง ----
  final _ownerNameCtrl = TextEditingController();
  final _ownerIdCardCtrl = TextEditingController();
  final _ownerPhoneCtrl = TextEditingController();
  final _ownerEmailCtrl = TextEditingController();
  final _ownerAddressCtrl = TextEditingController();
  final _ownerSubdistrictCtrl = TextEditingController();
  final _ownerDistrictCtrl = TextEditingController();
  final _ownerProvinceCtrl = TextEditingController();
  final _ownerZipCtrl = TextEditingController();

  // ---- สถานที่เลี้ยง ----
  bool _sameAsOwnerAddress = true;
  final _placeAddressCtrl = TextEditingController();
  final _placeSubdistrictCtrl = TextEditingController();
  final _placeDistrictCtrl = TextEditingController();
  final _placeProvinceCtrl = TextEditingController();
  final _placeZipCtrl = TextEditingController();

  // ---- สัตว์เลี้ยง (เพิ่มได้หลายตัว) — เอกสารแนบอยู่ในแต่ละตัว ----
  late final List<_PetEntry> _pets;

  bool _saving = false;

  bool _isBlank(TextEditingController controller) =>
      controller.text.trim().isEmpty;

  @override
  void initState() {
    super.initState();
    _pets = [_PetEntry()];

    _ownerNameCtrl.text = MockUserStore.owner.fullName;
    _ownerIdCardCtrl.text = MockUserStore.owner.idCard;
    _ownerPhoneCtrl.text = MockUserStore.owner.phone;
    _ownerEmailCtrl.text = MockUserStore.owner.email;
    _ownerAddressCtrl.text = MockUserStore.owner.address;
    _ownerSubdistrictCtrl.text = MockUserStore.owner.subdistrict;
    _ownerDistrictCtrl.text = MockUserStore.owner.district;
    _ownerProvinceCtrl.text = MockUserStore.owner.province;
    _ownerZipCtrl.text = MockUserStore.owner.zipCode;

    _placeAddressCtrl.text = MockUserStore.owner.address;
    _placeSubdistrictCtrl.text = MockUserStore.owner.subdistrict;
    _placeDistrictCtrl.text = MockUserStore.owner.district;
    _placeProvinceCtrl.text = MockUserStore.owner.province;
    _placeZipCtrl.text = MockUserStore.owner.zipCode;
  }

  @override
  void dispose() {
    _ownerNameCtrl.dispose();
    _ownerIdCardCtrl.dispose();
    _ownerPhoneCtrl.dispose();
    _ownerEmailCtrl.dispose();
    _ownerAddressCtrl.dispose();
    _ownerSubdistrictCtrl.dispose();
    _ownerDistrictCtrl.dispose();
    _ownerProvinceCtrl.dispose();
    _ownerZipCtrl.dispose();
    _placeAddressCtrl.dispose();
    _placeSubdistrictCtrl.dispose();
    _placeDistrictCtrl.dispose();
    _placeProvinceCtrl.dispose();
    _placeZipCtrl.dispose();
    for (final pet in _pets) {
      pet.dispose();
    }
    super.dispose();
  }

  void _addPet() {
    setState(() => _pets.add(_PetEntry()));
  }

  void _removePet(int index) {
    setState(() {
      _pets[index].dispose();
      _pets.removeAt(index);
    });
  }

  void _applyLocation(ThaiLocationMock location, {bool place = false}) {
    setState(() {
      final subdistrictCtrl =
          place ? _placeSubdistrictCtrl : _ownerSubdistrictCtrl;
      final districtCtrl = place ? _placeDistrictCtrl : _ownerDistrictCtrl;
      final provinceCtrl = place ? _placeProvinceCtrl : _ownerProvinceCtrl;
      final zipCtrl = place ? _placeZipCtrl : _ownerZipCtrl;

      subdistrictCtrl.text = location.subdistrict;
      districtCtrl.text = location.district;
      provinceCtrl.text = location.province;
      zipCtrl.text = location.zipCode;
    });
  }

  void _updateOwnerLocationFromSubdistrict(String value) {
    final location = MockReferenceData.findBySubdistrict(value);
    if (location != null) {
      _applyLocation(location);
      return;
    }
    setState(() {
      _ownerSubdistrictCtrl.text = value;
      _ownerZipCtrl.clear();
    });
  }

  void _updateOwnerLocationFromDistrict(String value) {
    final location = MockReferenceData.findByDistrict(value);
    if (location != null) {
      _applyLocation(location);
      return;
    }
    setState(() {
      _ownerDistrictCtrl.text = value;
      _ownerZipCtrl.clear();
    });
  }

  void _updateOwnerLocationFromProvince(String value) {
    final location = MockReferenceData.findByProvince(value);
    if (location != null) {
      _applyLocation(location);
      return;
    }
    setState(() {
      _ownerProvinceCtrl.text = value;
      _ownerZipCtrl.clear();
    });
  }

  void _updatePlaceLocationFromSubdistrict(String value) {
    final location = MockReferenceData.findBySubdistrict(value);
    if (location != null) {
      _applyLocation(location, place: true);
      return;
    }
    setState(() {
      _placeSubdistrictCtrl.text = value;
      _placeZipCtrl.clear();
    });
  }

  void _updatePlaceLocationFromDistrict(String value) {
    final location = MockReferenceData.findByDistrict(value);
    if (location != null) {
      _applyLocation(location, place: true);
      return;
    }
    setState(() {
      _placeDistrictCtrl.text = value;
      _placeZipCtrl.clear();
    });
  }

  void _updatePlaceLocationFromProvince(String value) {
    final location = MockReferenceData.findByProvince(value);
    if (location != null) {
      _applyLocation(location, place: true);
      return;
    }
    setState(() {
      _placeProvinceCtrl.text = value;
      _placeZipCtrl.clear();
    });
  }

  String? _requiredDataMessage() {
    if (_isBlank(_ownerNameCtrl) ||
        _isBlank(_ownerIdCardCtrl) ||
        _isBlank(_ownerPhoneCtrl) ||
        _isBlank(_ownerAddressCtrl) ||
        _isBlank(_ownerSubdistrictCtrl) ||
        _isBlank(_ownerDistrictCtrl) ||
        _isBlank(_ownerProvinceCtrl) ||
        _isBlank(_ownerZipCtrl)) {
      return 'กรุณากรอกข้อมูลผู้ครอบครองให้ครบถ้วน';
    }

    if (_ownerIdCardCtrl.text.trim().length != 13) {
      return 'กรุณากรอกเลขบัตรประชาชนให้ครบ 13 หลัก';
    }

    if (_ownerPhoneCtrl.text.trim().length != 10) {
      return 'กรุณากรอกเบอร์โทรศัพท์ให้ครบ 10 หลัก';
    }

    if (_ownerZipCtrl.text.trim().length != 5) {
      return 'กรุณาเลือกที่อยู่ให้ครบ เพื่อให้ระบบแสดงรหัสไปรษณีย์';
    }

    if (!_sameAsOwnerAddress) {
      if (_isBlank(_placeAddressCtrl) ||
          _isBlank(_placeSubdistrictCtrl) ||
          _isBlank(_placeDistrictCtrl) ||
          _isBlank(_placeProvinceCtrl) ||
          _isBlank(_placeZipCtrl)) {
        return 'กรุณากรอกข้อมูลสถานที่เลี้ยงให้ครบถ้วน';
      }

      if (_placeZipCtrl.text.trim().length != 5) {
        return 'กรุณาเลือกสถานที่เลี้ยงให้ครบ เพื่อให้ระบบแสดงรหัสไปรษณีย์';
      }
    }

    for (var index = 0; index < _pets.length; index++) {
      final pet = _pets[index];
      if (pet.nameCtrl.text.trim().isEmpty) {
        return 'กรุณากรอกชื่อสัตว์เลี้ยงตัวที่ ${index + 1}';
      }
      if (pet.microchipCtrl.text.trim().isEmpty) {
        return 'กรุณากรอกเลขไมโครชิปของสัตว์เลี้ยงตัวที่ ${index + 1}';
      }
      if (pet.microchipCtrl.text.trim().length != 15) {
        return 'กรุณากรอกเลขไมโครชิปของสัตว์เลี้ยงตัวที่ ${index + 1} ให้ครบ 15 หลัก';
      }
    }

    return null;
  }

  Future<void> _submit() async {
    final formOk = _formKey.currentState?.validate() ?? false;
    final requiredMessage = _requiredDataMessage();
    if (!formOk || requiredMessage != null) {
      await showInfoDialog(
        context: context,
        icon: Icons.error_outline_rounded,
        title: 'ข้อมูลไม่ครบถ้วน',
        message:
            requiredMessage ??
            'กรุณากรอกข้อมูลที่จำเป็น (ช่องที่มีเครื่องหมาย *) ให้ครบถ้วน',
        color: Colors.redAccent,
      );
      return;
    }

    await showConfirmDialog(
      context: context,
      icon: Icons.help_outline_rounded,
      title: 'ยืนยันการบันทึก',
      message:
          'ตรวจสอบข้อมูลเรียบร้อยแล้วใช่หรือไม่?\nต้องการบันทึกข้อมูลการจดทะเบียนนี้',
      confirmText: 'บันทึกข้อมูล',
      confirmColor: AppColors.primary,
      onConfirm: _saveData,
    );
  }

  Future<void> _saveData() async {
    setState(() => _saving = true);
    // TODO: เรียก API บันทึกข้อมูลจริง
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _saving = false);

    final registeredPets = <MockPetProfile>[];
    for (var index = 0; index < _pets.length; index++) {
      final pet = _pets[index];
      final name = pet.nameCtrl.text.trim();
      final chipNumber = pet.microchipCtrl.text.trim();
      if (name.isEmpty || chipNumber.isEmpty) continue;

      final registeredPet = MockPetProfile(
        id: 'pet-$chipNumber',
        name: name,
        species: pet.species,
        image: '',
        gender: pet.gender,
        breed: pet.breedCtrl.text.trim(),
        ageYears: _ageYearsFromBirthDate(pet.birthDate),
        weightKg: '',
        color: pet.colorCtrl.text.trim(),
        traits: pet.traitsCtrl.text.trim(),
        microchipNumber: chipNumber,
        microchipLocation: pet.chipLocationCtrl.text.trim(),
        birthDate: pet.birthDate,
        chipDate: pet.chipDate,
      );
      MockUserStore.upsertPet(registeredPet);
      registeredPets.add(registeredPet);
    }

    final petNames =
        registeredPets
            .map((pet) => pet.name)
            .where((name) => name.isNotEmpty)
            .toList();
    if (registeredPets.isEmpty) {
      await showInfoDialog(
        context: context,
        icon: Icons.error_outline_rounded,
        title: 'ข้อมูลไม่ครบถ้วน',
        message: 'กรุณากรอกข้อมูลสัตว์เลี้ยงให้ครบถ้วนก่อนบันทึก',
        color: Colors.redAccent,
      );
      return;
    }

    final petSummary =
        petNames.isEmpty
            ? 'สัตว์เลี้ยงของคุณ'
            : petNames.length == 1
            ? petNames.first
            : '${petNames.first} และอีก ${petNames.length - 1} ตัว';

    await NotificationStorage.add(
      NotificationRecord.registrationSuccess(
        petSummary: petSummary,
        petCount: petNames.isEmpty ? _pets.length : petNames.length,
        petId: registeredPets.isNotEmpty ? registeredPets.first.id : null,
      ),
    );
    if (!mounted) return;

    await showInfoDialog(
      context: context,
      icon: Icons.check_circle_outline_rounded,
      title: 'บันทึกสำเร็จ',
      message: 'บันทึกข้อมูลการจดทะเบียนสัตว์เลี้ยงเรียบร้อยแล้ว',
      color: AppColors.primary,
      onClose: () {
        if (mounted) Navigator.of(context).pop();
      },
    );
  }

  String _ageYearsFromBirthDate(DateTime? birthDate) {
    if (birthDate == null) return '';
    final now = DateTime.now();
    var years = now.year - birthDate.year;
    final birthdayThisYear = DateTime(now.year, birthDate.month, birthDate.day);
    if (now.isBefore(birthdayThisYear)) years--;
    return years < 0 ? '' : years.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarMainApp(
        title: 'จดทะเบียน',
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
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.greenlight.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color: AppColors.primarySecondary,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'ข้อมูลผู้ครอบครองและสัตว์เลี้ยงดึงจากโปรไฟล์ตัวอย่างให้แล้ว สามารถแก้ไขได้ตามจริงก่อนบันทึก',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primarySecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  _SectionCard(
                    icon: Icons.person_outline,
                    title: 'ข้อมูลผู้ครอบครอง',
                    children: [
                      _FormField(
                        label: 'ชื่อ-นามสกุล',
                        controller: _ownerNameCtrl,
                        hint: 'กรอกชื่อ-นามสกุลผู้ครอบครอง',
                        icon: Icons.badge_outlined,
                        required: true,
                      ),
                      _FormField(
                        label: 'เลขบัตรประชาชน',
                        controller: _ownerIdCardCtrl,
                        hint: 'x-xxxx-xxxxx-xx-x',
                        icon: Icons.credit_card_outlined,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(13),
                        ],
                        required: true,
                      ),
                      _FormField(
                        label: 'เบอร์โทรศัพท์',
                        controller: _ownerPhoneCtrl,
                        hint: '08xxxxxxxx',
                        icon: Icons.call_outlined,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        required: true,
                      ),
                      _FormField(
                        label: 'อีเมล (ถ้ามี)',
                        controller: _ownerEmailCtrl,
                        hint: 'example@email.com',
                        icon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      _FormField(
                        label: 'ที่อยู่',
                        controller: _ownerAddressCtrl,
                        hint: 'บ้านเลขที่ / หมู่ / ซอย / ถนน',
                        icon: Icons.home_outlined,
                        maxLines: 2,
                        required: true,
                      ),
                      SharedSearchDropdownField(
                        label: 'แขวง/ตำบล',
                        valueText: _ownerSubdistrictCtrl.text,
                        options: MockReferenceData.uniqueSubdistricts(),
                        hintText: 'เลือกแขวง/ตำบล',
                        searchHintText: 'ค้นหาแขวง/ตำบล',
                        required: true,
                        allowCustomInput: false,
                        onSelected: _updateOwnerLocationFromSubdistrict,
                      ),
                      SharedSearchDropdownField(
                        label: 'เขต/อำเภอ',
                        valueText: _ownerDistrictCtrl.text,
                        options: MockReferenceData.uniqueDistricts(),
                        hintText: 'เลือกเขต/อำเภอ',
                        searchHintText: 'ค้นหาเขต/อำเภอ',
                        required: true,
                        allowCustomInput: false,
                        onSelected: _updateOwnerLocationFromDistrict,
                      ),
                      SharedSearchDropdownField(
                        label: 'จังหวัด',
                        valueText: _ownerProvinceCtrl.text,
                        options: MockReferenceData.uniqueProvinces(),
                        hintText: 'เลือกจังหวัด',
                        searchHintText: 'ค้นหาจังหวัด',
                        required: true,
                        allowCustomInput: false,
                        onSelected: _updateOwnerLocationFromProvince,
                      ),
                      _FormField(
                        label: 'รหัสไปรษณีย์',
                        controller: _ownerZipCtrl,
                        hint: 'จะเติมให้อัตโนมัติ',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(5),
                        ],
                        required: true,
                        readOnly: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  _SectionCard(
                    icon: Icons.location_on_outlined,
                    title: 'สถานที่เลี้ยง',
                    children: [
                      _CheckRow(
                        label: 'ใช้ที่อยู่เดียวกับผู้ครอบครอง',
                        value: _sameAsOwnerAddress,
                        onChanged:
                            (v) => setState(() => _sameAsOwnerAddress = v),
                      ),
                      if (!_sameAsOwnerAddress) ...[
                        const SizedBox(height: 10),
                        _FormField(
                          label: 'ที่อยู่สถานที่เลี้ยง',
                          controller: _placeAddressCtrl,
                          hint: 'บ้านเลขที่ / หมู่ / ซอย / ถนน',
                          icon: Icons.home_work_outlined,
                          maxLines: 2,
                          required: true,
                        ),
                        SharedSearchDropdownField(
                          label: 'แขวง/ตำบล',
                          valueText: _placeSubdistrictCtrl.text,
                          options: MockReferenceData.uniqueSubdistricts(),
                          hintText: 'เลือกแขวง/ตำบล',
                          searchHintText: 'ค้นหาแขวง/ตำบล',
                          required: true,
                          allowCustomInput: false,
                          onSelected: _updatePlaceLocationFromSubdistrict,
                        ),
                        SharedSearchDropdownField(
                          label: 'เขต/อำเภอ',
                          valueText: _placeDistrictCtrl.text,
                          options: MockReferenceData.uniqueDistricts(),
                          hintText: 'เลือกเขต/อำเภอ',
                          searchHintText: 'ค้นหาเขต/อำเภอ',
                          required: true,
                          allowCustomInput: false,
                          onSelected: _updatePlaceLocationFromDistrict,
                        ),
                        SharedSearchDropdownField(
                          label: 'จังหวัด',
                          valueText: _placeProvinceCtrl.text,
                          options: MockReferenceData.uniqueProvinces(),
                          hintText: 'เลือกจังหวัด',
                          searchHintText: 'ค้นหาจังหวัด',
                          required: true,
                          allowCustomInput: false,
                          onSelected: _updatePlaceLocationFromProvince,
                        ),
                        _FormField(
                          label: 'รหัสไปรษณีย์',
                          controller: _placeZipCtrl,
                          hint: 'จะเติมให้อัตโนมัติ',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(5),
                          ],
                          required: true,
                          readOnly: true,
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 18),

                  // ---- สัตว์เลี้ยง (dynamic list) — แต่ละตัวมีเอกสารแนบของตัวเอง ----
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Row(
                      children: [
                        Icon(Icons.pets, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'ข้อมูลสัตว์เลี้ยง',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppColors.greyscale_900,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primarySecondary,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_pets.length} ตัว',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  for (int i = 0; i < _pets.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _PetFormCard(
                        index: i,
                        pet: _pets[i],
                        canRemove: _pets.length > 1,
                        onRemove: () => _removePet(i),
                      ),
                    ),

                  OutlinedButton.icon(
                    onPressed: _addPet,
                    icon: Icon(Icons.add, color: AppColors.primary, size: 20),
                    label: Text(
                      'เพิ่มสัตว์เลี้ยงอีกตัว',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      side: BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),

            // ---- ปุ่มบันทึกข้อมูล ----
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child:
                          _saving
                              ? const SizedBox(
                                key: ValueKey('spinner'),
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
                                'บันทึกข้อมูล',
                                key: ValueKey('label'),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// Models
// ================================================================

class _PetEntry {
  final nameCtrl = TextEditingController();
  final breedCtrl = TextEditingController();
  final colorCtrl = TextEditingController();
  final traitsCtrl = TextEditingController();
  final microchipCtrl = TextEditingController();
  final chipLocationCtrl = TextEditingController();

  String species = 'สุนัข';
  String gender = 'เพศผู้';
  DateTime? birthDate;
  DateTime? chipDate;

  // ---- เอกสารประกอบของสัตว์เลี้ยงตัวนี้ ----
  final List<_DocumentSlot> documents = [
    _DocumentSlot(
      title: 'ใบรับรอง (แบบ คพส.๑)',
      subtitle: 'เอกสารรับรองการขอจดทะเบียนสัตว์เลี้ยง',
      accentColor: AppColors.primary,
    ),
    _DocumentSlot(
      title: 'หนังสือยินยอมให้สุนัข/แมวพักอาศัย',
      subtitle: 'จากเจ้าของบ้านที่สุนัข/แมวอาศัยอยู่ (กรณีเป็นผู้เช่า)',
      accentColor: AppColors.primarySecondary,
    ),
  ];

  void dispose() {
    nameCtrl.dispose();
    breedCtrl.dispose();
    colorCtrl.dispose();
    traitsCtrl.dispose();
    microchipCtrl.dispose();
    chipLocationCtrl.dispose();
  }
}

class _DocumentSlot {
  _DocumentSlot({
    required this.title,
    required this.subtitle,
    this.accentColor = AppColors.primary,
  });
  final String title;
  final String subtitle;
  final Color accentColor;
  _AttachmentFile? attachment;
}

class _AttachmentFile {
  const _AttachmentFile({required this.name, this.path, this.sizeBytes});

  final String name;
  final String? path;
  final int? sizeBytes;
}

// ================================================================
// Section / field building blocks
// ================================================================

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.greyscale_200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.greyscale_900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.controller,
    required this.hint,
    this.icon,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.required = false,
    this.readOnly = false,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData? icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final bool required;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6, left: 2),
            child: RichText(
              text: TextSpan(
                text: label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.greyscale_900,
                ),
                children:
                    required
                        ? const [
                          TextSpan(
                            text: ' *',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ]
                        : null,
              ),
            ),
          ),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            maxLines: maxLines,
            readOnly: readOnly,
            style: const TextStyle(fontSize: 14),
            validator:
                required
                    ? (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'กรุณากรอกข้อมูล'
                            : null
                    : null,
            decoration: InputDecoration(
              isDense: true,
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 13,
                color: AppColors.greyscale_300,
              ),
              prefixIcon:
                  icon != null
                      ? Icon(icon, size: 18, color: AppColors.greyscale_400)
                      : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.greyscale_200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.greyscale_200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.redAccent),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormDropdown extends StatelessWidget {
  const _FormDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6, left: 2),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.greyscale_900,
              ),
            ),
          ),
          DropdownButtonFormField<String>(
            initialValue: value,
            items:
                options
                    .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                    .toList(),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
            isDense: true,
            style: TextStyle(fontSize: 14, color: AppColors.greyscale_900),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.greyscale_200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.greyscale_200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Checkbox(
              value: value,
              activeColor: AppColors.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: (v) => onChanged(v ?? false),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 14, color: AppColors.greyscale_900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// Pet sub-form (repeatable) — มีเอกสารแนบของตัวเองอยู่ในการ์ดเดียวกัน
// ================================================================

class _PetFormCard extends StatefulWidget {
  const _PetFormCard({
    required this.index,
    required this.pet,
    required this.canRemove,
    required this.onRemove,
  });

  final int index;
  final _PetEntry pet;
  final bool canRemove;
  final VoidCallback onRemove;

  @override
  State<_PetFormCard> createState() => _PetFormCardState();
}

class _PetFormCardState extends State<_PetFormCard> {
  Future<void> _pickDocument(_DocumentSlot slot) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      setState(
        () =>
            slot.attachment = _AttachmentFile(
              name: file.name,
              path: file.path,
              sizeBytes: file.size,
            ),
      );
    } on MissingPluginException {
      await _pickDocumentFallback(slot);
    } catch (_) {
      await _pickDocumentFallback(slot);
    }
  }

  Future<void> _pickDocumentFallback(_DocumentSlot slot) async {
    final picker = ImagePicker();
    final choice = await showModalBottomSheet<_AttachmentFallbackChoice>(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (sheetContext) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            ),
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.greyscale_200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'เลือกไฟล์แนบ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.greyscale_900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _FallbackChoiceTile(
                    icon: Icons.photo_camera_rounded,
                    iconAsset: appCameraIconAsset,
                    title: 'ถ่ายรูป',
                    subtitle: 'ถ่ายเอกสารใหม่',
                    onTap:
                        () => Navigator.pop(
                          sheetContext,
                          _AttachmentFallbackChoice.cameraImage,
                        ),
                  ),
                  _FallbackChoiceTile(
                    icon: Icons.photo_library_rounded,
                    iconAsset: appGalleryIconAsset,
                    title: 'เลือกรูป',
                    subtitle: 'เลือกรูปเอกสารจากเครื่อง',
                    onTap:
                        () => Navigator.pop(
                          sheetContext,
                          _AttachmentFallbackChoice.galleryImage,
                        ),
                  ),
                  _FallbackChoiceTile(
                    icon: Icons.videocam_rounded,
                    iconAsset: appCameraVideoIconAsset,
                    title: 'ถ่ายวิดีโอ',
                    subtitle: 'บันทึกวิดีโอเอกสาร',
                    onTap:
                        () => Navigator.pop(
                          sheetContext,
                          _AttachmentFallbackChoice.cameraVideo,
                        ),
                  ),
                  _FallbackChoiceTile(
                    icon: Icons.video_library_rounded,
                    iconAsset: appVideoGalleryIconAsset,
                    title: 'เลือกวิดีโอ',
                    subtitle: 'เลือกวิดีโอจากเครื่อง',
                    onTap:
                        () => Navigator.pop(
                          sheetContext,
                          _AttachmentFallbackChoice.galleryVideo,
                        ),
                  ),
                ],
              ),
            ),
          ),
    );

    if (choice == null) return;

    if (choice == _AttachmentFallbackChoice.cameraImage) {
      final picked = await picker.pickImage(source: ImageSource.camera);
      if (picked == null) return;
      setState(
        () =>
            slot.attachment = _AttachmentFile(
              name: picked.name,
              path: picked.path,
            ),
      );
      return;
    }

    if (choice == _AttachmentFallbackChoice.galleryImage) {
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;
      setState(
        () =>
            slot.attachment = _AttachmentFile(
              name: picked.name,
              path: picked.path,
            ),
      );
      return;
    }

    if (choice == _AttachmentFallbackChoice.cameraVideo) {
      final picked = await picker.pickVideo(source: ImageSource.camera);
      if (picked == null) return;
      setState(
        () =>
            slot.attachment = _AttachmentFile(
              name: picked.name,
              path: picked.path,
            ),
      );
      return;
    }

    final picked = await picker.pickVideo(source: ImageSource.gallery);
    if (picked == null) return;
    setState(
      () =>
          slot.attachment = _AttachmentFile(
            name: picked.name,
            path: picked.path,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pet = widget.pet;
    final speciesLabel = pet.species == 'สุนัข' ? 'สุนัข' : 'แมว';
    final speciesIcon =
        pet.species == 'สุนัข' ? Icons.pets : Icons.cruelty_free_outlined;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.greyscale_200),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ---- หัวการ์ด แบบไล่สี ----
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColors.primary.withValues(alpha: 0.10),
                  AppColors.greenlight.withValues(alpha: 0.10),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    '${widget.index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Icon(speciesIcon, size: 16, color: AppColors.primarySecondary),
                const SizedBox(width: 6),
                Text(
                  'สัตว์เลี้ยงตัวที่ ${widget.index + 1} · $speciesLabel',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.greyscale_900,
                  ),
                ),
                const Spacer(),
                if (widget.canRemove)
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Colors.redAccent,
                    ),
                    onPressed: widget.onRemove,
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _FormField(
                  label: 'ชื่อสัตว์เลี้ยง',
                  controller: pet.nameCtrl,
                  hint: 'ชื่อสัตว์เลี้ยง',
                  icon: Icons.pets,
                  required: true,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _FormDropdown(
                        label: 'ชนิด',
                        value: pet.species,
                        options: const ['สุนัข', 'แมว'],
                        onChanged: (v) {
                          setState(() {
                            pet.species = v;
                            if (pet.breedCtrl.text.trim().isNotEmpty &&
                                pet.breedCtrl.text.trim() != 'อื่นๆ') {
                              final options =
                                  v == 'แมว'
                                      ? MockReferenceData.catBreeds
                                      : MockReferenceData.dogBreeds;
                              if (!options.contains(
                                pet.breedCtrl.text.trim(),
                              )) {
                                pet.breedCtrl.clear();
                              }
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _FormDropdown(
                        label: 'เพศ',
                        value: pet.gender,
                        options: const ['เพศผู้', 'เพศเมีย'],
                        onChanged: (v) => setState(() => pet.gender = v),
                      ),
                    ),
                  ],
                ),
                SharedSearchDropdownField(
                  label: 'พันธุ์',
                  valueText: pet.breedCtrl.text,
                  options:
                      pet.species == 'แมว'
                          ? MockReferenceData.catBreeds
                          : MockReferenceData.dogBreeds,
                  hintText: 'เลือกหรือพิมพ์พันธุ์',
                  searchHintText: 'ค้นหาพันธุ์',
                  allowCustomInput: true,
                  onSelected: (v) => setState(() => pet.breedCtrl.text = v),
                ),
                SharedSearchDropdownField(
                  label: 'สี',
                  valueText: pet.colorCtrl.text,
                  options: MockReferenceData.petColors,
                  hintText: 'เลือกหรือพิมพ์สี',
                  searchHintText: 'ค้นหาสี',
                  allowCustomInput: true,
                  onSelected: (v) => setState(() => pet.colorCtrl.text = v),
                ),
                SharedThaiDatePickerField(
                  label: 'วันเกิด (โดยประมาณ)',
                  date: pet.birthDate,
                  onPicked: (d) => setState(() => pet.birthDate = d),
                ),
                _FormField(
                  label: 'ลักษณะเด่น',
                  controller: pet.traitsCtrl,
                  hint: 'ลักษณะพิเศษ / ตำหนิ ที่สังเกตได้',
                  maxLines: 2,
                ),

                const Divider(height: 22),
                Row(
                  children: [
                    Icon(Icons.memory, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      'ข้อมูลไมโครชิป',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.greyscale_900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _FormField(
                  label: 'เลขไมโครชิป',
                  controller: pet.microchipCtrl,
                  hint: '15 หลัก',
                  icon: Icons.qr_code_2_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(15),
                  ],
                  required: true,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: SharedThaiDatePickerField(
                        label: 'วันที่ฝังไมโครชิป',
                        date: pet.chipDate,
                        onPicked: (d) => setState(() => pet.chipDate = d),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 6,
                      child: _FormField(
                        label: 'สถานที่ฝังไมโครชิป',
                        controller: pet.chipLocationCtrl,
                        hint: 'คลินิก/โรงพยาบาลสัตว์',
                      ),
                    ),
                  ],
                ),

                const Divider(height: 22),
                Row(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'เอกสารประกอบของตัวนี้',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.greyscale_900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                for (final doc in pet.documents)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _DocumentTile(
                      slot: doc,
                      onTap: () => _pickDocument(doc),
                      onRemove: () => setState(() => doc.attachment = null),
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

// ================================================================
// Document attachment tile
// ================================================================

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({
    required this.slot,
    required this.onTap,
    required this.onRemove,
  });

  final _DocumentSlot slot;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final hasFile = slot.attachment != null;
    final accent = slot.accentColor;
    final fileName = slot.attachment?.name ?? '';

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasFile ? accent : AppColors.greyscale_200,
            width: hasFile ? 1.4 : 1,
          ),
          color:
              hasFile ? accent.withValues(alpha: 0.06) : AppColors.greyscale_25,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color:
                    hasFile
                        ? accent.withValues(alpha: 0.14)
                        : AppColors.greyscale_200.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(
                hasFile
                    ? Icons.description_rounded
                    : Icons.upload_file_outlined,
                size: 20,
                color: hasFile ? accent : AppColors.greyscale_400,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slot.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.greyscale_900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    hasFile ? 'แนบไฟล์แล้ว แตะเพื่อเปลี่ยน' : slot.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: hasFile ? accent : AppColors.greyscale_400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (hasFile) ...[
                    const SizedBox(height: 3),
                    Text(
                      fileName,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.greyscale_400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 38,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      hasFile ? AppColors.primarySecondary : AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(hasFile ? 'เปลี่ยนไฟล์' : 'แนบไฟล์'),
              ),
            ),
            if (hasFile) ...[
              const SizedBox(width: 8),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  Icons.close,
                  size: 18,
                  color: AppColors.greyscale_400,
                ),
                onPressed: onRemove,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FallbackChoiceTile extends StatelessWidget {
  const _FallbackChoiceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconAsset,
  });

  final IconData icon;
  final String? iconAsset;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.greyscale_25,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.greyscale_200),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    iconAsset == null
                        ? Icon(
                          icon,
                          color: AppColors.primarySecondary,
                          size: 20,
                        )
                        : Padding(
                          padding: const EdgeInsets.all(8),
                          child: AppMediaIcon(
                            asset: iconAsset!,
                            fallbackIcon: icon,
                            size: 24,
                            color: AppColors.primarySecondary,
                          ),
                        ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.greyscale_900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.greyscale_400,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.greyscale_400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

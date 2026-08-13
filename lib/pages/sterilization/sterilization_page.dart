// ignore_for_file: unused_element_parameter

import 'package:bkkpet/blank_page/appbar.dart';
import 'package:bkkpet/blank_page/custom_dialog.dart';
import 'package:bkkpet/pages/sterilization/sterilization_booking_detail_page.dart';
import 'package:bkkpet/pages/sterilization/sterilization_booking_history_page.dart';
import 'package:bkkpet/pages/sterilization/sterilization_booking_model.dart';
import 'package:bkkpet/pages/sterilization/sterilization_booking_storage.dart';
import 'package:bkkpet/services/notification_storage.dart';
import 'package:bkkpet/services/mock_user_store.dart';
import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ================================================================
/// จองทำหมันสัตว์เลี้ยง — ฝั่งประชาชน
/// (การฉีดวัคซีนแยกไปอีกหน้า VaccinePage)
///
/// ครอบคลุม:
///   - เลือกสัตว์เลี้ยงที่เคยลงทะเบียนไว้ (ไม่ต้องกรอกข้อมูลซ้ำ)
///     หรือกรอกข้อมูลสัตว์เลี้ยงตัวใหม่ (เลือกได้ทีละ 1 ตัวต่อการจอง)
///   - เลือกเขตพื้นที่ + คลินิก/หน่วยเคลื่อนที่ที่รับทำหมัน
///   - จองวันเวลา พร้อมแสดงคิวคงเหลือของแต่ละช่วงเวลา
///   - เช็คลิสต์ความพร้อมก่อนผ่าตัด
///   - ยืนยันการจอง แล้วบันทึกลง local storage พร้อมเปิดหน้าแสดงรายละเอียด
///     การจอง / ดูประวัติการจองย้อนหลังได้
/// ================================================================

class Sterilizationpage extends StatefulWidget {
  const Sterilizationpage({super.key});

  @override
  State<Sterilizationpage> createState() => _SterilizationpageState();
}

enum _PointType { fixed, mobile }

enum _PetSource { registered, manual }

class _SterilizationpageState extends State<Sterilizationpage> {
  final _formKey = GlobalKey<FormState>();

  // ---- สัตว์เลี้ยงของฉัน (mock ข้อมูลที่เคยลงทะเบียนไว้แล้ว) ----
  late final List<_MyPet> _myPets;
  _PetSource _petSource = _PetSource.registered;
  String? _selectedPetId;

  final _manualNameCtrl = TextEditingController();
  final _manualAgeCtrl = TextEditingController();
  final _manualWeightCtrl = TextEditingController();
  String _manualSpecies = 'สุนัข';
  String _manualGender = 'เพศผู้';

  // ---- เขตพื้นที่ / คลินิก ----
  String _districtLabel = 'ทุกเขต';
  final List<String> _districtOptions = const [
    'ทุกเขต',
    'ปทุมวัน',
    'บางกะปิ',
    'จตุจักร',
    'ห้วยขวาง',
  ];

  final List<_ServicePoint> _allPoints = const [
    _ServicePoint(
      name: 'ศูนย์บริการสัตวแพทย์ สวนลุมพินี',
      type: _PointType.fixed,
      address: '111 ถ.พระราม 4 แขวงลุมพินี เขตปทุมวัน',
      district: 'ปทุมวัน',
      distanceKm: 1.2,
      openHours: '08:30 - 15:00 น. (จันทร์-ศุกร์)',
      dailyCapacityLabel: 'รองรับประมาณ 15 คิวผ่าตัด/วัน',
      slotRemaining: {
        '08:30 - 09:30': 3,
        '09:30 - 10:30': 2,
        '10:30 - 11:30': 0,
        '13:00 - 14:00': 4,
      },
    ),
    _ServicePoint(
      name: 'หน่วยทำหมันเคลื่อนที่ เขตบางกะปิ',
      type: _PointType.mobile,
      address: 'ลานกิจกรรมหน้าสำนักงานเขตบางกะปิ',
      district: 'บางกะปิ',
      distanceKm: 4.8,
      openHours: '09:00 - 12:00 น. (เฉพาะวันเสาร์)',
      dailyCapacityLabel: 'รองรับประมาณ 20 คิวผ่าตัด/วัน',
      slotRemaining: {
        '09:00 - 10:00': 5,
        '10:00 - 11:00': 3,
        '11:00 - 12:00': 0,
      },
    ),
    _ServicePoint(
      name: 'คลินิกสัตวแพทย์ เขตจตุจักร',
      type: _PointType.fixed,
      address: '54 ถ.พหลโยธิน แขวงจตุจักร เขตจตุจักร',
      district: 'จตุจักร',
      distanceKm: 6.5,
      openHours: '08:30 - 15:00 น. (จันทร์-ศุกร์)',
      dailyCapacityLabel: 'รองรับประมาณ 12 คิวผ่าตัด/วัน',
      slotRemaining: {
        '08:30 - 09:30': 0,
        '09:30 - 10:30': 2,
        '13:00 - 14:00': 3,
      },
    ),
    _ServicePoint(
      name: 'หน่วยทำหมันเคลื่อนที่ เขตห้วยขวาง',
      type: _PointType.mobile,
      address: 'ลานจอดรถตลาดห้วยขวาง',
      district: 'ห้วยขวาง',
      distanceKm: 3.1,
      openHours: '09:00 - 12:00 น. (เฉพาะวันอาทิตย์)',
      dailyCapacityLabel: 'รองรับประมาณ 18 คิวผ่าตัด/วัน',
      slotRemaining: {
        '09:00 - 10:00': 6,
        '10:00 - 11:00': 4,
        '11:00 - 12:00': 1,
      },
    ),
  ];

  _ServicePoint? _selectedPoint;

  // ---- วัน / เวลา ----
  DateTime? _bookingDate;
  String? _timeSlot;

  // ---- ความพร้อมก่อนผ่าตัด ----
  bool _fasted = false;
  bool _healthChecked = false;
  bool _vaccinated = false;

  // ---- ผู้จอง / ผู้ติดต่อ ----
  final _ownerNameCtrl = TextEditingController();
  final _ownerPhoneCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _myPets =
        MockUserStore.pets
            .map(
              (pet) => _MyPet(
                id: pet.id,
                name: pet.name,
                species: pet.species,
                image: pet.image,
                gender: pet.gender,
                breed: pet.breed,
                age: pet.ageYears,
                weight: pet.weightKg,
              ),
            )
            .toList();

    _ownerNameCtrl.text = MockUserStore.owner.fullName;
    _ownerPhoneCtrl.text = MockUserStore.owner.phone;

    final profileDistrict = MockUserStore.owner.district;
    final districtPoints =
        _allPoints.where((p) => p.district == profileDistrict).toList()
          ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    if (districtPoints.isNotEmpty) {
      _districtLabel = profileDistrict;
      _selectedPoint = districtPoints.first;
    } else {
      final nearestPoint = _sortedPoints.first;
      _districtLabel = nearestPoint.district;
      _selectedPoint = nearestPoint;
    }
  }

  @override
  void dispose() {
    _manualNameCtrl.dispose();
    _manualAgeCtrl.dispose();
    _manualWeightCtrl.dispose();
    _ownerNameCtrl.dispose();
    _ownerPhoneCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  _MyPet? get _selectedRegisteredPet {
    if (_selectedPetId == null) return null;
    for (final p in _myPets) {
      if (p.id == _selectedPetId) return p;
    }
    return null;
  }

  bool get _hasChosenPet =>
      _petSource == _PetSource.registered
          ? _selectedRegisteredPet != null
          : _manualNameCtrl.text.trim().isNotEmpty;

  List<_ServicePoint> get _filteredPoints {
    final list =
        _allPoints
            .where(
              (p) => _districtLabel == 'ทุกเขต' || p.district == _districtLabel,
            )
            .toList();
    list.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return list;
  }

  List<_ServicePoint> get _sortedPoints {
    final list = _allPoints.toList();
    list.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return list;
  }

  String _formatDate(DateTime d) {
    const months = [
      'ม.ค.',
      'ก.พ.',
      'มี.ค.',
      'เม.ย.',
      'พ.ค.',
      'มิ.ย.',
      'ก.ค.',
      'ส.ค.',
      'ก.ย.',
      'ต.ค.',
      'พ.ย.',
      'ธ.ค.',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year + 543}';
  }

  Future<void> _submit() async {
    final formOk = _formKey.currentState?.validate() ?? false;

    if (!_hasChosenPet) {
      await showInfoDialog(
        context: context,
        icon: Icons.error_outline_rounded,
        title: 'ยังไม่ได้เลือกสัตว์เลี้ยง',
        message: 'กรุณาเลือกหรือกรอกข้อมูลสัตว์เลี้ยงที่จะเข้ารับการทำหมัน',
        color: Colors.redAccent,
      );
      return;
    }
    if (_selectedPoint == null) {
      await showInfoDialog(
        context: context,
        icon: Icons.error_outline_rounded,
        title: 'ยังไม่ได้เลือกคลินิก',
        message: 'กรุณาเลือกคลินิกหรือหน่วยเคลื่อนที่ก่อนทำการจอง',
        color: Colors.redAccent,
      );
      return;
    }
    if (_bookingDate == null || _timeSlot == null) {
      await showInfoDialog(
        context: context,
        icon: Icons.error_outline_rounded,
        title: 'ยังไม่ได้เลือกวันเวลา',
        message: 'กรุณาเลือกวันที่และช่วงเวลาที่ต้องการเข้ารับบริการ',
        color: Colors.redAccent,
      );
      return;
    }
    if (!_fasted || !_healthChecked) {
      await showInfoDialog(
        context: context,
        icon: Icons.error_outline_rounded,
        title: 'ยังไม่พร้อมสำหรับการผ่าตัด',
        message:
            'กรุณายืนยันว่างดอาหารตามกำหนดและตรวจสุขภาพเบื้องต้นแล้ว เพื่อความปลอดภัยของสัตว์เลี้ยง',
        color: Colors.redAccent,
      );
      return;
    }
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

    await showConfirmDialog(
      context: context,
      icon: Icons.help_outline_rounded,
      title: 'ยืนยันการจองคิว',
      message:
          'ตรวจสอบข้อมูลเรียบร้อยแล้วใช่หรือไม่?\nต้องการยืนยันการจองคิวทำหมันนี้',
      confirmText: 'ยืนยันการจอง',
      confirmColor: AppColors.primary,
      onConfirm: _saveBooking,
    );
  }

  Future<void> _saveBooking() async {
    setState(() => _saving = true);

    final String petName;
    final String species;
    final String gender;
    final String age;
    final String weight;
    final String? petId;

    if (_petSource == _PetSource.registered) {
      final pet = _selectedRegisteredPet!;
      petId = pet.id;
      petName = pet.name;
      species = pet.species;
      gender = pet.gender;
      age = pet.age;
      weight = pet.weight;
    } else {
      petId = null;
      petName = _manualNameCtrl.text.trim();
      species = _manualSpecies;
      gender = _manualGender;
      age = _manualAgeCtrl.text.trim();
      weight = _manualWeightCtrl.text.trim();
    }

    final code = 'ST${DateTime.now().millisecondsSinceEpoch % 1000000}';
    final now = DateTime.now();

    final record = SterilizationBookingRecord(
      id: code,
      petId: petId,
      petName: petName,
      species: species,
      gender: gender,
      age: age,
      weight: weight,
      district: _districtLabel,
      pointName: _selectedPoint!.name,
      pointAddress: _selectedPoint!.address,
      pointType: _selectedPoint!.type == _PointType.mobile ? 'mobile' : 'fixed',
      dateIso: _bookingDate!.toIso8601String(),
      timeSlot: _timeSlot!,
      fasted: _fasted,
      healthChecked: _healthChecked,
      vaccinated: _vaccinated,
      ownerName: _ownerNameCtrl.text.trim(),
      ownerPhone: _ownerPhoneCtrl.text.trim(),
      note: _noteCtrl.text.trim(),
      createdAtIso: now.toIso8601String(),
    );

    // TODO: เรียก API บันทึกการจองจริง (ปัจจุบันเก็บไว้ใน local storage ก่อน)
    await SterilizationBookingStorage.add(record);
    await NotificationStorage.add(
      NotificationRecord.sterilizationSuccess(record),
    );
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _saving = false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder:
            (_) => SterilizationBookingDetailPage(
              record: record,
              justBooked: true,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canConfirm =
        _hasChosenPet &&
        _selectedPoint != null &&
        _bookingDate != null &&
        _timeSlot != null;

    return Scaffold(
      backgroundColor: AppColors.greyscale_25,
      appBar: AppBarMainApp(
        title: 'จองทำหมัน',
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
                  // ---- ทางลัดไปประวัติการจอง ----
                  InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap:
                        () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (_) => const SterilizationBookingHistoryPage(),
                          ),
                        ),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.greenlight.withOpacity(0.6),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.history_rounded,
                            size: 18,
                            color: AppColors.primarySecondary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'ดูประวัติการจองทำหมันของฉัน',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primarySecondary,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: AppColors.primarySecondary,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ---- คำแนะนำสั้น ๆ ----
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'การทำหมัน 1 การจอง จะรับสัตว์เลี้ยงได้ 1 ตัวต่อครั้ง เพื่อความปลอดภัยและความสะดวกในการดูแลหลังผ่าตัด',
                            style: TextStyle(
                              fontSize: 12.5,
                              height: 1.4,
                              color: AppColors.greyscale_800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ---- 1. เลือกสัตว์เลี้ยง ----
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Row(
                      children: [
                        Icon(Icons.pets, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'เลือกสัตว์เลี้ยงที่จะเข้ารับการทำหมัน',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: AppColors.greyscale_900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.greyscale_200),
                    ),
                    child: Column(
                      children: [
                        _SourceToggle(
                          label: 'สัตว์เลี้ยงที่เคยลงทะเบียนไว้',
                          selected: _petSource == _PetSource.registered,
                          onTap:
                              () => setState(
                                () => _petSource = _PetSource.registered,
                              ),
                        ),
                        if (_petSource == _PetSource.registered) ...[
                          const SizedBox(height: 10),
                          for (final pet in _myPets)
                            _MyPetTile(
                              pet: pet,
                              selected: _selectedPetId == pet.id,
                              onTap:
                                  () => setState(() => _selectedPetId = pet.id),
                            ),
                          if (_myPets.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                'ยังไม่มีสัตว์เลี้ยงที่ลงทะเบียนไว้ในระบบ',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.greyscale_400,
                                ),
                              ),
                            ),
                        ],
                        const SizedBox(height: 10),
                        const Divider(height: 1),
                        const SizedBox(height: 10),
                        _SourceToggle(
                          label: 'กรอกข้อมูลสัตว์เลี้ยงตัวใหม่',
                          selected: _petSource == _PetSource.manual,
                          onTap:
                              () => setState(
                                () => _petSource = _PetSource.manual,
                              ),
                        ),
                        if (_petSource == _PetSource.manual) ...[
                          const SizedBox(height: 10),
                          _FormField(
                            label: 'ชื่อสัตว์เลี้ยง',
                            controller: _manualNameCtrl,
                            hint: 'ชื่อสัตว์เลี้ยง',
                            icon: Icons.badge_outlined,
                            required: _petSource == _PetSource.manual,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _FormDropdown(
                                  label: 'ชนิด',
                                  value: _manualSpecies,
                                  options: const ['สุนัข', 'แมว', 'อื่นๆ'],
                                  onChanged:
                                      (v) => setState(() => _manualSpecies = v),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _FormDropdown(
                                  label: 'เพศ',
                                  value: _manualGender,
                                  options: const ['เพศผู้', 'เพศเมีย'],
                                  onChanged:
                                      (v) => setState(() => _manualGender = v),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _FormField(
                                  label: 'อายุ (ปี)',
                                  controller: _manualAgeCtrl,
                                  hint: 'เช่น 2',
                                  icon: Icons.cake_outlined,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _FormField(
                                  label: 'น้ำหนัก (กก.)',
                                  controller: _manualWeightCtrl,
                                  hint: 'เช่น 12',
                                  icon: Icons.monitor_weight_outlined,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ---- 2. เขตพื้นที่ + คลินิก ----
                  _SectionCard(
                    icon: Icons.location_on_outlined,
                    title: 'เขตพื้นที่และคลินิก',
                    children: [
                      _FormDropdown(
                        label: 'เขตพื้นที่',
                        value: _districtLabel,
                        options: _districtOptions,
                        onChanged:
                            (v) => setState(() {
                              _districtLabel = v;
                              _selectedPoint = null;
                              _timeSlot = null;
                            }),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10, left: 2),
                        child: Text(
                          'เลือกคลินิกหรือหน่วยเคลื่อนที่ เรียงตามระยะทางใกล้บ้าน',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.greyscale_400,
                          ),
                        ),
                      ),
                      if (_filteredPoints.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.greyscale_200.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'ไม่พบคลินิกในเขตที่เลือก\nลองเปลี่ยนเขตพื้นที่',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.greyscale_400,
                            ),
                          ),
                        )
                      else
                        for (final point in _filteredPoints)
                          _ServicePointCard(
                            point: point,
                            selected: _selectedPoint == point,
                            onTap:
                                () => setState(() {
                                  _selectedPoint = point;
                                  _timeSlot = null;
                                }),
                          ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // ---- 3. วัน / เวลา ----
                  _SectionCard(
                    icon: Icons.event_available_outlined,
                    title: 'วันและเวลานัดหมาย',
                    children: [
                      _BookingDateField(
                        label: 'วันที่ต้องการเข้ารับบริการ',
                        date: _bookingDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 60)),
                        onPicked: (d) => setState(() => _bookingDate = d),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6, left: 2),
                        child: Text(
                          'ช่วงเวลา',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.greyscale_900,
                          ),
                        ),
                      ),
                      if (_selectedPoint == null)
                        Text(
                          'กรุณาเลือกคลินิกก่อนเพื่อดูช่วงเวลาที่ว่าง',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.greyscale_400,
                          ),
                        )
                      else
                        _TimeSlotChips(
                          slotRemaining: _selectedPoint!.slotRemaining,
                          selected: _timeSlot,
                          onSelect: (s) => setState(() => _timeSlot = s),
                        ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // ---- 4. ความพร้อมก่อนผ่าตัด ----
                  _SectionCard(
                    icon: Icons.checklist_rtl,
                    title: 'ความพร้อมก่อนผ่าตัด',
                    children: [
                      _CheckTile(
                        title: 'งดอาหารก่อนผ่าตัดอย่างน้อย 8-12 ชม. *',
                        subtitle: 'จำเป็นเพื่อความปลอดภัยขณะวางยาสลบ',
                        value: _fasted,
                        onChanged: (v) => setState(() => _fasted = v ?? false),
                      ),
                      _CheckTile(
                        title: 'ตรวจสุขภาพเบื้องต้นแล้ว *',
                        subtitle:
                            'ไม่มีไข้ ไอ หรืออาการผิดปกติในช่วง 3 วันที่ผ่านมา',
                        value: _healthChecked,
                        onChanged:
                            (v) => setState(() => _healthChecked = v ?? false),
                      ),
                      _CheckTile(
                        title: 'ฉีดวัคซีนครบตามกำหนด',
                        subtitle: 'ถ้ายังไม่ครบ สามารถแจ้งสัตวแพทย์หน้างานได้',
                        value: _vaccinated,
                        onChanged:
                            (v) => setState(() => _vaccinated = v ?? false),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // ---- 5. ผู้จอง / ผู้ติดต่อ ----
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.greenlight.withOpacity(0.6),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.badge_outlined,
                          size: 18,
                          color: AppColors.primarySecondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                MockUserStore.owner.fullName,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primarySecondary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${MockUserStore.owner.phone} • ${MockUserStore.owner.email}',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: AppColors.primarySecondary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                MockUserStore.owner.shortAddress,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primarySecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),

            // ---- แถบยืนยันการจองด้านล่าง ----
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (canConfirm)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 14,
                              color: AppColors.greyscale_400,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                '${_formatDate(_bookingDate!)} • $_timeSlot • ${_selectedPoint!.name}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.greyscale_400,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(
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
                                    'ยืนยันการจอง',
                                    key: ValueKey('label'),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                        ),
                      ),
                    ),
                  ],
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

class _MyPet {
  const _MyPet({
    required this.id,
    required this.name,
    required this.species,
    required this.image,
    required this.gender,
    required this.breed,
    required this.age,
    required this.weight,
  });

  final String id;
  final String name;
  final String species;
  final String image;
  final String gender;
  final String breed;
  final String age;
  final String weight;
}

class _ServicePoint {
  const _ServicePoint({
    required this.name,
    required this.type,
    required this.address,
    required this.district,
    required this.distanceKm,
    required this.openHours,
    required this.dailyCapacityLabel,
    required this.slotRemaining,
  });

  final String name;
  final _PointType type;
  final String address;
  final String district;
  final double distanceKm;
  final String openHours;
  final String dailyCapacityLabel;
  final Map<String, int> slotRemaining;
}

// ================================================================
// Section / field building blocks
// ================================================================

class _SourceToggle extends StatelessWidget {
  const _SourceToggle({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            size: 20,
            color: selected ? AppColors.primary : AppColors.greyscale_300,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.greyscale_900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData? icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final bool required;

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

class _BookingDateField extends StatelessWidget {
  const _BookingDateField({
    required this.label,
    required this.date,
    required this.firstDate,
    required this.lastDate,
    required this.onPicked,
  });

  final String label;
  final DateTime? date;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onPicked;

  String get _text {
    if (date == null) return '';
    final d = date!.day.toString().padLeft(2, '0');
    final m = date!.month.toString().padLeft(2, '0');
    return '$d/$m/${date!.year}';
  }

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
                children: const [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: date ?? firstDate,
                firstDate: firstDate,
                lastDate: lastDate,
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: AppColors.primary,
                        onPrimary: Colors.white,
                        onSurface: AppColors.greyscale_900,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) onPicked(picked);
            },
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.greyscale_200),
              ),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: AppColors.greyscale_400,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _text.isEmpty ? 'เลือกวันที่' : _text,
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          _text.isEmpty
                              ? AppColors.greyscale_300
                              : AppColors.greyscale_900,
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

// ================================================================
// สัตว์เลี้ยงที่เคยลงทะเบียนไว้แล้ว — เลือกได้ทีละ 1 ตัว
// ================================================================

class _MyPetTile extends StatelessWidget {
  const _MyPetTile({
    required this.pet,
    required this.selected,
    required this.onTap,
  });

  final _MyPet pet;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.greyscale_200,
            width: selected ? 1.5 : 1,
          ),
          color:
              selected
                  ? AppColors.primary.withOpacity(0.05)
                  : Colors.transparent,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: ClipOval(
                child: Image.asset(
                  pet.image,
                  height: 40,
                  width: 40,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Icon(
                        pet.species == 'แมว' ? Icons.pets : Icons.pets_outlined,
                        size: 18,
                        color: AppColors.primary,
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
                    '${pet.name} • ${pet.species} • ${pet.gender}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.greyscale_900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${pet.breed} • อายุ ${pet.age} ปี • น้ำหนัก ${pet.weight} กก.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.greyscale_400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.radio_button_off,
              size: 22,
              color: selected ? AppColors.primary : AppColors.greyscale_300,
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// Checklist tile ความพร้อมก่อนผ่าตัด
// ================================================================

class _CheckTile extends StatelessWidget {
  const _CheckTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => onChanged(!value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value ? AppColors.primary : AppColors.greyscale_200,
            width: value ? 1.5 : 1,
          ),
          color: value ? AppColors.primary.withOpacity(0.05) : Colors.white,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              value ? Icons.check_box : Icons.check_box_outline_blank,
              size: 20,
              color: value ? AppColors.primary : AppColors.greyscale_300,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
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
          ],
        ),
      ),
    );
  }
}

// ================================================================
// Service point card (จุดประจำ / หน่วยเคลื่อนที่)
// ================================================================

class _ServicePointCard extends StatelessWidget {
  const _ServicePointCard({
    required this.point,
    required this.selected,
    required this.onTap,
  });

  final _ServicePoint point;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isMobile = point.type == _PointType.mobile;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.greyscale_200,
            width: selected ? 1.5 : 1,
          ),
          color: selected ? AppColors.primary.withOpacity(0.05) : Colors.white,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 20,
              color: selected ? AppColors.primary : AppColors.greyscale_300,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          point.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.greyscale_900,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: (isMobile
                                  ? AppColors.primarySecondary
                                  : AppColors.primary)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isMobile ? 'หน่วยเคลื่อนที่' : 'จุดประจำ',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color:
                                isMobile
                                    ? AppColors.primarySecondary
                                    : AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    point.address,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.greyscale_400,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.place_outlined,
                        size: 13,
                        color: AppColors.greyscale_300,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${point.distanceKm.toStringAsFixed(1)} กม.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.greyscale_400,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.schedule_outlined,
                        size: 13,
                        color: AppColors.greyscale_300,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          point.openHours,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.greyscale_400,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    point.dailyCapacityLabel,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.greyscale_300,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// Time slot chips พร้อมจำนวนคิวคงเหลือ
// ================================================================

class _TimeSlotChips extends StatelessWidget {
  const _TimeSlotChips({
    required this.slotRemaining,
    required this.selected,
    required this.onSelect,
  });

  final Map<String, int> slotRemaining;
  final String? selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          slotRemaining.entries.map((entry) {
            final slot = entry.key;
            final remaining = entry.value;
            final isFull = remaining <= 0;
            final isSelected = slot == selected;
            return InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: isFull ? null : () => onSelect(slot),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color:
                      isFull
                          ? AppColors.greyscale_200.withOpacity(0.4)
                          : (isSelected ? AppColors.primary : Colors.white),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        isFull
                            ? AppColors.greyscale_200
                            : (isSelected
                                ? AppColors.primary
                                : AppColors.greyscale_200),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      slot,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color:
                            isFull
                                ? AppColors.greyscale_300
                                : (isSelected
                                    ? Colors.white
                                    : AppColors.greyscale_900),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isFull ? 'เต็ม' : 'เหลือ $remaining คิว',
                      style: TextStyle(
                        fontSize: 10.5,
                        color:
                            isFull
                                ? AppColors.greyscale_300
                                : (isSelected
                                    ? Colors.white.withOpacity(0.9)
                                    : AppColors.greyscale_400),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }
}

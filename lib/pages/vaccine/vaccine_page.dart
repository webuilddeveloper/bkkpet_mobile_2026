import 'package:bkkpet/blank_page/appbar.dart';
import 'package:bkkpet/blank_page/custom_dialog.dart';
import 'package:bkkpet/blank_page/shared_thai_date_picker.dart';
import 'package:bkkpet/pages/vaccine/vaccine_booking_detail_page.dart';
import 'package:bkkpet/pages/vaccine/vaccine_booking_history_page.dart';
import 'package:bkkpet/pages/vaccine/vaccine_booking_model.dart';
import 'package:bkkpet/pages/vaccine/vaccine_booking_storage.dart';
import 'package:bkkpet/services/notification_storage.dart';
import 'package:bkkpet/services/mock_user_store.dart';
import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ================================================================
/// จองฉีดวัคซีนสัตว์เลี้ยง — ฝั่งประชาชน
/// (การทำหมันแยกไปอีกหน้า SterilizationPage)
///
/// ครอบคลุม:
///   - เลือกสัตว์เลี้ยงที่เคยลงทะเบียนไว้ (ไม่ต้องกรอกข้อมูลซ้ำ)
///     หรือเพิ่มสัตว์ที่ยังไม่ได้ลงทะเบียน
///   - วัคซีนพิษสุนัขบ้าตามนโยบาย (ฟรี) + วัคซีนรวมเสริม (เลือกได้หลายรายการ)
///   - เลือกเขตพื้นที่ + จุดบริการ/หน่วยเคลื่อนที่ใกล้บ้าน
///   - จองวันเวลา พร้อมแสดงคิวคงเหลือของแต่ละช่วงเวลา
///   - ยืนยันการจอง แล้วบันทึกลง local storage พร้อมเปิดหน้าแสดงรายละเอียด
///     การจอง / ต้องการจองเพิ่มก็กลับมาที่หน้านี้ได้ทันที
/// ================================================================

class VaccinePage extends StatefulWidget {
  const VaccinePage({super.key});

  @override
  State<VaccinePage> createState() => _VaccinePageState();
}

enum _PointType { fixed, mobile }

class _VaccinePageState extends State<VaccinePage> {
  final _formKey = GlobalKey<FormState>();

  // ---- สัตว์เลี้ยงของฉัน (mock ข้อมูลที่เคยลงทะเบียนไว้แล้ว) ----
  late final List<_MyPet> _myPets;
  final Set<String> _selectedPetIds = {};
  final List<_BookingPetEntry> _manualPets = [];

  // ---- วัคซีนเสริม (เลือกได้หลายรายการ) ----
  final List<_ComboVaccineOption> _comboOptions = const [
    _ComboVaccineOption(
      id: 'c1',
      name: 'วัคซีนรวมป้องกัน 4 โรค (สุนัข)',
      species: 'สุนัข',
      price: 280,
      description: 'ป้องกันโรคหัด ตับอักเสบ เลปโตสไปโรซิส และลำไส้อักเสบ',
    ),
    _ComboVaccineOption(
      id: 'c2',
      name: 'วัคซีนรวมป้องกัน 5 โรค (สุนัข)',
      species: 'สุนัข',
      price: 320,
      description: 'ครอบคลุมมากขึ้น เหมาะสำหรับสุนัขที่ยังไม่เคยฉีดวัคซีน',
    ),
    _ComboVaccineOption(
      id: 'c3',
      name: 'วัคซีนรวมป้องกัน 4 โรค (แมว)',
      species: 'แมว',
      price: 300,
      description: 'ป้องกันไข้หัดแมว หวัดแมว และโรคระบบทางเดินหายใจ',
    ),
    _ComboVaccineOption(
      id: 'c4',
      name: 'วัคซีนป้องกันเชื้อราแมว',
      species: 'แมว',
      price: 250,
      description: 'แนะนำสำหรับแมวที่อยู่รวมกันหลายตัวหรือมีความเสี่ยงสูง',
    ),
    _ComboVaccineOption(
      id: 'c5',
      name: 'ยาถ่ายพยาธิ',
      species: null,
      price: 150,
      description: 'กำจัดพยาธิภายใน แนะนำให้ทำควบคู่กับการฉีดวัคซีน',
    ),
  ];
  final Set<String> _selectedComboIds = {};

  // ---- เขตพื้นที่ / จุดบริการ ----
  late String _districtLabel;
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
      openHours: '08:30 - 16:00 น. (จันทร์-ศุกร์)',
      dailyCapacityLabel: 'รองรับประมาณ 40 คิว/วัน',
      slotRemaining: {
        '09:00 - 10:00': 6,
        '10:00 - 11:00': 3,
        '11:00 - 12:00': 0,
        '13:00 - 14:00': 8,
        '14:00 - 15:00': 5,
        '15:00 - 16:00': 2,
      },
    ),
    _ServicePoint(
      name: 'หน่วยเคลื่อนที่ เขตบางกะปิ',
      type: _PointType.mobile,
      address: 'ลานกิจกรรมหน้าสำนักงานเขตบางกะปิ',
      district: 'บางกะปิ',
      distanceKm: 4.8,
      openHours: '09:00 - 12:00 น. (เฉพาะวันเสาร์)',
      dailyCapacityLabel: 'รองรับประมาณ 60 คิว/วัน',
      slotRemaining: {
        '09:00 - 10:00': 12,
        '10:00 - 11:00': 9,
        '11:00 - 12:00': 4,
      },
    ),
    _ServicePoint(
      name: 'คลินิกสัตวแพทย์ เขตจตุจักร',
      type: _PointType.fixed,
      address: '54 ถ.พหลโยธิน แขวงจตุจักร เขตจตุจักร',
      district: 'จตุจักร',
      distanceKm: 6.5,
      openHours: '08:30 - 16:00 น. (จันทร์-ศุกร์)',
      dailyCapacityLabel: 'รองรับประมาณ 35 คิว/วัน',
      slotRemaining: {
        '09:00 - 10:00': 0,
        '10:00 - 11:00': 0,
        '11:00 - 12:00': 5,
        '13:00 - 14:00': 7,
        '14:00 - 15:00': 6,
        '15:00 - 16:00': 4,
      },
    ),
    _ServicePoint(
      name: 'หน่วยเคลื่อนที่ เขตห้วยขวาง',
      type: _PointType.mobile,
      address: 'ลานจอดรถตลาดห้วยขวาง',
      district: 'ห้วยขวาง',
      distanceKm: 3.1,
      openHours: '09:00 - 12:00 น. (เฉพาะวันอาทิตย์)',
      dailyCapacityLabel: 'รองรับประมาณ 50 คิว/วัน',
      slotRemaining: {
        '09:00 - 10:00': 10,
        '10:00 - 11:00': 2,
        '11:00 - 12:00': 1,
      },
    ),
  ];

  _ServicePoint? _selectedPoint;

  // ---- วัน / เวลา ----
  DateTime? _bookingDate;
  String? _timeSlot;

  // ---- ผู้จอง / ผู้ติดต่อ ----
  final _ownerNameCtrl = TextEditingController();
  final _ownerPhoneCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _myPets =
        MockUserStore.pets
            .map(
              (pet) => _MyPet(
                id: pet.id,
                name: pet.name,
                species: pet.species,
                image: pet.image,
                breed: pet.breed,
                lastVaccinatedDate: DateTime(now.year - 1, now.month, now.day),
                nextDueDate: DateTime(
                  now.year,
                  now.month,
                  now.day,
                ).add(const Duration(days: 180)),
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
    _ownerNameCtrl.dispose();
    _ownerPhoneCtrl.dispose();
    _noteCtrl.dispose();
    for (final p in _manualPets) {
      p.dispose();
    }
    super.dispose();
  }

  int get _totalPetCount => _selectedPetIds.length + _manualPets.length;

  List<_ComboVaccineOption> get _selectedComboOptions =>
      _comboOptions.where((o) => _selectedComboIds.contains(o.id)).toList();

  int get _comboUnitPrice =>
      _selectedComboOptions.fold(0, (sum, o) => sum + o.price);

  int get _comboTotalEstimate =>
      _comboUnitPrice * (_totalPetCount == 0 ? 1 : _totalPetCount);

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

  void _addManualPet() => setState(() => _manualPets.add(_BookingPetEntry()));

  void _removeManualPet(int index) {
    setState(() {
      _manualPets[index].dispose();
      _manualPets.removeAt(index);
    });
  }

  void _toggleCombo(String id) {
    setState(() {
      if (_selectedComboIds.contains(id)) {
        _selectedComboIds.remove(id);
      } else {
        _selectedComboIds.add(id);
      }
    });
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

    if (_totalPetCount == 0) {
      await showInfoDialog(
        context: context,
        icon: Icons.error_outline_rounded,
        title: 'ยังไม่ได้เลือกสัตว์เลี้ยง',
        message: 'กรุณาเลือกสัตว์เลี้ยงที่จะพามารับวัคซีนอย่างน้อย 1 ตัว',
        color: Colors.redAccent,
      );
      return;
    }
    if (_selectedPoint == null) {
      await showInfoDialog(
        context: context,
        icon: Icons.error_outline_rounded,
        title: 'ยังไม่ได้เลือกจุดบริการ',
        message: 'กรุณาเลือกจุดบริการหรือหน่วยเคลื่อนที่ก่อนทำการจอง',
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
          'ตรวจสอบข้อมูลเรียบร้อยแล้วใช่หรือไม่?\nต้องการยืนยันการจองคิวฉีดวัคซีนนี้',
      confirmText: 'ยืนยันการจอง',
      confirmColor: AppColors.primary,
      onConfirm: _saveBooking,
    );
  }

  Future<void> _saveBooking() async {
    setState(() => _saving = true);

    // รวบรวมรายชื่อสัตว์เลี้ยงที่เลือก (จากรายการเดิม + ที่กรอกใหม่)
    final pets = <Map<String, String>>[
      for (final id in _selectedPetIds)
        () {
          final pet = _myPets.firstWhere((p) => p.id == id);
          return {'id': pet.id, 'name': pet.name, 'species': pet.species};
        }(),
      for (final p in _manualPets)
        {'name': p.nameCtrl.text.trim(), 'species': p.species},
    ];

    final code = 'VC${DateTime.now().millisecondsSinceEpoch % 1000000}';
    final now = DateTime.now();

    final record = VaccineBookingRecord(
      id: code,
      pets: pets,
      comboVaccines: _selectedComboOptions.map((o) => o.name).toList(),
      comboTotalPrice: _comboTotalEstimate,
      district: _districtLabel,
      pointName: _selectedPoint!.name,
      pointAddress: _selectedPoint!.address,
      pointType: _selectedPoint!.type == _PointType.mobile ? 'mobile' : 'fixed',
      dateIso: _bookingDate!.toIso8601String(),
      timeSlot: _timeSlot!,
      ownerName: _ownerNameCtrl.text.trim(),
      ownerPhone: _ownerPhoneCtrl.text.trim(),
      note: _noteCtrl.text.trim(),
      createdAtIso: now.toIso8601String(),
    );

    // TODO: เรียก API บันทึกการจองจริง (ปัจจุบันเก็บไว้ใน local storage ก่อน)
    await VaccineBookingStorage.add(record);
    await NotificationStorage.add(NotificationRecord.vaccineSuccess(record));
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _saving = false);

    // เปิดหน้าแสดงรายละเอียดการจองแทนหน้านี้
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder:
            (_) => VaccineBookingDetailPage(record: record, justBooked: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canConfirm =
        _totalPetCount > 0 &&
        _selectedPoint != null &&
        _bookingDate != null &&
        _timeSlot != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarMainApp(
        title: 'จองฉีดวัคซีน',
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
                            builder: (_) => const VaccineBookingHistoryPage(),
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
                              'ดูประวัติการจองฉีดวัคซีนของฉัน',
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

                  // ---- 1. เลือกสัตว์เลี้ยง ----
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Row(
                      children: [
                        Icon(Icons.pets, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'เลือกสัตว์เลี้ยงที่จะพามารับวัคซีน',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: AppColors.greyscale_900,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$_totalPetCount ตัว',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
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
                        for (final pet in _myPets)
                          _MyPetTile(
                            pet: pet,
                            selected: _selectedPetIds.contains(pet.id),
                            formatDate: _formatDate,
                            onTap:
                                () => setState(() {
                                  if (_selectedPetIds.contains(pet.id)) {
                                    _selectedPetIds.remove(pet.id);
                                  } else {
                                    _selectedPetIds.add(pet.id);
                                  }
                                }),
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
                    ),
                  ),

                  if (_manualPets.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    for (int i = 0; i < _manualPets.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ManualPetCard(
                          index: i,
                          pet: _manualPets[i],
                          onRemove: () => _removeManualPet(i),
                        ),
                      ),
                  ],

                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _addManualPet,
                    icon: Icon(Icons.add, color: AppColors.primary, size: 20),
                    label: Text(
                      'เพิ่มสัตว์เลี้ยงที่ยังไม่ได้ลงทะเบียน',
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

                  const SizedBox(height: 18),

                  // ---- 2. ชนิดวัคซีน ----
                  _SectionCard(
                    icon: Icons.vaccines_outlined,
                    title: 'วัคซีนที่จะได้รับ',
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.verified_outlined,
                              size: 20,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'วัคซีนป้องกันโรคพิษสุนัขบ้า',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13.5,
                                      color: AppColors.greyscale_900,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'บริการฟรีตามนโยบาย รวมอยู่ในทุกการจอง',
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
                      const SizedBox(height: 14),
                      Text(
                        'วัคซีนรวมเสริม (เลือกได้มากกว่า 1 รายการ)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.greyscale_900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'มีค่าใช้จ่ายเพิ่มเติม ชำระที่จุดบริการ ราคาคำนวณต่อสัตว์เลี้ยง 1 ตัว',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.greyscale_400,
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (final option in _comboOptions)
                        _ComboVaccineTile(
                          option: option,
                          selected: _selectedComboIds.contains(option.id),
                          onTap: () => _toggleCombo(option.id),
                        ),
                      if (_selectedComboIds.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.greenlight.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calculate_outlined,
                                size: 16,
                                color: AppColors.primarySecondary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'ประมาณการวัคซีนเสริมทั้งหมด ($_totalPetCount ตัว)',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.primarySecondary,
                                  ),
                                ),
                              ),
                              Text(
                                '$_comboTotalEstimate บาท',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primarySecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 18),

                  // ---- 3. เขตพื้นที่ + จุดบริการ ----
                  _SectionCard(
                    icon: Icons.location_on_outlined,
                    title: 'เขตพื้นที่และจุดบริการ',
                    children: [
                      _FormDropdown(
                        label: 'เขตพื้นที่',
                        value: _districtLabel,
                        options: _districtOptions,
                        onChanged:
                            (v) => setState(() {
                              _districtLabel = v;
                              _selectedPoint =
                                  _filteredPoints.isNotEmpty
                                      ? _filteredPoints.first
                                      : null;
                              _timeSlot = null;
                            }),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10, left: 2),
                        child: Text(
                          'เลือกจุดบริการหรือหน่วยเคลื่อนที่ เรียงตามระยะทางใกล้บ้าน',
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
                            'ไม่พบจุดบริการในเขตที่เลือก\nลองเปลี่ยนเขตพื้นที่',
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

                  // ---- 4. วัน / เวลา ----
                  _SectionCard(
                    icon: Icons.event_available_outlined,
                    title: 'วันและเวลานัดหมาย',
                    children: [
                      SharedThaiDatePickerField(
                        label: 'วันที่ต้องการเข้ารับบริการ',
                        date: _bookingDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 60)),
                        required: true,
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
                          'กรุณาเลือกจุดบริการก่อนเพื่อดูช่วงเวลาที่ว่าง',
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
    required this.breed,
    required this.lastVaccinatedDate,
    required this.nextDueDate,
  });

  final String id;
  final String name;
  final String species;
  final String image;
  final String breed;
  final DateTime? lastVaccinatedDate;
  final DateTime? nextDueDate;
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

class _BookingPetEntry {
  final nameCtrl = TextEditingController();
  final breedCtrl = TextEditingController();

  String species = 'สุนัข';
  String gender = 'เพศผู้';

  void dispose() {
    nameCtrl.dispose();
    breedCtrl.dispose();
  }
}

class _ComboVaccineOption {
  const _ComboVaccineOption({
    required this.id,
    required this.name,
    required this.species,
    required this.price,
    required this.description,
  });

  final String id;
  final String name;

  /// 'สุนัข', 'แมว' หรือ null ถ้าใช้ได้ทั้งสองชนิด
  final String? species;
  final int price;
  final String description;
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

// ================================================================
// สัตว์เลี้ยงที่เคยลงทะเบียนไว้แล้ว — เลือกจากรายการ
// ================================================================

class _MyPetTile extends StatelessWidget {
  const _MyPetTile({
    required this.pet,
    required this.selected,
    required this.onTap,
    required this.formatDate,
  });

  final _MyPet pet;
  final bool selected;
  final VoidCallback onTap;
  final String Function(DateTime) formatDate;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    String statusText;
    Color statusColor;
    if (pet.nextDueDate == null) {
      statusText = 'ยังไม่มีประวัติฉีดวัคซีน';
      statusColor = AppColors.greyscale_400;
    } else if (pet.nextDueDate!.isBefore(now)) {
      statusText = 'ถึงกำหนดฉีดแล้ว';
      statusColor = Colors.redAccent;
    } else {
      statusText = 'ครบกำหนดฉีดซ้ำ ${formatDate(pet.nextDueDate!)}';
      statusColor = AppColors.primarySecondary;
    }

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
                    '${pet.name} • ${pet.species}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.greyscale_900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    pet.breed,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.greyscale_400,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
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
// เพิ่มสัตว์เลี้ยงที่ยังไม่ได้ลงทะเบียน (ฟอร์มสั้น)
// ================================================================

class _ManualPetCard extends StatefulWidget {
  const _ManualPetCard({
    required this.index,
    required this.pet,
    required this.onRemove,
  });

  final int index;
  final _BookingPetEntry pet;
  final VoidCallback onRemove;

  @override
  State<_ManualPetCard> createState() => _ManualPetCardState();
}

class _ManualPetCardState extends State<_ManualPetCard> {
  @override
  Widget build(BuildContext context) {
    final pet = widget.pet;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyscale_200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.pets, size: 16, color: AppColors.greyscale_400),
              const SizedBox(width: 6),
              Text(
                'สัตว์เลี้ยงที่ยังไม่ได้ลงทะเบียน #${widget.index + 1}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppColors.greyscale_900,
                ),
              ),
              const Spacer(),
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
          const SizedBox(height: 10),
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
                  onChanged: (v) => setState(() => pet.species = v),
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
          _FormField(
            label: 'พันธุ์ (ถ้าทราบ)',
            controller: pet.breedCtrl,
            hint: 'เช่น พันธุ์ทาง, พุดเดิ้ล, เปอร์เซีย',
          ),
        ],
      ),
    );
  }
}

// ================================================================
// การ์ดเลือกวัคซีนรวมเสริม (เลือกได้หลายรายการ)
// ================================================================

class _ComboVaccineTile extends StatelessWidget {
  const _ComboVaccineTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _ComboVaccineOption option;
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
                  ? AppColors.primaryLight.withOpacity(0.18)
                  : Colors.white,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              selected ? Icons.check_circle : Icons.radio_button_off,
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
                          option.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                            color: AppColors.greyscale_900,
                          ),
                        ),
                      ),
                      if (option.species != null)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            option.species!,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.greyscale_800,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    option.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.greyscale_400,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${option.price} บาท / ตัว',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primarySecondary,
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

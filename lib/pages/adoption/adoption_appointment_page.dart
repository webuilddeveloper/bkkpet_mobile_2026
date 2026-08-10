import 'package:bkkpet/blank_page/appbar.dart';
import 'package:bkkpet/blank_page/custom_dialog.dart';
import 'package:bkkpet/pages/adoption/adoption_models.dart';
import 'package:bkkpet/pages/adoption/adoption_storage.dart';
import 'package:bkkpet/pages/adoption/adoption_status_page.dart';
import 'package:bkkpet/pages/adoption/adoption_ui_kit.dart';
import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';

class AdoptionAppointmentPage extends StatefulWidget {
  const AdoptionAppointmentPage({super.key, required this.application});

  final AdoptionApplication application;

  @override
  State<AdoptionAppointmentPage> createState() =>
      _AdoptionAppointmentPageState();
}

class _AdoptionAppointmentPageState extends State<AdoptionAppointmentPage> {
  static const _locations = [
    'ศูนย์รับเลี้ยงสัตว์ กทม. บางกะปิ',
    'ศูนย์รับเลี้ยงสัตว์ กทม. ประเวศ',
    'สำนักงานสัตวแพทย์สาธารณสุข เขตหนองจอก',
  ];

  static const _timeSlots = [
    '09:00 - 10:00',
    '10:00 - 11:00',
    '13:00 - 14:00',
    '14:00 - 15:00',
  ];

  DateTime? _date;
  String? _timeSlot;
  late String _location = widget.application.appointmentLocation;
  bool _saving = false;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
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
    if (picked != null) setState(() => _date = picked);
  }

  String get _dateText {
    if (_date == null) return '';
    const weekdays = [
      'จันทร์',
      'อังคาร',
      'พุธ',
      'พฤหัสบดี',
      'ศุกร์',
      'เสาร์',
      'อาทิตย์',
    ];
    const months = [
      'มกราคม',
      'กุมภาพันธ์',
      'มีนาคม',
      'เมษายน',
      'พฤษภาคม',
      'มิถุนายน',
      'กรกฎาคม',
      'สิงหาคม',
      'กันยายน',
      'ตุลาคม',
      'พฤศจิกายน',
      'ธันวาคม',
    ];
    final d = _date!;
    return '${weekdays[d.weekday - 1]} ${d.day} ${months[d.month - 1]} ${d.year + 543}';
  }

  Future<void> _confirm() async {
    if (_date == null || _timeSlot == null) {
      await showInfoDialog(
        context: context,
        icon: Icons.error_outline_rounded,
        title: 'ข้อมูลไม่ครบถ้วน',
        message: 'กรุณาเลือกวันที่และช่วงเวลานัดหมาย',
        color: Colors.redAccent,
      );
      return;
    }

    await showConfirmDialog(
      context: context,
      icon: Icons.help_outline_rounded,
      title: 'ยืนยันนัดหมาย',
      message:
          'นัดดูตัว "${widget.application.pet.name}"\n$_dateText ช่วง $_timeSlot\nที่ $_location',
      confirmText: 'ยืนยันนัดหมาย',
      confirmColor: AppColors.primary,
      onConfirm: _save,
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    // TODO: เรียก API บันทึกนัดหมายจริง
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    final app = widget.application;
    app.appointmentDate = _date;
    app.appointmentTimeSlot = _timeSlot;
    app.appointmentLocation = _location;
    app.status = AdoptionStatus.appointment;

    await AdoptionStorage.upsertApplication(app);
    if (!mounted) return;
    setState(() => _saving = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => AdoptionStatusPage(application: app)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarMainApp(
        title: 'นัดหมายดูตัวสัตว์เลี้ยง',
        onBack: () => Navigator.pop(context),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                AdoptionSectionCard(
                  icon: Icons.map_outlined,
                  title: 'สถานที่นัดดูตัว',
                  children: [
                    Column(
                      children:
                          _locations.map((loc) {
                            final selected = _location == loc;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => setState(() => _location = loc),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color:
                                          selected
                                              ? AppColors.primary
                                              : AppColors.greyscale_200,
                                      width: selected ? 1.4 : 1,
                                    ),
                                    color:
                                        selected
                                            ? AppColors.primary.withOpacity(
                                              0.05,
                                            )
                                            : Colors.white,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        selected
                                            ? Icons.radio_button_checked
                                            : Icons.radio_button_off,
                                        size: 18,
                                        color:
                                            selected
                                                ? AppColors.primary
                                                : AppColors.greyscale_300,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          loc,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: AppColors.greyscale_900,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                AdoptionSectionCard(
                  icon: Icons.calendar_month_outlined,
                  title: 'วันและเวลานัดหมาย',
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: _pickDate,
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
                              _dateText.isEmpty ? 'เลือกวันที่' : _dateText,
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    _dateText.isEmpty
                                        ? AppColors.greyscale_300
                                        : AppColors.greyscale_900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'ช่วงเวลา',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.greyscale_400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 2.6,
                      children:
                          _timeSlots.map((slot) {
                            final selected = _timeSlot == slot;
                            return InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () => setState(() => _timeSlot = slot),
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color:
                                        selected
                                            ? AppColors.primary
                                            : AppColors.greyscale_200,
                                    width: selected ? 1.4 : 1,
                                  ),
                                  color:
                                      selected
                                          ? AppColors.primary.withOpacity(0.06)
                                          : Colors.white,
                                ),
                                child: Text(
                                  slot,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        selected
                                            ? AppColors.primary
                                            : AppColors.greyscale_900,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.greyscale_50,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppColors.greyscale_400,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'กรุณามาถึงตรงเวลานัดหมาย เจ้าหน้าที่จะพาไปดูตัวสัตว์เลี้ยงและตอบข้อซักถามเพิ่มเติม',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.greyscale_800,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AdoptionBottomBar(
            child: AdoptionPrimaryButton(
              label: 'ยืนยันนัดหมาย',
              loading: _saving,
              onPressed: _saving ? null : _confirm,
            ),
          ),
        ],
      ),
    );
  }
}

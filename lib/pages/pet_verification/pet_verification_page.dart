import 'package:bkkpet/blank_page/appbar.dart';
import 'package:bkkpet/blank_page/custom_dialog.dart';
import 'package:bkkpet/pages/pet_verification/form_sheet_widget.dart';

import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ================================================================
/// ตรวจสอบเจ้าของสัตว์ / ไมโครชิป
///
/// ครอบคลุม:
///   - ค้นหาข้อมูลสัตว์เลี้ยงด้วยหมายเลขไมโครชิป หรือชื่อสัตว์เลี้ยง
///   - แสดงข้อมูลวันที่ฝังไมโครชิป และประวัติการเปลี่ยนเจ้าของ (timeline)
///   - บันทึกคำขอโอนเจ้าของ สำหรับร้านค้า/ผู้เพาะพันธุ์ (Breeder) ก่อนซื้อ-ขาย
///     ตามมาตรการบังคับข้อมูลไมโครชิปก่อนซื้อขายสัตว์
///
/// หมายเหตุ: ฟีเจอร์ "แจ้งหาย / แจ้งพบสัตว์" แยกไปอีกหน้า LostFoundPage แล้ว
/// ================================================================

class PetVerificationPage extends StatefulWidget {
  const PetVerificationPage({super.key});

  @override
  State<PetVerificationPage> createState() => _PetVerificationPageState();
}

class _PetVerificationPageState extends State<PetVerificationPage> {
  // ---- ค้นหาไมโครชิป ----
  final _searchCtrl = TextEditingController();
  bool _searching = false;
  bool _hasSearched = false;
  _MicrochipRecord? _searchResult;
  late final List<_MicrochipRecord> _mockDatabase;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();

    _mockDatabase = [
      _MicrochipRecord(
        chipId: '985141000123456',
        petName: 'น้องโบโบ้',
        species: 'สุนัข',
        breed: 'พันธุ์ทาง',
        gender: 'เพศผู้',
        implantDate: DateTime(now.year - 3, 4, 12),
        implantedAt: 'คลินิกสัตวแพทย์ เขตจตุจักร',
        currentOwnerName: 'คุณสมชาย ใจดี',
        currentOwnerPhoneMasked: '08x-xxx-4521',
        verified: true,
        history: [
          _OwnershipEvent(
            date: DateTime(now.year - 3, 4, 12),
            type: 'ฝังไมโครชิปครั้งแรก',
            from: 'ฟาร์มเพาะพันธุ์สุนัขบางกะปิ (Breeder)',
            to: 'ฟาร์มเพาะพันธุ์สุนัขบางกะปิ (Breeder)',
          ),
          _OwnershipEvent(
            date: DateTime(now.year - 3, 5, 2),
            type: 'ซื้อขาย',
            from: 'ฟาร์มเพาะพันธุ์สุนัขบางกะปิ (Breeder)',
            to: 'คุณกมลชนก วงศ์สุข',
          ),
          _OwnershipEvent(
            date: DateTime(now.year - 1, 8, 20),
            type: 'โอนย้ายเจ้าของ',
            from: 'คุณกมลชนก วงศ์สุข',
            to: 'คุณสมชาย ใจดี',
          ),
        ],
      ),
      _MicrochipRecord(
        chipId: '985141000998877',
        petName: 'มะลิ',
        species: 'แมว',
        breed: 'เปอร์เซีย',
        gender: 'เพศเมีย',
        implantDate: DateTime(now.year - 1, 11, 3),
        implantedAt: 'ศูนย์บริการสัตวแพทย์ สวนลุมพินี',
        currentOwnerName: 'คุณพิมพ์ชนก รุ่งเรือง',
        currentOwnerPhoneMasked: '09x-xxx-7710',
        verified: true,
        history: [
          _OwnershipEvent(
            date: DateTime(now.year - 1, 11, 3),
            type: 'ฝังไมโครชิปครั้งแรก',
            from: 'เจ้าของเดิม',
            to: 'คุณพิมพ์ชนก รุ่งเรือง',
          ),
        ],
      ),
    ];
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _searchCtrl.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _searching = true;
      _hasSearched = false;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    _MicrochipRecord? match;
    for (final record in _mockDatabase) {
      if (record.chipId.contains(query) ||
          record.petName.contains(query) ||
          query.contains(record.chipId)) {
        match = record;
        break;
      }
    }

    if (!mounted) return;
    setState(() {
      _searching = false;
      _hasSearched = true;
      _searchResult = match;
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

  Future<void> _openTransferRequestSheet() async {
    final chipCtrl = TextEditingController(text: _searchResult?.chipId ?? '');
    final shopCtrl = TextEditingController();
    final buyerNameCtrl = TextEditingController();
    final buyerPhoneCtrl = TextEditingController();

    final bool? success = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return FormBottomSheet(
          title: 'บันทึกคำขอโอนเจ้าของ',
          subtitle:
              'สำหรับร้านค้า/ผู้เพาะพันธุ์ (Breeder) — ต้องบันทึกข้อมูลไมโครชิป'
              'ก่อนทำการซื้อ-ขายหรือโอนกรรมสิทธิ์สัตว์เลี้ยงทุกครั้ง',
          confirmLabel: 'ส่งคำขอโอนเจ้าของ',
          onConfirm: () async {
            if (chipCtrl.text.trim().isEmpty ||
                buyerNameCtrl.text.trim().isEmpty ||
                buyerPhoneCtrl.text.trim().isEmpty) {
              return false;
            }
            return true;
          },
          fields: [
            SheetFormField(
              label: 'หมายเลขไมโครชิป',
              controller: chipCtrl,
              icon: Icons.memory_outlined,
              required: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            SheetFormField(
              label: 'ชื่อร้านค้า / ผู้เพาะพันธุ์ (Breeder)',
              controller: shopCtrl,
              icon: Icons.storefront_outlined,
            ),
            SheetFormField(
              label: 'ชื่อผู้ซื้อ / เจ้าของใหม่',
              controller: buyerNameCtrl,
              icon: Icons.person_outline,
              required: true,
            ),
            SheetFormField(
              label: 'เบอร์โทรผู้ซื้อ',
              controller: buyerPhoneCtrl,
              icon: Icons.call_outlined,
              required: true,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
            ),
          ],
        );
      },
    );

    if (!mounted || success != true) return;

    // การ mock นี้ยังไม่ได้ต่อ API จริง — แสดงผลยืนยันการส่งคำขอ
    await showInfoDialog(
      context: context,
      icon: Icons.check_circle_outline_rounded,
      title: 'ส่งคำขอโอนเจ้าของแล้ว',
      message:
          'บันทึกคำขอโอนเจ้าของเรียบร้อยแล้ว\n'
          'เจ้าหน้าที่จะตรวจสอบและอัปเดตข้อมูลไมโครชิปภายใน 3 วันทำการ',
      color: AppColors.primary,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarMainApp(
        title: 'ตรวจสอบเจ้าของสัตว์',
        onBack: () => Navigator.pop(context),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xffFEF2F2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xffFECACA)),
            ),
            child: const Text(
              'ข้อมูลในหน้านี้เป็นข้อมูลตัวอย่าง (Mock Data)\n'
              'การแสดงผลข้อมูลจริงจะเป็นไปตามระเบียบของสำนักงานสัตวแพทย์สาธารณสุข สำนักอนามัย กรุงเทพมหานคร (สสธ.)',
              style: TextStyle(
                fontSize: 12.5,
                height: 1.55,
                fontWeight: FontWeight.w700,
                color: Color(0xffB91C1C),
              ),
            ),
          ),
          // ---- ช่องค้นหา ----
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.greyscale_200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.memory_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'ค้นหาด้วยหมายเลขไมโครชิปหรือชื่อสัตว์เลี้ยง',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.greyscale_900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'ใช้ตรวจสอบเจ้าของสัตว์เลี้ยงก่อนรับซื้อ-ขาย หรือเมื่อพบสัตว์หลงทาง',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.greyscale_400,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        onSubmitted: (_) => _search(),
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: 'เช่น 985141000123456 หรือ โบโบ้',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: AppColors.greyscale_300,
                          ),
                          filled: true,
                          fillColor: AppColors.greyscale_25,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.greyscale_200,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.greyscale_200,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _searching ? null : _search,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child:
                            _searching
                                ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Text('ค้นหา'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ---- ผลการค้นหา ----
          if (_hasSearched && !_searching)
            _searchResult != null
                ? _MicrochipResultCard(
                  record: _searchResult!,
                  formatDate: _formatDate,
                  onRequestTransfer: _openTransferRequestSheet,
                )
                : const _NoResultCard(),

          const SizedBox(height: 18),

          // ---- มาตรการบังคับข้อมูลไมโครชิปก่อนซื้อขาย ----
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.greenlight.withValues(alpha: 0.6),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.gavel_rounded,
                      size: 18,
                      color: AppColors.primarySecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'มาตรการบังคับข้อมูลไมโครชิปก่อนซื้อขาย',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                          color: AppColors.primarySecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'ร้านค้าและผู้เพาะพันธุ์ (Breeder) ต้องตรวจสอบและบันทึกข้อมูล'
                  'ไมโครชิปของสัตว์เลี้ยงทุกตัวในระบบนี้ ก่อนทำการซื้อ-ขาย'
                  'หรือโอนกรรมสิทธิ์ทุกครั้ง เพื่อให้สามารถตรวจสอบย้อนกลับ'
                  'แหล่งที่มาและเจ้าของได้',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.greyscale_800,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _openTransferRequestSheet,
                    icon: Icon(
                      Icons.assignment_turned_in_outlined,
                      size: 18,
                      color: AppColors.primarySecondary,
                    ),
                    label: Text(
                      'บันทึกคำขอโอนเจ้าของ (ร้านค้า/Breeder)',
                      style: TextStyle(
                        color: AppColors.primarySecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      side: BorderSide(color: AppColors.primarySecondary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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
// Mock models (สำหรับข้อมูลตัวอย่าง — ต่อ API ทะเบียนไมโครชิปจริงภายหลัง)
// ================================================================

class _MicrochipRecord {
  const _MicrochipRecord({
    required this.chipId,
    required this.petName,
    required this.species,
    required this.breed,
    required this.gender,
    required this.implantDate,
    required this.implantedAt,
    required this.currentOwnerName,
    required this.currentOwnerPhoneMasked,
    required this.verified,
    required this.history,
  });

  final String chipId;
  final String petName;
  final String species;
  final String breed;
  final String gender;
  final DateTime implantDate;
  final String implantedAt;
  final String currentOwnerName;
  final String currentOwnerPhoneMasked;
  final bool verified;
  final List<_OwnershipEvent> history;
}

class _OwnershipEvent {
  const _OwnershipEvent({
    required this.date,
    required this.type,
    required this.from,
    required this.to,
  });

  final DateTime date;
  final String type;
  final String from;
  final String to;
}

// ================================================================
// การ์ดผลลัพธ์การค้นหาไมโครชิป
// ================================================================

class _MicrochipResultCard extends StatefulWidget {
  const _MicrochipResultCard({
    required this.record,
    required this.formatDate,
    required this.onRequestTransfer,
  });

  final _MicrochipRecord record;
  final String Function(DateTime) formatDate;
  final VoidCallback onRequestTransfer;

  @override
  State<_MicrochipResultCard> createState() => _MicrochipResultCardState();
}

class _MicrochipResultCardState extends State<_MicrochipResultCard> {
  bool _showHistory = false;

  @override
  Widget build(BuildContext context) {
    final record = widget.record;
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
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Icon(
                  record.species == 'แมว' ? Icons.pets : Icons.pets_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${record.petName} • ${record.species}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.greyscale_900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${record.breed} • ${record.gender}',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.greyscale_400,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.greenlight.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      size: 13,
                      color: AppColors.primarySecondary,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'ยืนยันแล้ว',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primarySecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.greyscale_25,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.memory_outlined,
                  label: 'หมายเลขไมโครชิป',
                  value: record.chipId,
                ),
                _InfoRow(
                  icon: Icons.event_outlined,
                  label: 'วันที่ฝังไมโครชิป',
                  value: widget.formatDate(record.implantDate),
                ),
                _InfoRow(
                  icon: Icons.storefront_outlined,
                  label: 'ฝังที่',
                  value: record.implantedAt,
                ),
                _InfoRow(
                  icon: Icons.person_outline,
                  label: 'เจ้าของปัจจุบัน',
                  value: record.currentOwnerName,
                ),
                _InfoRow(
                  icon: Icons.call_outlined,
                  label: 'เบอร์ติดต่อ',
                  value: record.currentOwnerPhoneMasked,
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => setState(() => _showHistory = !_showHistory),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'ประวัติการเปลี่ยนเจ้าของ (${record.history.length} รายการ)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Icon(
                    _showHistory
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
          if (_showHistory) ...[
            const SizedBox(height: 6),
            for (int i = 0; i < record.history.length; i++)
              _OwnershipTimelineTile(
                event: record.history[i],
                formatDate: widget.formatDate,
                isFirst: i == 0,
                isLast: i == record.history.length - 1,
              ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: widget.onRequestTransfer,
              icon: Icon(
                Icons.swap_horiz_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              label: const Text('บันทึกคำขอโอนเจ้าของใหม่'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                minimumSize: const Size(0, 48),
                side: BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: AppColors.greyscale_400),
          const SizedBox(width: 8),
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: TextStyle(fontSize: 12.5, color: AppColors.greyscale_400),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.greyscale_900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OwnershipTimelineTile extends StatelessWidget {
  const _OwnershipTimelineTile({
    required this.event,
    required this.formatDate,
    required this.isFirst,
    required this.isLast,
  });

  final _OwnershipEvent event;
  final String Function(DateTime) formatDate;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isLast ? AppColors.primary : AppColors.greyscale_300,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 1.5, color: AppColors.greyscale_200),
                ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        event.type,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                          color: AppColors.greyscale_900,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        formatDate(event.date),
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.greyscale_400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    event.from == event.to
                        ? event.to
                        : '${event.from}  →  ${event.to}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.greyscale_400,
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

class _NoResultCard extends StatelessWidget {
  const _NoResultCard();

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
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 36,
            color: AppColors.greyscale_300,
          ),
          const SizedBox(height: 10),
          Text(
            'ไม่พบข้อมูลในระบบ',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: AppColors.greyscale_900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'อาจยังไม่เคยฝังไมโครชิป หรือพิมพ์หมายเลข/ชื่อไม่ถูกต้อง\n'
            'หากพบสัตว์เร่ร่อนไม่มีข้อมูล ลองแจ้งพบสัตว์ที่เมนู "แจ้งหาย & ตามหา"',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: AppColors.greyscale_400),
          ),
        ],
      ),
    );
  }
}

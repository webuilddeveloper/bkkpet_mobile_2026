import 'package:bkkpet/blank_page/appbar.dart';
import 'package:bkkpet/blank_page/custom_dialog.dart';
import 'package:bkkpet/blank_page/bannercarousel.dart';
import 'package:bkkpet/blank_page/custom_textfield.dart';
import 'package:bkkpet/pages/adoption/adoption_ui_kit.dart';
import 'package:bkkpet/pages/chat/message_chat.dart';
import 'package:bkkpet/pages/consult/consult_chat_waiting_page.dart';
import 'package:bkkpet/pages/consult/consult_booking_history_page.dart';
import 'package:bkkpet/pages/consult/consult_booking_page.dart';
import 'package:bkkpet/pages/consult/consult_favorite_doctors_page.dart';
import 'package:bkkpet/pages/consult/consult_favorite_storage.dart';
import 'package:bkkpet/pages/consult/consult_page_models.dart';
import 'package:bkkpet/services/mock_user_store.dart';
import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';

class ConSultPag extends StatefulWidget {
  const ConSultPag({super.key, required this.onTabChange});
  final void Function(int index) onTabChange;

  @override
  State<ConSultPag> createState() => _ConSultPagState();
}

final List<String> banners = [
  'assets/images/banner.png',
  'assets/images/banner2.png',
];

class _ConSultPagState extends State<ConSultPag> {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController _symptomController = TextEditingController();
  final Set<String> _favoriteIds = <String>{};
  String _query = '';
  String _selectedSpecialty = 'ทั้งหมด';
  String _selectedMode = 'ทั้งหมด';
  bool _onlyOnline = false;
  String? _selectedPetId;
  bool _startingQuickChat = false;

  List<String> get _specialties {
    final items =
        consultDoctors.map((d) => d.specialty).toSet().toList()..sort();
    return ['ทั้งหมด', ...items];
  }

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  @override
  void dispose() {
    searchController.dispose();
    _symptomController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final favorites = await ConsultFavoriteStorage.getAll();
    if (!mounted) return;
    setState(
      () =>
          _favoriteIds
            ..clear()
            ..addAll(favorites),
    );
  }

  Future<void> _toggleFavorite(ConsultDoctor doctor) async {
    await ConsultFavoriteStorage.toggle(doctor.id);
    await _loadFavorites();
  }

  Future<void> _openFavoritePage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ConsultFavoriteDoctorsPage()),
    );
    await _loadFavorites();
  }

  Future<void> _startQuickChat() async {
    final symptom = _symptomController.text.trim();
    if (_selectedPetId == null) {
      await showInfoDialog(
        context: context,
        icon: Icons.pets_rounded,
        title: 'เลือกสัตว์เลี้ยงก่อน',
        message: 'กรุณาเลือกสัตว์เลี้ยงที่ต้องการปรึกษา',
        color: Colors.redAccent,
      );
      return;
    }
    if (symptom.isEmpty) {
      await showInfoDialog(
        context: context,
        icon: Icons.assignment_outlined,
        title: 'ระบุอาการก่อน',
        message: 'กรุณากรอกอาการเบื้องต้นเพื่อส่งเข้าระบบ',
        color: Colors.redAccent,
      );
      return;
    }

    final pet = MockUserStore.pets.firstWhere((p) => p.id == _selectedPetId);
    setState(() => _startingQuickChat = true);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => ConsultChatWaitingPage(
              petName: pet.name,
              petSpecies: pet.species,
              symptom: symptom,
            ),
      ),
    );
    if (!mounted) return;
    setState(() => _startingQuickChat = false);
  }

  List<ConsultDoctor> get _filteredDoctors {
    final q = _query.trim().toLowerCase();
    return consultDoctors.where((doctor) {
      final matchesQuery =
          q.isEmpty ||
          doctor.name.toLowerCase().contains(q) ||
          doctor.specialty.toLowerCase().contains(q) ||
          doctor.clinic.toLowerCase().contains(q) ||
          doctor.area.toLowerCase().contains(q) ||
          doctor.description.toLowerCase().contains(q);
      final matchesSpecialty =
          _selectedSpecialty == 'ทั้งหมด' ||
          doctor.specialty == _selectedSpecialty;
      final matchesMode =
          _selectedMode == 'ทั้งหมด' ||
          (_selectedMode == 'แชท' && doctor.isOnlineNow) ||
          (_selectedMode == 'โทร' && doctor.isOnlineNow) ||
          (_selectedMode == 'พบคลินิก');
      final matchesOnline = !_onlyOnline || doctor.isOnlineNow;
      return matchesQuery && matchesSpecialty && matchesMode && matchesOnline;
    }).toList();
  }

  void _openFilterSheet() {
    bool onlyOnline = _onlyOnline;
    String specialty = _selectedSpecialty;
    String mode = _selectedMode;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                14,
                16,
                16 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.greyscale_200,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'ตัวกรอง',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.greyscale_900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'สาขา',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.greyscale_900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final item in _specialties)
                        AdoptionChoiceChip(
                          label: item,
                          selected: specialty == item,
                          onTap: () => setSheetState(() => specialty = item),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'รูปแบบการปรึกษา',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.greyscale_900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final item in const [
                        'ทั้งหมด',
                        'แชท',
                        'โทร',
                        'พบคลินิก',
                      ])
                        AdoptionChoiceChip(
                          label: item,
                          selected: mode == item,
                          onTap: () => setSheetState(() => mode = item),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SwitchListTile.adaptive(
                    value: onlyOnline,
                    onChanged: (v) => setSheetState(() => onlyOnline = v),
                    contentPadding: EdgeInsets.zero,
                    activeTrackColor: AppColors.primaryLight,
                    title: Text(
                      'เฉพาะหมอออนไลน์ตอนนี้',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.greyscale_900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setSheetState(() {
                              specialty = 'ทั้งหมด';
                              mode = 'ทั้งหมด';
                              onlyOnline = false;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primarySecondary,
                            side: BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('ล้างตัวกรอง'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedSpecialty = specialty;
                              _selectedMode = mode;
                              _onlyOnline = onlyOnline;
                            });
                            Navigator.pop(sheetContext);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('ใช้ตัวกรอง'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final doctors = _filteredDoctors;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarMainApp(
        title: 'ปรึกษาสัตวแพทย์',
        onBack: () => widget.onTabChange(0),
        actions: [
          IconButton(
            onPressed: _openFavoritePage,
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.favorite_outline, color: AppColors.primary),
                if (_favoriteIds.isNotEmpty)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      width: 15,
                      height: 15,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          _favoriteIds.length > 9
                              ? '9+'
                              : '${_favoriteIds.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ConsultBookingHistoryPage(),
                ),
              );
            },
            icon: Icon(Icons.event_note_rounded, color: AppColors.primary),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 110),
        children: [
          BannerCarousel(banners: banners),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.greyscale_25,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.greyscale_200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ปรึกษาแชทด่วน',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primarySecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'เลือกสัตว์เลี้ยงของคุณ แล้วกรอกอาการเบื้องต้นก่อนเริ่มแชท',
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    color: AppColors.primarySecondary,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 94,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: MockUserStore.pets.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final pet = MockUserStore.pets[index];
                      return SizedBox(
                        width: 140,
                        child: _QuickPetCard(
                          petName: pet.name,
                          species: pet.species,
                          gender: pet.gender,
                          image: pet.image,
                          selected: _selectedPetId == pet.id,
                          onTap: () => setState(() => _selectedPetId = pet.id),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _symptomController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'อาการเบื้องต้น เช่น ซึม กินน้อย มีไข้ หรือคัน',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: AppColors.greyscale_300,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppColors.greyscale_200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppColors.greyscale_200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _startingQuickChat ? null : _startQuickChat,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child:
                        _startingQuickChat
                            ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Text(
                              'แชทกับแพทย์',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: CustomSearchField(
                  controller: searchController,
                  hintText: 'ค้นหาชื่อหมอ สาขา หรือคลินิก',
                  rightBtn: true,
                  onFilterTap: _openFilterSheet,
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _openFilterSheet,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 45,
                  width: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.greyscale_200),
                  ),
                  child: const Icon(
                    Icons.tune,
                    color: AppColors.greyscale_800,
                    size: 25,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (doctors.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.greyscale_25,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.greyscale_200),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    size: 42,
                    color: AppColors.greyscale_300,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'ไม่พบหมอตามเงื่อนไขที่เลือก',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.greyscale_800,
                    ),
                  ),
                ],
              ),
            )
          else
            for (final doctor in doctors)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DoctorCard(
                  doctor: doctor,
                  isFavorite: _favoriteIds.contains(doctor.id),
                  onFavoriteTap: () => _toggleFavorite(doctor),
                  onReviewTap: () {
                    showInfoDialog(
                      context: context,
                      icon: Icons.star_rounded,
                      title: 'รีวิวหมอ',
                      message:
                          '${doctor.name}\nคะแนนเฉลี่ย ${doctor.rating.toStringAsFixed(1)} จากประสบการณ์ ${doctor.experienceYears} ปี',
                      color: AppColors.primary,
                    );
                  },
                  onChatTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => MessageChatPage(
                              doctorName: doctor.name,
                              profileImage: doctor.imageUrl,
                              isOnline: doctor.isOnlineNow,
                            ),
                      ),
                    );
                  },
                  onBookingTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ConsultBookingPage(doctor: doctor),
                      ),
                    );
                  },
                ),
              ),
        ],
      ),
    );
  }
}

class _QuickPetCard extends StatelessWidget {
  const _QuickPetCard({
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
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.greyscale_200,
            width: selected ? 1.4 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
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
                  const SizedBox(height: 3),
                  Text(
                    '$species • $gender',
                    style: TextStyle(
                      fontSize: 12.3,
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

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({
    required this.doctor,
    required this.isFavorite,
    required this.onFavoriteTap,
    required this.onReviewTap,
    required this.onChatTap,
    required this.onBookingTap,
  });

  final ConsultDoctor doctor;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;
  final VoidCallback onReviewTap;
  final VoidCallback onChatTap;
  final VoidCallback onBookingTap;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              doctor.imageUrl,
              width: 94,
              height: 110,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        doctor.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.greyscale_900,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: onFavoriteTap,
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_outline,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  doctor.specialty,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  doctor.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    color: AppColors.greyscale_400,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _Tag(label: doctor.clinic),
                    _Tag(label: doctor.area),
                    _Tag(label: '${doctor.experienceYears} ปี'),
                    // _Tag(label: '฿${doctor.fee}'),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const SizedBox(width: 4),
                    ElevatedButton(
                      onPressed: onBookingTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.greenlight,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'จองนัด',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(width: 16),

                    InkWell(
                      onTap: onChatTap,
                      child: Image.asset(
                        "assets/icons/icon_chat_1.png",
                        height: 30,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.star, color: Colors.amber.shade700, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      doctor.rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.greyscale_900,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Icon(
                    //   doctor.isOnlineNow ? Icons.circle : Icons.circle_outlined,
                    //   color:
                    //       doctor.isOnlineNow
                    //           ? Colors.green
                    //           : AppColors.greyscale_300,
                    //   size: 10,
                    // ),
                    // const SizedBox(width: 4),
                    // Text(
                    //   doctor.isOnlineNow ? 'ออนไลน์' : 'ออฟไลน์',
                    //   style: TextStyle(
                    //     fontSize: 12,
                    //     color:
                    //         doctor.isOnlineNow
                    //             ? Colors.green
                    //             : AppColors.greyscale_400,
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: AppColors.primarySecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

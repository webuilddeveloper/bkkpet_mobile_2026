import 'package:bkkpet/blank_page/appbar.dart';
import 'package:bkkpet/mock_data.dart';
import 'package:bkkpet/pages/adoption/adoption_detail_page.dart';
import 'package:bkkpet/pages/adoption/adoption_my_applications_page.dart';
import 'package:bkkpet/pages/adoption/adoption_owned_pets_page.dart';
import 'package:bkkpet/pages/adoption/adoption_models.dart';
import 'package:bkkpet/pages/adoption/adoption_ui_kit.dart';
import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';

class AdoptionListPage extends StatefulWidget {
  const AdoptionListPage({super.key});

  @override
  State<AdoptionListPage> createState() => _AdoptionListPageState();
}

class _AdoptionListPageState extends State<AdoptionListPage> {
  final _searchCtrl = TextEditingController();

  String _category = 'สุนัข'; // 'สุนัข' | 'แมว'

  // ---- ตัวกรอง (เดิมอยู่แถวบน ย้ายไปรวมในชีทตัวกรอง) ----
  String? _district;
  String? _breed;
  String? _gender;
  String? _ageGroup;
  String? _size;
  final Set<String> _temperament = {};

  late final List<AdoptionPet> _allPets =
      mockAdoptionPetCatalog.map(AdoptionPet.fromJson).toList();

  List<String> get _breedOptions =>
      _allPets
          .where((p) => p.species == _category)
          .map((p) => p.breed)
          .toSet()
          .toList();

  List<AdoptionPet> get _filteredPets {
    return _allPets.where((p) {
      if (p.species != _category) return false;
      final q = _searchCtrl.text.trim();
      if (q.isNotEmpty &&
          !p.name.contains(q) &&
          !p.breed.contains(q) &&
          !p.district.contains(q) &&
          !p.history.contains(q) &&
          !p.temperament.any((t) => t.contains(q))) {
        return false;
      }
      if (_district != null && p.district != _district) return false;
      if (_breed != null && p.breed != _breed) return false;
      if (_gender != null && p.gender != _gender) return false;
      if (_ageGroup != null && p.ageGroup != _ageGroup) return false;
      if (_size != null && p.size != _size) return false;
      if (_temperament.isNotEmpty &&
          !_temperament.every((t) => p.temperament.contains(t))) {
        return false;
      }
      return true;
    }).toList();
  }

  int get _activeFilterCount =>
      [
        _district,
        _breed,
        _gender,
        _ageGroup,
        _size,
      ].where((e) => e != null).length +
      (_temperament.isNotEmpty ? 1 : 0);

  void _openFilterSheet() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => _FilterSheet(
            district: _district,
            breed: _breed,
            gender: _gender,
            ageGroup: _ageGroup,
            size: _size,
            temperament: _temperament,
            breedOptions: _breedOptions,
            onApply: (f) {
              setState(() {
                _district = f.district;
                _breed = f.breed;
                _gender = f.gender;
                _ageGroup = f.ageGroup;
                _size = f.size;
                _temperament
                  ..clear()
                  ..addAll(f.temperament);
              });
            },
          ),
    );
    if (result == true) setState(() {});
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pets = _filteredPets;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarMainApp(
        title: 'รับเลี้ยงสัตว์',
        onBack: () => Navigator.pop(context),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 2),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdoptionOwnedPetsPage(),
                  ),
                );
              },
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.assignment_turned_in_outlined,
                  size: 19,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdoptionMyApplicationsPage(),
                  ),
                );
              },
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.history_rounded,
                  size: 19,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              children: [
                // Container(
                //   margin: const EdgeInsets.only(bottom: 12),
                //   padding: const EdgeInsets.symmetric(
                //     horizontal: 14,
                //     vertical: 12,
                //   ),
                //   decoration: BoxDecoration(
                //     color: AppColors.primaryLight.withOpacity(0.34),
                //     borderRadius: BorderRadius.circular(14),
                //     border: Border.all(
                //       color: AppColors.greenlight.withOpacity(0.55),
                //     ),
                //   ),
                //   child: Row(
                //     children: [
                //       Icon(
                //         Icons.history_rounded,
                //         size: 18,
                //         color: AppColors.primarySecondary,
                //       ),
                //       const SizedBox(width: 8),
                //       Expanded(
                //         child: Text(
                //           'เลื่อนดูสัตว์ที่พร้อมรับเลี้ยง และใช้ปุ่มมุมขวาบนเพื่อดูรายการที่รับเลี้ยงแล้ว',
                //           style: TextStyle(
                //             fontSize: 13,
                //             fontWeight: FontWeight.w600,
                //             color: AppColors.primarySecondary,
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.greyscale_50,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _CategoryTab(
                          label: 'สุนัข',
                          icon: 'assets/images/dog.png',
                          selected: _category == 'สุนัข',
                          onTap: () => setState(() => _category = 'สุนัข'),
                        ),
                      ),
                      Expanded(
                        child: _CategoryTab(
                          label: 'แมว',
                          icon: 'assets/images/cat.png',
                          selected: _category == 'แมว',
                          onTap: () => setState(() => _category = 'แมว'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.greyscale_200),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: (_) => setState(() {}),
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 14,
                            ),
                            hintText: 'ค้นหาชื่อ พันธุ์ พื้นที่ นิสัย ประวัติ',
                            hintStyle: TextStyle(
                              fontSize: 13,
                              color: AppColors.greyscale_300,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              size: 18,
                              color: AppColors.greyscale_400,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: _openFilterSheet,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Center(
                              child: Icon(
                                Icons.tune_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            if (_activeFilterCount > 0)
                              Positioned(
                                top: -4,
                                right: -4,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    color: Colors.redAccent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '$_activeFilterCount',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
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
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      'พบสัตว์พร้อมรับเลี้ยง ${pets.length} ตัว',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.greyscale_400,
                      ),
                    ),
                    const Spacer(),
                    if (_activeFilterCount > 0)
                      InkWell(
                        onTap: () {
                          setState(() {
                            _district = null;
                            _breed = null;
                            _gender = null;
                            _ageGroup = null;
                            _size = null;
                            _temperament.clear();
                          });
                        },
                        child: Text(
                          'ล้างตัวกรอง',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child:
                pets.isEmpty
                    ? _EmptyState(
                      onReset: () {
                        setState(() {
                          _district = null;
                          _breed = null;
                          _gender = null;
                          _ageGroup = null;
                          _size = null;
                          _temperament.clear();
                          _searchCtrl.clear();
                        });
                      },
                    )
                    : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: pets.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final pet = pets[i];
                        return _AdoptionPetCard(
                          pet: pet,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AdoptionDetailPage(pet: pet),
                              ),
                            );
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTab extends StatelessWidget {
  const _CategoryTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(11),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          boxShadow:
              selected
                  ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                    ),
                  ]
                  : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon(
            //   icon,
            //   size: 17,
            //   color: selected ? AppColors.primary : AppColors.greyscale_400,
            // ),
            Image.asset(
              icon,
              height: 17,
              color: selected ? AppColors.primary : AppColors.greyscale_400,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.primary : AppColors.greyscale_400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdoptionPetCard extends StatelessWidget {
  const _AdoptionPetCard({required this.pet, required this.onTap});

  final AdoptionPet pet;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.greyscale_200),
          borderRadius: BorderRadius.circular(18),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                AdoptionPetAvatarPlaceholder(
                  species: pet.species,
                  imageAsset: pet.imageAsset,
                  height: 180,
                  borderRadius: 0,
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      pet.district,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.greyscale_800,
                      ),
                    ),
                  ),
                ),
                if (pet.sterilized)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'ทำหมันแล้ว',
                        style: TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          pet.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.greyscale_900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.pets_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${pet.breed} · ${pet.gender == 'เพศผู้' ? 'ผู้' : 'เมีย'} · ${pet.ageLabel}',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.greyscale_400,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      AdoptionTag(label: pet.species),
                      AdoptionTag(label: 'ขนาด${pet.size}'),
                      AdoptionTag(label: pet.ageGroup),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    pet.history,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.5,
                      color: AppColors.greyscale_400,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children:
                        pet.temperament
                            .take(3)
                            .map((t) => AdoptionTag(label: t))
                            .toList(),
                  ),
                  const SizedBox(height: 14),
                  AdoptionPrimaryButton(
                    label: 'ดูรายละเอียด',
                    onPressed: onTap,
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 40,
              color: AppColors.greyscale_300,
            ),
            const SizedBox(height: 12),
            Text(
              'ไม่พบสัตว์เลี้ยงที่ตรงกับตัวกรอง',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.greyscale_800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'ลองปรับตัวกรองหรือค้นหาด้วยคำอื่น',
              style: TextStyle(fontSize: 12, color: AppColors.greyscale_400),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onReset,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'ล้างตัวกรองทั้งหมด',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// ชีตตัวกรอง — รวม เขต พันธุ์ เพศ อายุ ขนาด นิสัย ไว้ที่เดียว
// ================================================================

class _FilterResult {
  _FilterResult({
    this.district,
    this.breed,
    this.gender,
    this.ageGroup,
    this.size,
    required this.temperament,
  });

  final String? district;
  final String? breed;
  final String? gender;
  final String? ageGroup;
  final String? size;
  final Set<String> temperament;
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.district,
    required this.breed,
    required this.gender,
    required this.ageGroup,
    required this.size,
    required this.temperament,
    required this.breedOptions,
    required this.onApply,
  });

  final String? district;
  final String? breed;
  final String? gender;
  final String? ageGroup;
  final String? size;
  final Set<String> temperament;
  final List<String> breedOptions;
  final ValueChanged<_FilterResult> onApply;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  static const _districts = [
    'บางกะปิ',
    'บางนา',
    'ลาดพร้าว',
    'สวนหลวง',
    'จตุจักร',
    'ห้วยขวาง',
  ];
  static const _genders = ['เพศผู้', 'เพศเมีย'];
  static const _ageGroups = ['ลูกสัตว์', 'โตเต็มวัย', 'สูงวัย'];
  static const _sizes = ['เล็ก', 'กลาง', 'ใหญ่'];
  static const _temperamentOptions = [
    'ขี้เล่น',
    'เป็นมิตร',
    'ขี้อ้อน',
    'เงียบ',
    'ว่านอนสอนง่าย',
    'ตื่นตัว',
  ];

  late String? _district = widget.district;
  late String? _breed = widget.breed;
  late String? _gender = widget.gender;
  late String? _ageGroup = widget.ageGroup;
  late String? _size = widget.size;
  late final Set<String> _temperament = {...widget.temperament};

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8, top: 4),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.greyscale_900,
      ),
    ),
  );

  Widget _chipGroup({
    required List<String> options,
    required String? selected,
    required ValueChanged<String?> onSelect,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          options.map((o) {
            final isSelected = selected == o;
            return AdoptionChoiceChip(
              label: o,
              selected: isSelected,
              onTap: () => onSelect(isSelected ? null : o),
            );
          }).toList(),
    );
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
                    Text(
                      'ตัวกรอง',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.greyscale_900,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _district = null;
                          _breed = null;
                          _gender = null;
                          _ageGroup = null;
                          _size = null;
                          _temperament.clear();
                        });
                      },
                      child: Text(
                        'ล้างทั้งหมด',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  children: [
                    _sectionLabel('เขต / พื้นที่'),
                    _chipGroup(
                      options: _districts,
                      selected: _district,
                      onSelect: (v) => setState(() => _district = v),
                    ),
                    _sectionLabel('พันธุ์'),
                    _chipGroup(
                      options: widget.breedOptions,
                      selected: _breed,
                      onSelect: (v) => setState(() => _breed = v),
                    ),
                    _sectionLabel('เพศ'),
                    _chipGroup(
                      options: _genders,
                      selected: _gender,
                      onSelect: (v) => setState(() => _gender = v),
                    ),
                    _sectionLabel('อายุ'),
                    _chipGroup(
                      options: _ageGroups,
                      selected: _ageGroup,
                      onSelect: (v) => setState(() => _ageGroup = v),
                    ),
                    _sectionLabel('ขนาด'),
                    _chipGroup(
                      options: _sizes,
                      selected: _size,
                      onSelect: (v) => setState(() => _size = v),
                    ),
                    _sectionLabel('ลักษณะนิสัย (เลือกได้หลายข้อ)'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          _temperamentOptions.map((o) {
                            final isSelected = _temperament.contains(o);
                            return AdoptionChoiceChip(
                              label: o,
                              selected: isSelected,
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _temperament.remove(o);
                                  } else {
                                    _temperament.add(o);
                                  }
                                });
                              },
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
              AdoptionBottomBar(
                child: AdoptionPrimaryButton(
                  label: 'แสดงผลลัพธ์',
                  onPressed: () {
                    widget.onApply(
                      _FilterResult(
                        district: _district,
                        breed: _breed,
                        gender: _gender,
                        ageGroup: _ageGroup,
                        size: _size,
                        temperament: _temperament,
                      ),
                    );
                    Navigator.pop(context, true);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

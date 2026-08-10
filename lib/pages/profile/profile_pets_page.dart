import 'package:bkkpet/blank_page/appbar.dart';
import 'package:bkkpet/services/mock_user_store.dart';
import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';

class ProfilePetsPage extends StatefulWidget {
  const ProfilePetsPage({super.key});

  @override
  State<ProfilePetsPage> createState() => _ProfilePetsPageState();
}

class _ProfilePetsPageState extends State<ProfilePetsPage> {
  Future<void> _editPet(MockPetProfile pet) async {
    final nameCtrl = TextEditingController(text: pet.name);
    final breedCtrl = TextEditingController(text: pet.breed);
    final colorCtrl = TextEditingController(text: pet.color);
    final traitsCtrl = TextEditingController(text: pet.traits);
    var species = pet.species;
    var gender = pet.gender;

    await showModalBottomSheet<void>(
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
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
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
                    const SizedBox(height: 18),
                    Text(
                      'แก้ไขข้อมูลสัตว์เลี้ยง',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.greyscale_900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _ReadonlyField(
                      label: 'เลขไมโครชิป',
                      value:
                          pet.microchipNumber.isEmpty
                              ? 'ไม่มีข้อมูล'
                              : pet.microchipNumber,
                    ),
                    const SizedBox(height: 10),
                    _EditField(label: 'ชื่อสัตว์เลี้ยง', controller: nameCtrl),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _ChoiceField(
                            label: 'ประเภท',
                            value: species,
                            options: const ['สุนัข', 'แมว'],
                            onChanged:
                                (value) => setSheetState(() => species = value),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ChoiceField(
                            label: 'เพศ',
                            value: gender,
                            options: const ['เพศผู้', 'เพศเมีย', 'ไม่ระบุ'],
                            onChanged:
                                (value) => setSheetState(() => gender = value),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _EditField(label: 'พันธุ์', controller: breedCtrl),
                    const SizedBox(height: 10),
                    _EditField(label: 'สี', controller: colorCtrl),
                    const SizedBox(height: 10),
                    _EditField(
                      label: 'ลักษณะเด่น',
                      controller: traitsCtrl,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          MockUserStore.upsertPet(
                            MockPetProfile(
                              id: pet.id,
                              name: nameCtrl.text.trim(),
                              species: species,
                              image: pet.image,
                              gender: gender,
                              breed: breedCtrl.text.trim(),
                              ageYears: pet.ageYears,
                              weightKg: pet.weightKg,
                              color: colorCtrl.text.trim(),
                              traits: traitsCtrl.text.trim(),
                              microchipNumber: pet.microchipNumber,
                              microchipLocation: pet.microchipLocation,
                              birthDate: pet.birthDate,
                              chipDate: pet.chipDate,
                            ),
                          );
                          if (mounted) setState(() {});
                          Navigator.pop(sheetContext);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'บันทึกข้อมูล',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    nameCtrl.dispose();
    breedCtrl.dispose();
    colorCtrl.dispose();
    traitsCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pets = MockUserStore.pets;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarMainApp(
        title: 'สัตว์เลี้ยงของฉัน',
        onBack: () => Navigator.pop(context),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          // Container(
          //   padding: const EdgeInsets.all(14),
          //   decoration: BoxDecoration(
          //     color: AppColors.primaryLight.withValues(alpha: 0.24),
          //     borderRadius: BorderRadius.circular(16),
          //     border: Border.all(
          //       color: AppColors.greenlight.withValues(alpha: 0.55),
          //     ),
          //   ),
          //   child: Text(
          //     'รายการสัตว์เลี้ยงทั้งหมดที่ผูกกับบัญชีผู้ใช้',
          //     style: TextStyle(
          //       fontSize: 12.5,
          //       height: 1.45,
          //       fontWeight: FontWeight.w600,
          //       color: AppColors.primarySecondary,
          //     ),
          //   ),
          // ),
          // const SizedBox(height: 16),
          for (final pet in pets) ...[
            _PetCard(
              name: pet.name,
              species: pet.species,
              gender: pet.gender,
              age: pet.ageYears,
              image: pet.image,
              breed: pet.breed,
              color: pet.color,
              traits: pet.traits,
              onTap: () => _editPet(pet),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _PetCard extends StatelessWidget {
  const _PetCard({
    required this.name,
    required this.species,
    required this.gender,
    required this.age,
    required this.image,
    required this.breed,
    required this.color,
    required this.traits,
    required this.onTap,
  });

  final String name;
  final String species;
  final String gender;
  final String age;
  final String image;
  final String breed;
  final String color;
  final String traits;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(70),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(70),
          border: Border.all(color: AppColors.greyscale_200),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(35),
              child: Image.asset(
                image,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.greyscale_900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$species • $gender • อายุ $age ปี',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.greyscale_400,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'พันธุ์ $breed • สี $color',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.greyscale_800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    traits,
                    style: TextStyle(
                      fontSize: 12.2,
                      color: AppColors.primarySecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.edit_outlined, size: 18, color: AppColors.greyscale_400),
          ],
        ),
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  const _EditField({
    required this.label,
    required this.controller,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.greyscale_50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.greyscale_200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.greyscale_200),
        ),
      ),
    );
  }
}

class _ReadonlyField extends StatelessWidget {
  const _ReadonlyField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.greyscale_50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.greyscale_200),
        ),
      ),
      child: Text(value),
    );
  }
}

class _ChoiceField extends StatelessWidget {
  const _ChoiceField({
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
    return DropdownButtonFormField<String>(
      initialValue: options.contains(value) ? value : options.first,
      items:
          options
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.greyscale_50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.greyscale_200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.greyscale_200),
        ),
      ),
    );
  }
}

import 'package:bkkpet/blank_page/appbar.dart';
import 'package:bkkpet/pages/adoption/adoption_owned_pet_detail_page.dart';
import 'package:bkkpet/pages/adoption/adoption_models.dart';
import 'package:bkkpet/pages/adoption/adoption_storage.dart';
import 'package:bkkpet/pages/adoption/adoption_ui_kit.dart';
import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';

class AdoptionOwnedPetsPage extends StatefulWidget {
  const AdoptionOwnedPetsPage({super.key});

  @override
  State<AdoptionOwnedPetsPage> createState() => _AdoptionOwnedPetsPageState();
}

class _AdoptionOwnedPetsPageState extends State<AdoptionOwnedPetsPage> {
  Future<List<AdoptionAdoptedRecord>>? _future;

  @override
  void initState() {
    super.initState();
    _future = AdoptionStorage.loadRecords();
  }

  Future<void> _reload() async {
    setState(() {
      _future = AdoptionStorage.loadRecords();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarMainApp(
        title: 'สัตว์ที่ฉันรับเลี้ยงแล้ว',
        onBack: () => Navigator.pop(context),
      ),
      body: FutureBuilder<List<AdoptionAdoptedRecord>>(
        future: _future,
        builder: (context, snapshot) {
          final records = snapshot.data ?? const <AdoptionAdoptedRecord>[];

          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.32),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.greenlight.withValues(alpha: 0.55),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.volunteer_activism_rounded,
                        size: 18,
                        color: AppColors.primarySecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'แตะรายการเพื่อส่งข้อมูลอัปเดตให้เจ้าหน้าที่ได้',
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
                if (records.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: Column(
                      children: [
                        Icon(
                          Icons.pets_outlined,
                          size: 44,
                          color: AppColors.greyscale_300,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'ยังไม่มีสัตว์ที่รับเลี้ยงในรายการ',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.greyscale_400,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...records.map(
                    (record) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () async {
                          final result = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => AdoptionOwnedPetDetailPage(
                                    record: record,
                                  ),
                            ),
                          );
                          if (result == true && mounted) {
                            _reload();
                          }
                        },
                        child: Container(
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
                                child: AdoptionPetAvatarPlaceholder(
                                  species: record.pet.species,
                                  imageAsset: record.pet.imageAsset,
                                  height: 64,
                                  borderRadius: 14,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      record.pet.name,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.greyscale_900,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${record.pet.breed} · ${record.pet.gender} · ${record.pet.ageLabel}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.greyscale_400,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: [
                                        AdoptionTag(label: record.statusText),
                                        AdoptionTag(label: record.pet.district),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.greyscale_300,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

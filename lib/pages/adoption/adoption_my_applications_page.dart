import 'package:bkkpet/blank_page/appbar.dart';
import 'package:bkkpet/blank_page/incident_input_widgets.dart';
import 'package:bkkpet/pages/adoption/adoption_models.dart';
import 'package:bkkpet/pages/adoption/adoption_status_page.dart';
import 'package:bkkpet/pages/adoption/adoption_storage.dart';
import 'package:bkkpet/pages/adoption/adoption_ui_kit.dart';
import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';

class AdoptionMyApplicationsPage extends StatefulWidget {
  const AdoptionMyApplicationsPage({super.key});

  @override
  State<AdoptionMyApplicationsPage> createState() =>
      _AdoptionMyApplicationsPageState();
}

class _AdoptionMyApplicationsPageState
    extends State<AdoptionMyApplicationsPage> {
  Future<List<AdoptionApplication>>? _future;

  @override
  void initState() {
    super.initState();
    _future = AdoptionStorage.loadApplications();
  }

  Future<void> _reload() async {
    setState(() {
      _future = AdoptionStorage.loadApplications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarMainApp(
        title: 'คำขอรับเลี้ยงของฉัน',
        onBack: () => Navigator.pop(context),
      ),
      body: FutureBuilder<List<AdoptionApplication>>(
        future: _future,
        builder: (context, snapshot) {
          final apps = snapshot.data ?? const <AdoptionApplication>[];

          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                const IncidentNoticeBanner(
                  title: 'เปิดดูสถานะได้ทุกเมื่อ',
                  message:
                      'แตะรายการเพื่อกลับไปดูสถานะล่าสุด และลองเปลี่ยนสถานะทดสอบได้ในหน้ารายละเอียด',
                ),
                if (apps.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: Column(
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 44,
                          color: AppColors.greyscale_300,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'ยังไม่มีคำขอรับเลี้ยงที่ส่งไว้',
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
                  ...apps.map(
                    (app) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () async {
                          final updated = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => AdoptionStatusPage(application: app),
                            ),
                          );
                          if (updated == true && mounted) {
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
                                  species: app.pet.species,
                                  imageAsset: app.pet.imageAsset,
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
                                      app.pet.name,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.greyscale_900,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${app.pet.breed} · ${app.pet.gender} · ${app.pet.ageLabel}',
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
                                        AdoptionTag(label: app.status.label),
                                        AdoptionTag(label: app.applicantName),
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

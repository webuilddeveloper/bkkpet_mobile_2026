import 'package:bkkpet/blank_page/appbar.dart';
import 'package:bkkpet/mock_data.dart';
import 'package:bkkpet/pages/adoption/adoption_list_page.dart';
import 'package:bkkpet/pages/lostpet/lost_found_page.dart';
import 'package:bkkpet/pages/pet_regis.dart';
import 'package:bkkpet/pages/pet_verification/pet_verification_page.dart';
import 'package:bkkpet/pages/reportIncident_page.dart';
import 'package:bkkpet/pages/sterilization/sterilization_page.dart';
import 'package:bkkpet/pages/vaccine/vaccine_page.dart';
import 'package:bkkpet/services/local_notification_service.dart';
import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeServicesAllPage extends StatefulWidget {
  const HomeServicesAllPage({
    super.key,
    required this.isLoggedIn,
    required this.openProtectedPage,
  });

  final bool isLoggedIn;
  final Future<void> Function(Widget page) openProtectedPage;

  @override
  State<HomeServicesAllPage> createState() => _HomeServicesAllPageState();
}

class _HomeServicesAllPageState extends State<HomeServicesAllPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(LocalNotificationService.showChatuchakRiskWelcomeOnce);
  }

  @override
  Widget build(BuildContext context) {
    final services = mockHomeServiceCategories.map(_serviceFromMock).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarMainApp(
        title: 'บริการทั้งหมด',
        onBack: () => Navigator.pop(context),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.greenlight.withValues(alpha: 0.6),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: AppColors.primarySecondary,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'พื้นที่เฝ้าระวังเริ่มต้น: เขตจตุจักร',
                    style: TextStyle(
                      color: AppColors.primarySecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  'แจ้งเตือนอัตโนมัติ',
                  style: TextStyle(
                    color: AppColors.greyscale_400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: services.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 6,
              childAspectRatio: 0.70,
            ),
            itemBuilder: (context, index) {
              final item = services[index];
              return _ServiceGridItem(
                item: item,
                isLoggedIn: widget.isLoggedIn,
              );
            },
          ),
        ],
      ),
    );
  }

  _ServiceItem _serviceFromMock(Map<String, dynamic> item) {
    final id = item['id'] as String;
    return _ServiceItem(
      id: id,
      title: item['title'] as String,
      image: item['image'] as String,
      locked: _isProtectedService(id),
      onTap: () => _openService(id),
    );
  }

  bool _isProtectedService(String id) =>
      id == '1' || id == '2' || id == '3' || id == '4';

  void _openService(String id) {
    switch (id) {
      case '1':
        widget.openProtectedPage(const PetRegisPage());
        break;
      case '2':
        widget.openProtectedPage(const VaccinePage());
        break;
      case '3':
        widget.openProtectedPage(const Sterilizationpage());
        break;
      case '4':
        widget.openProtectedPage(const PetVerificationPage());
        break;
      case '5':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReportIncidentPage()),
        );
        break;
      case '6':
        LocalNotificationService.showRiskAreaAlert(
          title: 'เฝ้าระวังโรคสัตว์สู่คน',
          body:
              'เขตจตุจักรมีการแจ้งสัตว์ป่วยผิดปกติ โปรดหลีกเลี่ยงการสัมผัสและติดตามประกาศพื้นที่เสี่ยง',
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ZoonoticDiseasePage()),
        );
        break;
      case '7':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PetFriendlyParkPage()),
        );
        break;
      case '8':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdoptionListPage()),
        );
        break;
      case '9':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LostFoundPage()),
        );
        break;
      case '10':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NearbyClinicsPage()),
        );
        break;
    }
  }
}

class _ServiceItem {
  const _ServiceItem({
    required this.id,
    required this.title,
    required this.image,
    required this.locked,
    required this.onTap,
  });

  final String id;
  final String title;
  final String image;
  final bool locked;
  final VoidCallback onTap;
}

class _ServiceGridItem extends StatelessWidget {
  const _ServiceGridItem({required this.item, required this.isLoggedIn});

  final _ServiceItem item;
  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: item.onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final circleSize = constraints.maxWidth * 0.78;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Container(
                    width: circleSize,
                    height: circleSize,
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.greyscale_200,
                        width: 1.15,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.asset(item.image, fit: BoxFit.cover),
                    ),
                  ),
                  if (item.locked && !isLoggedIn)
                    Positioned(
                      right: 1,
                      bottom: 1,
                      child: Container(
                        padding: const EdgeInsets.all(2.5),
                        decoration: const BoxDecoration(
                          color: Colors.black87,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_rounded,
                          size: 9,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                item.title,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.greyscale_900,
                  height: 1.1,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ZoonoticDiseasePage extends StatelessWidget {
  const ZoonoticDiseasePage({super.key});

  @override
  Widget build(BuildContext context) {
    final hotspots = <_HotspotPoint>[
      const _HotspotPoint(
        name: 'จุดแจ้งสัตว์ป่วยผิดปกติ',
        area: 'แขวงจอมพล เขตจตุจักร',
        severity: 'สูง',
        position: Alignment(-0.32, -0.15),
      ),
      const _HotspotPoint(
        name: 'จุดเฝ้าระวังภาคสนาม',
        area: 'แขวงลาดยาว เขตจตุจักร',
        severity: 'ปานกลาง',
        position: Alignment(0.24, 0.18),
      ),
      const _HotspotPoint(
        name: 'รายงานสัตว์ตายผิดปกติ',
        area: 'แนวรัศมี 5 กม.',
        severity: 'ต้องติดตาม',
        position: Alignment(0.02, -0.38),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarMainApp(
        title: 'เฝ้าระวังโรคสัตว์สู่คน',
        onBack: () => Navigator.pop(context),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.greenlight.withValues(alpha: 0.55),
              ),
            ),
            child: Text(
              'พื้นที่เฝ้าระวังตั้งต้น: เขตจตุจักร\nระบบจะแสดงจุดเสี่ยงบนพื้นที่และแจ้งเตือนผู้ใช้งานที่อยู่ในรัศมีประมาณ 5 กิโลเมตร',
              style: TextStyle(
                color: AppColors.primarySecondary,
                fontSize: 13,
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 240,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.greyscale_200),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primaryLight.withValues(alpha: 0.12),
                          AppColors.greyscale_25,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(child: CustomPaint(painter: _RiskMapPainter())),
                Positioned(
                  left: 12,
                  top: 12,
                  child: _MapLegend(
                    label: 'รัศมีแจ้งเตือน 5 กม.',
                    color: AppColors.primary,
                  ),
                ),
                for (final hotspot in hotspots)
                  Align(
                    alignment: hotspot.position,
                    child: _HotspotMarker(point: hotspot),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...hotspots.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _HotspotCard(point: point),
            ),
          ),
        ],
      ),
    );
  }
}

class PetFriendlyParkPage extends StatelessWidget {
  const PetFriendlyParkPage({super.key});

  @override
  Widget build(BuildContext context) {
    final places = <PetFriendlyPlace>[
      const PetFriendlyPlace(
        id: 'p1',
        name: 'สวนป่าประชานิเวศน์',
        area: 'แขวงลาดยาว เขตจตุจักร',
        image: 'assets/images/petpark.jpeg',
        openHours: 'เปิด 24 ชั่วโมง',
        highlight: 'มี Dog Park และพื้นที่ร่มรื่นสำหรับเดินเล่น',
        address:
            'ถนนเทศบาลนิมิตใต้ ซอย 13 แขวงลาดยาว เขตจตุจักร กรุงเทพมหานคร 10900',
        details:
            'สวนขนาดย่อมในเขตจตุจักรที่มี Dog park พื้นที่เดินเล่น และจุดจอดรถ เหมาะสำหรับพาสัตว์เลี้ยงมาผ่อนคลายและออกกำลังกาย',
        rules:
            'ควบคุมสัตว์เลี้ยงตลอดเวลา เก็บมูลทันที และปฏิบัติตามกฎของพื้นที่สาธารณะ',
        mapQuery: 'สวนป่าประชานิเวศน์ เขตจตุจักร กรุงเทพฯ',
      ),
      const PetFriendlyPlace(
        id: 'p2',
        name: 'สวนวชิรเบญจทัศ (สวนรถไฟ)',
        area: 'แขวงลาดยาว เขตจตุจักร',
        image: 'assets/images/petpark2.webp',
        openHours: 'ทุกวัน 04:30 - 21:00',
        highlight: 'Pet friendly และมีพื้นที่สำหรับออกกำลังกาย',
        address: 'ถนนกำแพงเพชร 3 แขวงลาดยาว เขตจตุจักร กรุงเทพมหานคร 10900',
        details:
            'สวนสาธารณะขนาดใหญ่ในเขตจตุจักร มีพื้นที่สำหรับคนและสัตว์เลี้ยง พร้อมสิ่งอำนวยความสะดวกและทางเดินออกกำลังกาย',
        rules: 'นำสายจูงตลอดเวลา พกถุงเก็บมูล และเคารพผู้ใช้งานพื้นที่อื่น',
        mapQuery: 'สวนวชิรเบญจทัศ เขตจตุจักร กรุงเทพฯ',
      ),
      const PetFriendlyPlace(
        id: 'p3',
        name: 'Benjakitti Park Dog Park',
        area: 'คลองเตย กรุงเทพมหานคร',
        image: 'assets/images/petpark3.jpeg',
        openHours: 'ทุกวัน 04:30 - 22:00',
        highlight: 'Dog Park ขนาดใหญ่และต้องลงทะเบียนก่อนเข้าใช้',
        address: 'ถนนรัชดาภิเษก แขวงคลองเตย เขตคลองเตย กรุงเทพมหานคร 10110',
        details:
            'สวนป่าในเมืองที่มี Dog Park สำหรับสัตว์เลี้ยงโดยเฉพาะ พร้อมกติกาการใช้งานชัดเจนและจุดเข้าออกสำหรับผู้ใช้บริการ',
        rules:
            'ลงทะเบียนก่อนเข้าใช้ ใช้สายจูงตลอดเวลา และทำความสะอาดพื้นที่ทุกครั้ง',
        mapQuery: 'Benjakitti Park Dog Park กรุงเทพฯ',
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarMainApp(
        title: 'Pet Friendly / Dog Park / Pet Park',
        onBack: () => Navigator.pop(context),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.greenlight.withValues(alpha: 0.55),
              ),
            ),
            child: Text(
              'รายชื่อพื้นที่ Pet Friendly, Dog Park และ Pet Park ที่กดดูรายละเอียดและนำทางต่อได้',
              style: TextStyle(
                color: AppColors.primarySecondary,
                fontSize: 13,
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          for (final place in places) ...[
            _PetFriendlyCard(
              place: place,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PetFriendlyPlaceDetailPage(place: place),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class PetFriendlyPlace {
  const PetFriendlyPlace({
    required this.id,
    required this.name,
    required this.area,
    required this.image,
    required this.openHours,
    required this.highlight,
    required this.address,
    required this.details,
    required this.rules,
    required this.mapQuery,
  });

  final String id;
  final String name;
  final String area;
  final String image;
  final String openHours;
  final String highlight;
  final String address;
  final String details;
  final String rules;
  final String mapQuery;
}

class _PetFriendlyCard extends StatelessWidget {
  const _PetFriendlyCard({required this.place, required this.onTap});

  final PetFriendlyPlace place;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.greyscale_200),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                place.image,
                width: 84,
                height: 84,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: TextStyle(
                      color: AppColors.greyscale_900,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    place.area,
                    style: TextStyle(
                      color: AppColors.greyscale_400,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    place.highlight,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.primarySecondary,
                      fontSize: 12.5,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          place.openHours,
                          style: TextStyle(
                            color: AppColors.primarySecondary,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'แตะดูรายละเอียด',
                        style: TextStyle(
                          color: AppColors.greyscale_400,
                          fontSize: 11,
                        ),
                      ),
                    ],
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

class PetFriendlyPlaceDetailPage extends StatelessWidget {
  const PetFriendlyPlaceDetailPage({super.key, required this.place});

  final PetFriendlyPlace place;

  Future<void> _openMaps() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(place.mapQuery)}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarMainApp(
        title: place.name,
        onBack: () => Navigator.pop(context),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(place.image, height: 220, fit: BoxFit.cover),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.greenlight.withValues(alpha: 0.55),
              ),
            ),
            child: Text(
              place.highlight,
              style: TextStyle(
                color: AppColors.primarySecondary,
                fontSize: 13.5,
                height: 1.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _DetailRow(title: 'พื้นที่', value: place.area),
          _DetailRow(title: 'เวลาเปิด-ปิด', value: place.openHours),
          _DetailRow(title: 'ที่อยู่', value: place.address),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.greyscale_200),
            ),
            child: Text(
              place.details,
              style: TextStyle(
                color: AppColors.greyscale_400,
                fontSize: 12.8,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.greyscale_200),
            ),
            child: Text(
              'กติกาการใช้พื้นที่\n${place.rules}',
              style: TextStyle(
                color: AppColors.greyscale_400,
                fontSize: 12.8,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _openMaps,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.directions_rounded),
              label: const Text('นำทางไปที่นี่'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyscale_200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.greyscale_400,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: AppColors.greyscale_900,
              fontSize: 13.5,
              height: 1.45,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HotspotPoint {
  const _HotspotPoint({
    required this.name,
    required this.area,
    required this.severity,
    required this.position,
  });

  final String name;
  final String area;
  final String severity;
  final Alignment position;
}

class _HotspotMarker extends StatelessWidget {
  const _HotspotMarker({required this.point});

  final _HotspotPoint point;

  @override
  Widget build(BuildContext context) {
    final severityColor = switch (point.severity) {
      'สูง' => Colors.redAccent,
      'ปานกลาง' => Colors.orange,
      _ => AppColors.primary,
    };

    return Transform.translate(
      offset: const Offset(0, -6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: severityColor.withValues(alpha: 0.35)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              point.severity,
              style: TextStyle(
                color: severityColor,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: severityColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: severityColor.withValues(alpha: 0.35),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RiskMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint =
        Paint()
          ..color = AppColors.greyscale_200
          ..strokeWidth = 1;

    for (double y = 0; y <= size.height; y += size.height / 6) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
    for (double x = 0; x <= size.width; x += size.width / 6) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }

    final radiusPaint =
        Paint()
          ..color = AppColors.primary.withValues(alpha: 0.08)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
    canvas.drawCircle(
      Offset(size.width * 0.55, size.height * 0.48),
      size.shortestSide * 0.30,
      radiusPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.55, size.height * 0.48),
      size.shortestSide * 0.18,
      radiusPaint..color = AppColors.primary.withValues(alpha: 0.16),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MapLegend extends StatelessWidget {
  const _MapLegend({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.greyscale_200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: AppColors.greyscale_900,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HotspotCard extends StatelessWidget {
  const _HotspotCard({required this.point});

  final _HotspotPoint point;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyscale_200),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_rounded,
              color: Colors.redAccent,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  point.name,
                  style: TextStyle(
                    color: AppColors.greyscale_900,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  point.area,
                  style: TextStyle(
                    color: AppColors.greyscale_400,
                    fontSize: 12.5,
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

class NearbyClinicsPage extends StatelessWidget {
  const NearbyClinicsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final clinics = _clinicItems;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarMainApp(
        title: 'คลินิกใกล้ฉัน',
        onBack: () => Navigator.pop(context),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
        children: [
          ...clinics.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ClinicCard(
                item: item,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ClinicDetailPage(item: item),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ClinicItem {
  const ClinicItem({
    required this.id,
    required this.name,
    required this.image,
    required this.area,
    required this.distance,
    required this.rating,
    required this.reviews,
    required this.address,
    required this.phone,
    required this.openHours,
    required this.services,
    required this.note,
  });

  final String id;
  final String name;
  final String image;
  final String area;
  final String distance;
  final double rating;
  final int reviews;
  final String address;
  final String phone;
  final String openHours;
  final List<String> services;
  final String note;
}

final List<ClinicItem> _clinicItems = [
  ClinicItem(
    id: 'c1',
    name: 'Bangkok Animal Care',
    image: 'assets/images/clinic01.jpeg',
    area: 'บางกะปิ',
    distance: '1.2 km',
    rating: 4.8,
    reviews: 324,
    address: '88 ซอยลาดพร้าว 101 แขวงคลองจั่น เขตบางกะปิ กรุงเทพฯ',
    phone: '02-123-4567',
    openHours: '08:00 - 20:00',
    services: ['ตรวจทั่วไป', 'ฉีดวัคซีน', 'อัลตราซาวด์', 'ผ่าตัดเล็ก'],
    note: 'รับบัตรคิวออนไลน์ และมีบริการฉุกเฉินนอกเวลาในบางวัน',
  ),
  ClinicItem(
    id: 'c2',
    name: 'PetCare Clinic',
    image: 'assets/images/clinic02.jpeg',
    area: 'ลาดพร้าว',
    distance: '2.4 km',
    rating: 4.7,
    reviews: 210,
    address: '15 ถนนลาดพร้าว แขวงจอมพล เขตจตุจักร กรุงเทพฯ',
    phone: '02-987-6543',
    openHours: '09:00 - 19:00',
    services: ['ตรวจสุขภาพ', 'ทำแผล', 'ทำหมัน', 'ตรวจเลือด'],
    note: 'เหมาะกับสัตว์เลี้ยงขนาดเล็ก มีมุมรอรับบริการที่เงียบ',
  ),
  ClinicItem(
    id: 'c3',
    name: 'Animal Wellness Center',
    image: 'assets/images/clinic03.png',
    area: 'สวนหลวง',
    distance: '3.1 km',
    rating: 4.9,
    reviews: 512,
    address: '45 ซอยพัฒนาการ 32 แขวงสวนหลวง เขตสวนหลวง กรุงเทพฯ',
    phone: '02-555-8899',
    openHours: '08:30 - 18:30',
    services: ['วัคซีน', 'ตรวจโรคผิวหนัง', 'อาบน้ำตัดขน', 'โภชนาการ'],
    note: 'มีโปรแกรมติดตามสัตว์ป่วยและแจ้งเตือนนัดหมายผ่านแอป',
  ),
];

class _ClinicCard extends StatelessWidget {
  const _ClinicCard({required this.item, required this.onTap});

  final ClinicItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.greyscale_200),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                item.image,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
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
                          item.name,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.greyscale_900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          item.distance,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primarySecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.area,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.greyscale_400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 13,
                        color: Colors.amber[700],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.greyscale_900,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${item.reviews})',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.greyscale_400,
                        ),
                      ),
                    ],
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

class ClinicDetailPage extends StatelessWidget {
  const ClinicDetailPage({super.key, required this.item});

  final ClinicItem item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarMainApp(
        title: 'รายละเอียดคลินิก',
        onBack: () => Navigator.pop(context),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.greyscale_200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: Image.asset(
                    item.image,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
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
                              color: AppColors.primaryLight.withValues(
                                alpha: 0.28,
                              ),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              item.distance,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primarySecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.area,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.greyscale_400,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: Colors.amber[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.greyscale_900,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'จาก ${item.reviews} รีวิว',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: AppColors.greyscale_400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _DetailBlock(title: 'ที่อยู่', value: item.address),
                      const SizedBox(height: 10),
                      _DetailBlock(title: 'เวลาทำการ', value: item.openHours),
                      const SizedBox(height: 10),
                      _DetailBlock(title: 'เบอร์โทร', value: item.phone),
                      const SizedBox(height: 10),
                      _DetailBlock(
                        title: 'บริการ',
                        value: item.services.join(' • '),
                      ),
                      const SizedBox(height: 10),
                      _DetailBlock(title: 'หมายเหตุ', value: item.note),
                    ],
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

class _DetailBlock extends StatelessWidget {
  const _DetailBlock({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.greyscale_50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: AppColors.greyscale_800,
            ),
          ),
        ],
      ),
    );
  }
}

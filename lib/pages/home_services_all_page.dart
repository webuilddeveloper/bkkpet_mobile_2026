import 'dart:async';
import 'dart:math' as math;

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
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
    Future.microtask(_showWelcomeNotificationSafely);
  }

  Future<void> _showWelcomeNotificationSafely() async {
    try {
      await LocalNotificationService.showChatuchakRiskWelcomeOnce();
    } catch (_) {
      // Notification permission or plugin setup should never block navigation.
    }
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

enum _SurveillancePageMode { overview }

enum _RiskLevel { high, medium, watch }

enum _SurveillanceFilter { all, high, medium, watch }

class ZoonoticDiseasePage extends StatelessWidget {
  const ZoonoticDiseasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SurveillancePage(mode: _SurveillancePageMode.overview);
  }
}

class _SurveillancePage extends StatefulWidget {
  const _SurveillancePage({required this.mode});

  final _SurveillancePageMode mode;

  @override
  State<_SurveillancePage> createState() => _SurveillancePageState();
}

class _SurveillancePageState extends State<_SurveillancePage> {
  static const LatLng _cityCenter = LatLng(13.8167, 100.561);
  static const double _minZoom = 10.0;
  static const double _maxZoom = 16.5;
  static const double _defaultZoom = 12.0;

  GoogleMapController? _mapController;
  double _cameraZoom = _defaultZoom;
  String? _selectedRiskId;
  _SurveillanceFilter _filter = _SurveillanceFilter.all;

  @override
  void initState() {
    super.initState();
    Future.microtask(_showRiskAreaNoticeSafely);
    WidgetsBinding.instance.addPostFrameCallback((_) => _fitToVisibleRisks());
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _showRiskAreaNoticeSafely() async {
    try {
      await LocalNotificationService.showRiskAreaAlert(
        title: 'เฝ้าระวังโรคสัตว์สู่คน',
        body:
            'เขตจตุจักรมีการแจ้งสัตว์ป่วยผิดปกติ โปรดหลีกเลี่ยงการสัมผัสและติดตามประกาศพื้นที่เสี่ยง',
      );
    } catch (_) {
      // Best effort only.
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    WidgetsBinding.instance.addPostFrameCallback((_) => _fitToVisibleRisks());
  }

  List<_SurveillanceRisk> get _allRisks => _surveillanceRisks;

  List<_SurveillanceRisk> get _filteredRisks {
    return switch (_filter) {
      _SurveillanceFilter.all => _allRisks,
      _SurveillanceFilter.high =>
        _allRisks.where((item) => item.level == _RiskLevel.high).toList(),
      _SurveillanceFilter.medium =>
        _allRisks.where((item) => item.level == _RiskLevel.medium).toList(),
      _SurveillanceFilter.watch =>
        _allRisks.where((item) => item.level == _RiskLevel.watch).toList(),
    };
  }

  List<_SurveillanceRisk> get _mapRisks {
    return _filteredRisks;
  }

  List<_SurveillanceRisk> get _previewRisks {
    if (widget.mode == _SurveillancePageMode.overview) {
      return _filteredRisks.take(3).toList();
    }
    return _filteredRisks;
  }

  _SurveillanceRisk? get _selectedRisk {
    if (_selectedRiskId == null) return null;
    final risks = _mapRisks;
    if (risks.isEmpty) return null;
    for (final risk in risks) {
      if (risk.id == _selectedRiskId) {
        return risk;
      }
    }
    return null;
  }

  Set<Marker> get _markers {
    final selectedRisk = _selectedRisk;
    final risksToShow =
        selectedRisk == null ? _mapRisks : <_SurveillanceRisk>[selectedRisk];

    return risksToShow.map((risk) {
      return Marker(
        markerId: MarkerId(risk.id),
        position: risk.position,
        icon: BitmapDescriptor.defaultMarkerWithHue(risk.level.markerHue),
        zIndexInt: selectedRisk?.id == risk.id ? 2 : 1,
        onTap: () => _selectRisk(risk),
        infoWindow: InfoWindow(
          title: risk.title,
          snippet: '${risk.area} · ${risk.level.label}',
        ),
      );
    }).toSet();
  }

  Set<Circle> get _circles {
    final selectedRisk = _selectedRisk;
    final risksToShow =
        selectedRisk == null ? _mapRisks : <_SurveillanceRisk>[selectedRisk];

    return risksToShow.map((risk) {
      final isSelected = selectedRisk?.id == risk.id;
      final color = risk.level.color;
      return Circle(
        circleId: CircleId(risk.id),
        center: risk.position,
        radius: risk.radiusMeters,
        strokeWidth: isSelected ? 4 : 2,
        strokeColor: color,
        fillColor: color.withValues(alpha: isSelected ? 0.20 : 0.12),
      );
    }).toSet();
  }

  Future<void> _selectRisk(
    _SurveillanceRisk risk, {
    bool focusMap = true,
  }) async {
    if (!mounted) return;
    final isSameSelection = _selectedRiskId == risk.id;
    setState(() {
      _selectedRiskId = isSameSelection ? null : risk.id;
    });
    if (focusMap) {
      if (isSameSelection) {
        await _fitToVisibleRisks();
      } else {
        await _focusOnRisk(risk);
      }
    }
  }

  Future<void> _focusOnRisk(_SurveillanceRisk risk) async {
    final controller = _mapController;
    if (controller == null) return;

    await controller.animateCamera(
      CameraUpdate.newLatLngZoom(risk.position, 14.2),
    );
    setState(() {
      _cameraZoom = 14.2;
    });
  }

  Future<void> _fitToVisibleRisks() async {
    final controller = _mapController;
    final risks = _mapRisks;
    if (controller == null || risks.isEmpty) return;

    if (risks.length == 1) {
      await _focusOnRisk(risks.first);
      return;
    }

    final bounds = _boundsFor(risks.map((risk) => risk.position));
    try {
      await controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 48));
    } catch (_) {
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(_cityCenter, _defaultZoom),
      );
    }
  }

  LatLngBounds _boundsFor(Iterable<LatLng> points) {
    final latitudes = points.map((point) => point.latitude).toList();
    final longitudes = points.map((point) => point.longitude).toList();
    final southWest = LatLng(
      latitudes.reduce(math.min),
      longitudes.reduce(math.min),
    );
    final northEast = LatLng(
      latitudes.reduce(math.max),
      longitudes.reduce(math.max),
    );
    return LatLngBounds(southwest: southWest, northeast: northEast);
  }

  Future<void> _zoomTo(double nextZoom) async {
    final controller = _mapController;
    if (controller == null) return;

    final clampedZoom = nextZoom.clamp(_minZoom, _maxZoom).toDouble();
    if ((clampedZoom - _cameraZoom).abs() < 0.01) return;

    setState(() {
      _cameraZoom = clampedZoom;
    });
    await controller.animateCamera(CameraUpdate.zoomTo(clampedZoom));
  }

  void _setFilter(_SurveillanceFilter filter) {
    setState(() {
      _filter = filter;
      final visibleIds = _filteredRisks.map((item) => item.id).toSet();
      if (_selectedRiskId != null && !visibleIds.contains(_selectedRiskId)) {
        _selectedRiskId = null;
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _fitToVisibleRisks());
  }

  void _resetSelectionAndFit() {
    setState(() {
      _selectedRiskId = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _fitToVisibleRisks());
  }

  @override
  Widget build(BuildContext context) {
    final selectedRisk = _selectedRisk;
    final mapHeight =
        widget.mode == _SurveillancePageMode.overview ? 470.0 : 420.0;
    final title =
        widget.mode == _SurveillancePageMode.overview
            ? 'เฝ้าระวังโรคสัตว์สู่คน'
            : 'พื้นที่เฝ้าระวังทั้งหมด';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarMainApp(
        title: title,
        onBack: () => Navigator.pop(context),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _SurveillanceCategoryTabs(
            selectedFilter: _filter,
            onChanged: _setFilter,
          ),
          const SizedBox(height: 10),
          _SurveillanceMapPanel(
            height: mapHeight,
            cameraZoom: _cameraZoom,
            minZoom: _minZoom,
            maxZoom: _maxZoom,
            onZoomIn:
                _cameraZoom >= _maxZoom ? null : () => _zoomTo(_cameraZoom + 1),
            onZoomOut:
                _cameraZoom <= _minZoom ? null : () => _zoomTo(_cameraZoom - 1),
            onResetView: _resetSelectionAndFit,
            selectedRisk: selectedRisk,
            visibleCount: _mapRisks.length,
            markers: _markers,
            circles: _circles,
            onMapCreated: _onMapCreated,
            onCameraMove: (position) {
              if ((position.zoom - _cameraZoom).abs() < 0.01) return;
              setState(() {
                _cameraZoom = position.zoom;
              });
            },
          ),
          const SizedBox(height: 12),
          if (widget.mode == _SurveillancePageMode.overview) ...[
            Text(
              'ตัวอย่างพื้นที่เฝ้าระวัง',
              style: TextStyle(
                color: AppColors.greyscale_900,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            ..._previewRisks.map(
              (risk) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SurveillanceRiskCard(
                  risk: risk,
                  isSelected: risk.id == selectedRisk?.id,
                  onTap: () => _selectRisk(risk),
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            _SectionHeader(
              title: 'รายการพื้นที่เฝ้าระวัง',
              actionLabel: 'รีเซ็ตมุมมอง',
              onActionTap: _resetSelectionAndFit,
            ),
            const SizedBox(height: 10),
            if (_previewRisks.isEmpty)
              const _SurveillanceEmptyState()
            else
              ..._previewRisks.map(
                (risk) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _SurveillanceRiskCard(
                    risk: risk,
                    isSelected: risk.id == selectedRisk?.id,
                    onTap: () => _selectRisk(risk),
                    showChevron: false,
                  ),
                ),
              ),
          ],
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

class _SurveillanceRisk {
  const _SurveillanceRisk({
    required this.id,
    required this.title,
    required this.area,
    required this.district,
    required this.summary,
    required this.recommendation,
    required this.level,
    required this.position,
    required this.radiusKm,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String area;
  final String district;
  final String summary;
  final String recommendation;
  final _RiskLevel level;
  final LatLng position;
  final double radiusKm;
  final DateTime updatedAt;

  double get radiusMeters => radiusKm * 1000;
}

extension _RiskLevelStyle on _RiskLevel {
  String get label {
    return switch (this) {
      _RiskLevel.high => 'ความเสี่ยงสูง',
      _RiskLevel.medium => 'ความเสี่ยงปานกลาง',
      _RiskLevel.watch => 'เฝ้าระวัง',
    };
  }

  String get shortLabel {
    return switch (this) {
      _RiskLevel.high => 'สูง',
      _RiskLevel.medium => 'ปานกลาง',
      _RiskLevel.watch => 'ติดตาม',
    };
  }

  Color get color {
    return switch (this) {
      _RiskLevel.high => const Color(0xFFE53935),
      _RiskLevel.medium => const Color(0xFFEF8C18),
      _RiskLevel.watch => const Color(0xFFF6C453),
    };
  }

  double get markerHue {
    return switch (this) {
      _RiskLevel.high => BitmapDescriptor.hueRed,
      _RiskLevel.medium => BitmapDescriptor.hueOrange,
      _RiskLevel.watch => BitmapDescriptor.hueYellow,
    };
  }
}

final List<_SurveillanceRisk> _surveillanceRisks = [
  _SurveillanceRisk(
    id: 'risk-01',
    title: 'จุดแจ้งสัตว์ป่วยผิดปกติ',
    area: 'แขวงจอมพล เขตจตุจักร',
    district: 'เขตจตุจักร',
    summary: 'มีการแจ้งสัตว์ป่วยผิดปกติใกล้แนวชุมชนและจุดรับบริการสาธารณะ',
    recommendation:
        'หลีกเลี่ยงการสัมผัสสัตว์ป่วยและแจ้งเจ้าหน้าที่หากพบเหตุซ้ำ',
    level: _RiskLevel.high,
    position: LatLng(13.8092, 100.5589),
    radiusKm: 5.0,
    updatedAt: DateTime(2026, 8, 11, 9, 30),
  ),
  _SurveillanceRisk(
    id: 'risk-02',
    title: 'จุดเฝ้าระวังภาคสนาม',
    area: 'แขวงลาดยาว เขตจตุจักร',
    district: 'เขตจตุจักร',
    summary: 'พื้นที่ติดตามการเคลื่อนย้ายสัตว์และการสัมผัสใกล้ชิดในชุมชน',
    recommendation:
        'สวมอุปกรณ์ป้องกันเมื่อเข้าพื้นที่ และล้างมือหลังสัมผัสสัตว์',
    level: _RiskLevel.medium,
    position: LatLng(13.8216, 100.5612),
    radiusKm: 3.8,
    updatedAt: DateTime(2026, 8, 11, 11, 10),
  ),
  _SurveillanceRisk(
    id: 'risk-03',
    title: 'รายงานสัตว์ตายผิดปกติ',
    area: 'แขวงเสนานิคม เขตจตุจักร',
    district: 'เขตจตุจักร',
    summary: 'พบรายงานการตายผิดปกติใกล้เส้นทางสัญจรและพื้นที่น้ำขัง',
    recommendation: 'หลีกเลี่ยงการสัมผัสซากสัตว์และแจ้งเจ้าหน้าที่ทันที',
    level: _RiskLevel.watch,
    position: LatLng(13.8078, 100.5468),
    radiusKm: 2.6,
    updatedAt: DateTime(2026, 8, 11, 12, 5),
  ),
  _SurveillanceRisk(
    id: 'risk-04',
    title: 'แนวตรวจจับรอบตลาดชุมชน',
    area: 'แขวงจันทรเกษม เขตจตุจักร',
    district: 'เขตจตุจักร',
    summary: 'เพิ่มการตรวจสอบจุดจำหน่ายสัตว์และพื้นที่ที่มีการรวมตัวของผู้คน',
    recommendation: 'งดปล่อยสัตว์เดินอิสระและติดตามประกาศจากหน่วยงาน',
    level: _RiskLevel.medium,
    position: LatLng(13.8301, 100.5541),
    radiusKm: 4.2,
    updatedAt: DateTime(2026, 8, 11, 12, 45),
  ),
  _SurveillanceRisk(
    id: 'risk-05',
    title: 'พื้นที่แจ้งเตือนภาคสนามพิเศษ',
    area: 'แขวงบางเขน เขตบางเขน',
    district: 'เขตบางเขน',
    summary: 'จุดติดตามกรณีรายงานอาการผิดปกติจากจุดบริการเคลื่อนที่',
    recommendation:
        'หากพบสัตว์มีอาการผิดปกติให้หลีกเลี่ยงการเข้าใกล้และแจ้งต่อทันที',
    level: _RiskLevel.high,
    position: LatLng(13.8473, 100.5832),
    radiusKm: 2.1,
    updatedAt: DateTime(2026, 8, 11, 13, 18),
  ),
  _SurveillanceRisk(
    id: 'risk-06',
    title: 'จุดติดตามแนวขนส่ง',
    area: 'แขวงลาดพร้าว เขตลาดพร้าว',
    district: 'เขตลาดพร้าว',
    summary: 'ตรวจสอบการเคลื่อนย้ายสัตว์เลี้ยงตามเส้นทางขนส่งและสถานีเชื่อมต่อ',
    recommendation:
        'ติดตามสถานะพื้นที่ก่อนเดินทางและหลีกเลี่ยงการรวมกลุ่มโดยไม่จำเป็น',
    level: _RiskLevel.watch,
    position: LatLng(13.8152, 100.6051),
    radiusKm: 3.0,
    updatedAt: DateTime(2026, 8, 11, 13, 42),
  ),
];

class _SurveillanceMapPanel extends StatelessWidget {
  const _SurveillanceMapPanel({
    required this.height,
    required this.cameraZoom,
    required this.minZoom,
    required this.maxZoom,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onResetView,
    required this.selectedRisk,
    required this.visibleCount,
    required this.markers,
    required this.circles,
    required this.onMapCreated,
    required this.onCameraMove,
  });

  final double height;
  final double cameraZoom;
  final double minZoom;
  final double maxZoom;
  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;
  final VoidCallback onResetView;
  final _SurveillanceRisk? selectedRisk;
  final int visibleCount;
  final Set<Marker> markers;
  final Set<Circle> circles;
  final void Function(GoogleMapController controller) onMapCreated;
  final void Function(CameraPosition position) onCameraMove;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.greyscale_200),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
              onMapCreated: onMapCreated,
              onCameraMove: onCameraMove,
              initialCameraPosition: const CameraPosition(
                target: _SurveillancePageState._cityCenter,
                zoom: _SurveillancePageState._defaultZoom,
              ),
              gestureRecognizers: {
                Factory<OneSequenceGestureRecognizer>(
                  () => EagerGestureRecognizer(),
                ),
              },
              markers: markers,
              circles: circles,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomGesturesEnabled: true,
              scrollGesturesEnabled: true,
              rotateGesturesEnabled: true,
              tiltGesturesEnabled: true,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
              trafficEnabled: false,
              buildingsEnabled: false,
            ),
          ),
          Positioned(
            left: 12,
            top: 12,
            child: _MapLegend(
              label:
                  selectedRisk == null
                      ? 'แสดงทั้งหมด $visibleCount จุด'
                      : 'แสดงเฉพาะ 1 จุด',
              color: AppColors.primarySecondary,
            ),
          ),
          Positioned(
            right: 12,
            top: 56,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _MapControlButton(icon: Icons.add, onTap: onZoomIn),
                const SizedBox(height: 8),
                _MapControlButton(icon: Icons.remove, onTap: onZoomOut),
                const SizedBox(height: 8),
                _MapControlButton(
                  icon: Icons.center_focus_strong,
                  onTap: onResetView,
                ),
              ],
            ),
          ),
          Positioned(
            right: 12,
            bottom: selectedRisk == null ? 12 : null,
            top: selectedRisk == null ? null : 12,
            child: _MapLegend(
              label: 'ซูม ${cameraZoom.toStringAsFixed(1)}',
              color: AppColors.greyscale_400,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onActionTap,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: AppColors.greyscale_900,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        TextButton(
          onPressed: onActionTap,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primarySecondary,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          ),
          child: Text(
            actionLabel,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _MapLegend extends StatelessWidget {
  const _MapLegend({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
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
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapControlButton extends StatelessWidget {
  const _MapControlButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.greyscale_200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(
            icon,
            size: 20,
            color:
                enabled ? AppColors.primarySecondary : AppColors.greyscale_300,
          ),
        ),
      ),
    );
  }
}

class _SurveillanceCategoryTabs extends StatelessWidget {
  const _SurveillanceCategoryTabs({
    required this.selectedFilter,
    required this.onChanged,
  });

  final _SurveillanceFilter selectedFilter;
  final ValueChanged<_SurveillanceFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = <_SurveillanceFilter, ({String label, IconData icon})>{
      _SurveillanceFilter.high: (label: 'สูง', icon: Icons.warning_rounded),
      _SurveillanceFilter.medium: (
        label: 'ปานกลาง',
        icon: Icons.priority_high_rounded,
      ),
      _SurveillanceFilter.watch: (
        label: 'เฝ้าระวัง',
        icon: Icons.shield_outlined,
      ),
    };

    final entries = items.entries.toList();

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.greyscale_25,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.greyscale_200),
      ),
      child: Row(
        children: [
          for (var i = 0; i < entries.length; i++) ...[
            Expanded(
              child: _SurveillanceCategoryTab(
                label: entries[i].value.label,
                icon: entries[i].value.icon,
                selected: entries[i].key == selectedFilter,
                selectedColor: switch (entries[i].key) {
                  _SurveillanceFilter.all => AppColors.primarySecondary,
                  _SurveillanceFilter.high => _RiskLevel.high.color,
                  _SurveillanceFilter.medium => _RiskLevel.medium.color,
                  _SurveillanceFilter.watch => _RiskLevel.watch.color,
                },
                onTap: () => onChanged(entries[i].key),
              ),
            ),
            if (i != entries.length - 1) const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }
}

class _SurveillanceCategoryTab extends StatelessWidget {
  const _SurveillanceCategoryTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final Color selectedColor;
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
            Icon(
              icon,
              size: 17,
              color: selected ? selectedColor : AppColors.greyscale_400,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.0,
                fontWeight: FontWeight.w600,
                color: selected ? selectedColor : AppColors.greyscale_400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SurveillanceRiskCard extends StatelessWidget {
  const _SurveillanceRiskCard({
    required this.risk,
    required this.isSelected,
    required this.onTap,
    this.showChevron = false,
  });

  final _SurveillanceRisk risk;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final accent = risk.level.color;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected ? accent.withValues(alpha: 0.05) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  isSelected
                      ? accent.withValues(alpha: 0.35)
                      : AppColors.greyscale_200,
              width: isSelected ? 1.2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  risk.level == _RiskLevel.high
                      ? Icons.warning_rounded
                      : risk.level == _RiskLevel.medium
                      ? Icons.place_rounded
                      : Icons.remove_red_eye_rounded,
                  color: accent,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            risk.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.greyscale_900,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                        ),
                        if (showChevron) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.greyscale_300,
                            size: 22,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${risk.area} · ${risk.level.label}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.greyscale_400,
                        fontSize: 12.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      risk.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.greyscale_400,
                        fontSize: 12.2,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _MiniTag(label: risk.level.shortLabel, color: accent),
                        _MiniTag(
                          label:
                              'รัศมี ${risk.radiusKm.toStringAsFixed(1)} กม.',
                          color: AppColors.primarySecondary,
                        ),
                        _MiniTag(
                          label: _thaiDate(risk.updatedAt),
                          color: AppColors.greyscale_400,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  const _MiniTag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10.8,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SurveillanceEmptyState extends StatelessWidget {
  const _SurveillanceEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greyscale_200),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.radar_rounded,
              color: AppColors.primarySecondary,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'ยังไม่พบพื้นที่เฝ้าระวังตามตัวกรองนี้',
            style: TextStyle(
              color: AppColors.greyscale_900,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'ลองเปลี่ยนตัวกรองเป็น "ทั้งหมด" หรือเลือกประเภทความเสี่ยงอื่น',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.greyscale_400,
              fontSize: 12.2,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

String _thaiDate(DateTime dateTime) {
  const months = <String>[
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

  final date = dateTime.toLocal();
  return '${date.day} ${months[date.month - 1]} ${date.year + 543}';
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

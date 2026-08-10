import 'package:bkkpet/blank_page/appbar.dart';
import 'package:bkkpet/blank_page/app_loading.dart';
import 'package:bkkpet/blank_page/bannercarousel.dart';
import 'package:bkkpet/blank_page/category_menu.dart';
import 'package:bkkpet/mock_data.dart';
import 'package:bkkpet/pages/adoption/adoption_list_page.dart';
import 'package:bkkpet/pages/login.dart';
import 'package:bkkpet/pages/home_services_all_page.dart';
import 'package:bkkpet/pages/lostpet/lost_found_page.dart';
import 'package:bkkpet/pages/notification.dart';
import 'package:bkkpet/pages/pet_regis.dart';
import 'package:bkkpet/pages/pet_verification/pet_verification_page.dart';
import 'package:bkkpet/pages/reportIncident_page.dart';
import 'package:bkkpet/pages/welfare/welfare_detail_page.dart';
import 'package:bkkpet/pages/welfare/welfare_page.dart';
import 'package:bkkpet/pages/sterilization/sterilization_page.dart';
import 'package:bkkpet/services/notification_storage.dart';
import 'package:bkkpet/services/mock_user_store.dart';
import 'package:bkkpet/pages/vaccine/vaccine_page.dart';
import 'package:bkkpet/services/app_route_observer.dart';
import 'package:bkkpet/style_theme.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.onTabChange});

  final void Function(int index) onTabChange;

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with RouteAware {
  bool _isLoggedIn = false;
  int _notificationCount = 0;
  PageRoute<dynamic>? _currentRoute;

  Future<void> refreshPage() async {
    await Future.wait([
      _loadLogin(),
      _loadNotificationCount(),
    ]);
  }

  @override
  void initState() {
    super.initState();
    _loadLogin();
    _loadNotificationCount();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute && route != _currentRoute) {
      if (_currentRoute != null) {
        appRouteObserver.unsubscribe(this);
      }
      _currentRoute = route;
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  Future<void> _loadLogin() async {
    final loggedIn = await AppAuthService.isLoggedIn();
    if (!mounted) return;
    setState(() => _isLoggedIn = loggedIn);
  }

  Future<void> _loadNotificationCount() async {
    final count = await NotificationStorage.unreadCount();
    if (!mounted) return;
    setState(() => _notificationCount = count);
  }

  Future<void> _refreshHome() => refreshPage();

  @override
  void didPopNext() {
    _loadLogin();
    _loadNotificationCount();
  }

  Future<void> _requireLoginAndOpen(Widget page) async {
    if (_isLoggedIn) {
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
    await _loadLogin();

    if (!_isLoggedIn || !mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyscale_25,
      appBar: AppBarHome(
        isLoggedIn: _isLoggedIn,
        notificationCount: _notificationCount,
        userName:
            _isLoggedIn ? MockUserStore.owner.fullName : 'กรุณาเข้าสู่ระบบ',
        welcomeText:
            _isLoggedIn ? 'สมาชิก BKK Pet' : 'ท่านยังไม่ได้เข้าสู่ระบบ',
        profileImage: MockUserStore.owner.profileImage,
        onNotificationTap:
            _isLoggedIn
                ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NotificationList()),
                  ).then((_) => _loadNotificationCount());
                }
                : null,
        onProfileTap: () {
          if (_isLoggedIn) {
            widget.onTabChange(4);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            ).then((_) => _loadLogin());
          }
        },
      ),
      body: AppRefreshIndicator(
        onRefresh: _refreshHome,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 24,
            bottom: 120,
          ),
          child: Column(
            children: [
                BannerCarousel(banners: mockHomeBanners),

                buiTxtdRow(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => HomeServicesAllPage(
                              isLoggedIn: _isLoggedIn,
                              openProtectedPage: _requireLoginAndOpen,
                            ),
                      ),
                    );
                  },
                  titleMain: "บริการ",
                  righttitle: "ดูทั้งหมด",
                ),
                buidService(),

                builServicePet(),

                buiTxtdRow(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const WelfarePage()),
                    );
                  },
                  titleMain: "สวัสดิการ",
                  righttitle: "ดูทั้งหมด",
                ),
                SizedBox(height: 12),
                buildWelfare(),
              ],
            ),
        ),
      ),
    );
  }

  buiTxtdRow({
    required String titleMain,
    required String righttitle,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          titleMain,
          style: TextStyle(
            fontSize: 18,
            color: AppColors.greyscale_900,
            fontWeight: FontWeight.w600,
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(
            righttitle,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  buidService() {
    return CategoryMenuWidget(
      items: mockHomeServiceCategories.take(5).toList(),
      onCategoryTap: (item) {
        switch (item['id']) {
          case '1':
            _requireLoginAndOpen(const PetRegisPage());
            break;

          case '2':
            _requireLoginAndOpen(const VaccinePage());
            break;

          case '3':
            _requireLoginAndOpen(const Sterilizationpage());
            break;

          case '4':
            _requireLoginAndOpen(const PetVerificationPage());
            break;

          case '5':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReportIncidentPage()),
            );
            break;
        }
      },
    );
  }

  builServicePet() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdoptionListPage()),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset('assets/icons/pets.png'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'รับเลี้ยง',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ค้นหาสัตว์ที่พร้อมให้รับอุปการะ',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w400,
                          color: Colors.black54,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LostFoundPage()),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset('assets/icons/search.png'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'แจ้งหาย & ตามหา',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'แจ้งสัตว์เลี้ยงสูญหาย หรือแจ้งพบสัตว์ที่หลงทาง',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w400,
                          color: Colors.black54,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
  }

  buildWelfare() {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: welfareItems.length,
        itemBuilder: (context, index) {
          final item = welfareItems[index];

          return Padding(
            padding: EdgeInsets.only(
              right: index == welfareItems.length - 1 ? 0 : 12,
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WelfareDetailPage(item: item),
                  ),
                );
              },
              child: Container(
                width: 240,
                decoration: BoxDecoration(
                  color: AppColors.greyscale_50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          item.image,
                          height: 110,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.greyscale_900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.summary,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.greyscale_400,
                          height: 1.35,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Text(
                        item.provider,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

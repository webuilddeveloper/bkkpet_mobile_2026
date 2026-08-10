// ignore_for_file: deprecated_member_use

import 'package:bkkpet/pages/calendar.dart';
import 'package:bkkpet/pages/consult/consult.dart';
import 'package:bkkpet/pages/home.dart';
import 'package:bkkpet/pages/login.dart';
import 'package:bkkpet/pages/policy_page.dart';

import 'package:bkkpet/pages/profile.dart';
import 'package:bkkpet/services/mock_user_store.dart';
import 'package:bkkpet/style_theme.dart';
import 'package:bkkpet/pages/chat/chat.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Menu extends StatefulWidget {
  const Menu({super.key, this.pageIndex});
  final int? pageIndex;

  @override
  State<Menu> createState() => _MenuState();
}

bool isLogin = false;

class _MenuState extends State<Menu> with SingleTickerProviderStateMixin {
  late GlobalKey<HomePageState> _homeKey;
  List<Widget> pages = <Widget>[];
  int _currentPage = 0;
  DateTime? currentBackPressTime;
  dynamic futureNotificationTire;

  void _refreshCalendarPage() {
    pages[1] = CalendarPage(
      key: UniqueKey(),
      onTabChange: _onItemTapped,
    );
  }

  @override
  void initState() {
    _homeKey = GlobalKey<HomePageState>();
    _checkLogin();
    pages = <Widget>[
      HomePage(key: _homeKey, onTabChange: _onItemTapped),
      CalendarPage(onTabChange: _onItemTapped),
      ConSultPag(onTabChange: _onItemTapped),
      chatPage(onTabChange: _onItemTapped),
      ProfilePage(onTabChange: _onItemTapped),
    ];
    super.initState();
  }

  // void _onItemTapped(int index) {
  //   setState(() {
  //     if (index == 0 && _currentPage != 0) {
  //       // ⬅️ เมื่อจากอื่นมาหน้า Home ให้ refresh ข้อมูล
  //       _homeKey.currentState?.refreshPage();
  //     }

  //     _currentPage = index;
  //   });
  // }

  void _onItemTapped(int index) {
    Future<void> openLoginAndRestore(int targetIndex) async {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      await _checkLogin();
      if (isLogin && mounted) {
        setState(() {
          if (targetIndex == 1) _refreshCalendarPage();
          _currentPage = targetIndex;
        });
      }
    }

    Future<void> openPolicyAndGoToConsult() async {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (_) => PolicyPage(
                type: PolicyType.consult,
                onAccept: () {
                  if (!mounted) return;
                  setState(() => _currentPage = 2);
                  Navigator.of(context).pop();
                },
              ),
        ),
      );
    }

    // 🔒 กันหน้า Calendar / Chat / Profile
    if ((index == 1 || index == 3 || index == 4) && !isLogin) {
      openLoginAndRestore(index);
      return;
    }

    if (index == 2) {
      openPolicyAndGoToConsult();
      return;
    }

    setState(() {
      if (index == 0 && _currentPage != 0) {
        _homeKey.currentState?.refreshPage();
      }
      if (index == 1) {
        _refreshCalendarPage();
      }

      _currentPage = index;
    });
  }

  Future<void> _checkLogin() async {
    final loggedIn = await AppAuthService.isLoggedIn();
    if (!mounted) return;
    setState(() => isLogin = loggedIn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFF1E1E1E),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            DateTime now = DateTime.now();
            if (currentBackPressTime == null ||
                now.difference(currentBackPressTime!) >
                    const Duration(seconds: 2)) {
              currentBackPressTime = now;
              Fluttertoast.showToast(
                msg: 'กดอีกครั้งเพื่อออก',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            } else {
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            }
          },
          child: IndexedStack(index: _currentPage, children: pages),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: Container(
        height: 65 + MediaQuery.of(context).padding.bottom,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF000000).withOpacity(0.10),
              blurRadius: 4,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTap(0, 'หน้าแรก', icon: 'assets/icons/home.png'),
            _buildTap(1, 'นัดหมาย', icon: 'assets/icons/calendar.png'),
            _buildTapCenter(2, icon: 'assets/icons/stethoscope.png'),
            _buildTap(3, 'แชท', icon: 'assets/icons/chat.png'),
            _buildTap(4, 'โปรไฟล์', icon: 'assets/icons/user.png'),
          ],
        ),
      ),
    );
  }

  Widget _buildTap(int? index, String title, {String? icon}) {
    return Flexible(
      flex: 1,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: () => _onItemTapped(index!),
            child: Container(
              alignment: Alignment.center,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    icon!,
                    height: 30,
                    width: 30,
                    color:
                        _currentPage == index
                            ? Colors.black
                            : AppColors.secondary,
                  ),
                  const SizedBox(height: 5),
                  title.isNotEmpty
                      ? Text(
                        title,
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              _currentPage == index
                                  ? Colors.black
                                  : Colors.grey[400],
                        ),
                      )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTapCenter(int? index, {String? icon}) {
    return Flexible(
      flex: 1,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: () => _onItemTapped(index!),
            child: Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                color: AppColors.primary,
                border: Border.all(
                  width: 5,
                  color:
                      _currentPage == index
                          ? AppColors.greenlight
                          : AppColors.primary,
                ),

                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,

              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    icon!,
                    height: 30,
                    width: 30,
                    color: Colors.white,
                  ),

                  // const SizedBox(height: 5),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

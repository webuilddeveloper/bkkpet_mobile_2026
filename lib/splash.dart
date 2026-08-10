// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:async';

import 'package:bkkpet/blank_page/dialog_fail.dart';
import 'package:bkkpet/menu.dart';
import 'package:bkkpet/services/mock_user_store.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

late Future<dynamic> futureModel;

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    _callRead();
    super.initState();
  }

  _callRead() {
    futureModel = _loadDemoData();

    // postDio(server + 'm/splash/read', {
    //   "code": '20241028141922-963-452',
    // });
  }

  Future<List<Map<String, dynamic>>> _loadDemoData() async {
    await Future.delayed(Duration(seconds: 1)); // จำลองโหลดข้อมูล
    return [
      {"timeOut": "2000"}, // ตัวอย่างข้อมูลจำลอง
    ];
  }

  _callTimer(time) async {
    var duration = Duration(seconds: time);
    return Timer(duration, _callNavigatorPage);
  }

  _callNavigatorPage() async {
    final loggedIn = await AppAuthService.isLoggedIn();
    if (loggedIn) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => Menu(pageIndex: null)),
        (Route<dynamic> route) => false,
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => Menu()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: FutureBuilder<dynamic>(
          future: futureModel,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              _callTimer(
                (snapshot.data.length > 0
                        ? int.parse(snapshot.data[0]['timeOut']) / 1000
                        : 0)
                    .round(),
              );

              return snapshot.data.length > 0
                  ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Image.asset(
                        'assets/icons/logo_bkk.png',
                        width: MediaQuery.of(context).size.width * 0.8,
                        fit: BoxFit.contain,
                      ),
                    ),
                  )
                  : Container();
            } else if (snapshot.hasError) {
              return Center(
                child: Container(
                  color: Colors.white,
                  child: dialogFail(context, reloadApp: true),
                ),
              );
            } else {
              return Center(child: Container());
            }
          },
        ),
      ),
    );
  }
}

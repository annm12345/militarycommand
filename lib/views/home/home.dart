// ignore: depend_on_referenced_packages
import 'dart:collection';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:military_admin/controllers/home_controller.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:military_admin/images.dart';
import 'package:military_admin/styles.dart';
import 'package:military_admin/views/book/book.dart';
import 'package:military_admin/views/book/sub_book.dart';
import 'package:military_admin/views/home/home_screen.dart';
import 'package:military_admin/views/profile/profile.dart';
// import 'package:military_admin/views/telegraph/src/map_compass.dart';
import 'package:military_admin/views/telegraph/src/mapc.dart';
import 'package:military_admin/views/telegraph/telegraph.dart';
import 'package:military_admin/views/map/map.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    //initate Home Controller
    var controller = Get.put(HomeController());
    var navBarItems = [
      BottomNavigationBarItem(
          icon: Image.asset(icuser, width: 26), label: "User list"),
      BottomNavigationBarItem(
          icon: Image.asset("icon/map.png", width: 26), label: "Map"),
      BottomNavigationBarItem(
          icon: Image.asset("icon/tdss.png", width: 26),
          label: "System Weapon"),
      BottomNavigationBarItem(
          icon: Image.asset(
            "icon/120mmMortar.png",
            width: 33,
            height: 28,
          ),
          label: "Your Weapon"),
      // BottomNavigationBarItem(
      //     icon: Image.asset(icTopCategories, width: 26), label: "Book"),
      BottomNavigationBarItem(
          icon: Image.asset(icProfile, width: 26), label: "Account"),
    ];
    var navBody = [
      HomeScreen(),
      FlutterMapMbTilesPage(),
      Booklist(),
      TelegraphView(),
      Profile()
    ];
    return Scaffold(
      body: Column(children: [
        Obx(() => Expanded(
            child: navBody.elementAt(controller.currentHavIndex.value))),
      ]),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.currentHavIndex.value,
          selectedItemColor: Colors.red,
          selectedLabelStyle: const TextStyle(fontFamily: bold),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          items: navBarItems,
          onTap: (value) {
            controller.currentHavIndex.value = value;
          },
        ),
      ),
    );
  }
}

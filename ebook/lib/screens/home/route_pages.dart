import 'package:ebook/utils/constants/colors.dart';
import 'package:ebook/screens/home/nav_pages/nav_home_page.dart';
import 'package:ebook/screens/home/nav_pages/nav_library_page.dart';
import 'package:ebook/screens/home/nav_pages/nav_profile_page.dart';
import 'package:ebook/screens/home/nav_pages/nav_search_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class RoutePages extends StatefulWidget {
  final String token;
  const RoutePages({super.key, required this.token});

  @override
  State<RoutePages> createState() => _RoutePagesState();
}


class _RoutePagesState extends State<RoutePages> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Pass the token to NavHomePage
    _pages = [
    NavHomePage(token: widget.token),
      NavSearchPage(),
      NavLibraryPage(),
      NavProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    Brightness brightness = Theme.of(context).brightness;
    bool isLight = brightness == Brightness.light;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: SvgPicture.asset("assets/images/logo-spotify.svg", height: 30),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: GNav(
            gap: 10,
            padding: const EdgeInsets.all(12),
            color: isLight ? TColors.secondary : TColors.white,
            activeColor: TColors.primary,
            duration: const Duration(milliseconds: 600),
            onTabChange: (value) {
              setState(() {
                _selectedIndex = value;
              });
            },
            tabs: const [
              GButton(icon: Icons.home_rounded, text: "Home"),
              GButton(icon: Icons.search_sharp, text: "Search"),
              GButton(icon: Icons.library_music_outlined, text: "Library"),
              GButton(icon: Icons.person_outline_rounded, text: "Profile"),
            ],
          ),
        ),
        body: _pages[_selectedIndex],
      ),
    );
  }
}

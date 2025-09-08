
import 'package:ebook/utils/constants/colors.dart';
import 'package:ebook/screens/home/nav_pages/nav_home_page.dart';
import 'package:ebook/screens/home/nav_pages/nav_library_page.dart';
import 'package:ebook/screens/home/nav_pages/nav_profile_page.dart';
import 'package:ebook/screens/home/nav_pages/nav_search_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class RoutePages extends StatefulWidget {
  const RoutePages({super.key});

  @override
  State<RoutePages> createState() => _RoutePagesState();
}

class _RoutePagesState extends State<RoutePages> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    NavHomePage(),
    NavSearchPage(),
    NavLibraryPage(),
    NavProfilePage(),
  ];
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
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: GNav(
            gap: 10,
            padding: EdgeInsets.all(12),
            color: isLight ? TColors.secondary : TColors.white,
            activeColor: TColors.primary,
            duration: Duration(milliseconds: 600),
            onTabChange: (value) {
              setState(() {
                _selectedIndex = value;
              });
            },

            tabs: [
              GButton(
                // backgroundColor: TColors.buttonDisabled,
                icon: Icons.home_rounded,
                text: "Home",
              ),

              GButton(
                // backgroundColor: TColors.buttonDisabled,
                icon: Icons.search_sharp,
                text: "Search",
              ),
              GButton(
                // backgroundColor: TColors.buttonDisabled,
                icon: Icons.library_music_outlined,
                text: "Library",
              ),
              GButton(
                // backgroundColor: TColors.buttonDisabled,
                icon: Icons.person_outline_rounded,
                text: "Profile",
              ),
            ],
          ),
        ),
        body: _pages[_selectedIndex],
      ),
    );
  }
}

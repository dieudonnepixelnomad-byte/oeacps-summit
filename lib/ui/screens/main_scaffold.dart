import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:summitoeacp/providers/language_provider.dart';
import 'package:summitoeacp/l10n/app_localizations.dart';

class MainScaffold extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({super.key, required this.navigationShell});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  // History of visited branch indices. Start with 0 (Home).
  final List<int> _tabHistory = [];

  @override
  Widget build(BuildContext context) {
    final currentIndex = widget.navigationShell.currentIndex;
    final languageProvider = Provider.of<LanguageProvider>(context);
    final l10n = AppLocalizations(languageProvider.currentLocale);

    // Update history
    if (_tabHistory.isEmpty) {
      _tabHistory.add(currentIndex);
    } else if (_tabHistory.last != currentIndex) {
      _tabHistory.add(currentIndex);
    }

    final String location = GoRouterState.of(context).uri.path;
    final bool isRoot =
        location == '/' ||
        location == '/events' ||
        location == '/media' ||
        location == '/news';

    return PopScope(
      canPop: !isRoot,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (isRoot) {
          if (_tabHistory.length > 1) {
            setState(() {
              _tabHistory.removeLast();
              widget.navigationShell.goBranch(_tabHistory.last);
            });
          } else {
            // Exit app
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        body: widget.navigationShell,
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color.fromRGBO(23, 144, 69, 1),
          currentIndex: currentIndex,
          onTap: (int idx) => _onItemTapped(idx),
          items: [
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/images/home.svg',
                width: 24,
                height: 24,
              ),
              label: l10n.translate('home_tab'),
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/images/calendar.svg',
                width: 24,
                height: 24,
              ),
              label: l10n.translate('events_tab'),
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/images/qr-code.svg',
                width: 24,
                height: 24,
              ),
              label: l10n.translate('gallery_tab'),
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/images/news.svg',
                width: 24,
                height: 24,
              ),
              label: l10n.translate('news_tab'),
            ),
          ],
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.white,
          unselectedItemColor: const Color.fromARGB(255, 238, 224, 224),
          showUnselectedLabels: true,
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }
}

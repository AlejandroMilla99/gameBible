import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../nav/app_drawer.dart';
import '../nav/bottom_navbar.dart';

// Global RouteObserver
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

class BaseScaffold extends StatefulWidget {
  final List<Widget> pages;
  final List<String> titles;
  final List<List<Widget>>? actions;
  final int initialIndex;

  const BaseScaffold({
    super.key,
    required this.pages,
    required this.titles,
    this.actions,
    this.initialIndex = 0,
  });

  @override
  State<BaseScaffold> createState() => _BaseScaffoldState();
}

class _BaseScaffoldState extends State<BaseScaffold> with RouteAware {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route changes
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _hideKeyboard() {
    FocusScope.of(context).unfocus();
  }

  // RouteAware overrides
  @override
  void didPushNext() => _hideKeyboard(); // another screen pushed on top
  @override
  void didPop() => _hideKeyboard();     // current screen popped

  @override
  Widget build(BuildContext context) {
    final hasActions = widget.actions != null &&
        widget.actions!.length > _selectedIndex;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _hideKeyboard,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.titles[_selectedIndex]),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          actions: hasActions ? widget.actions![_selectedIndex] : null,
        ),
        drawer: const AppDrawer(),
        body: widget.pages[_selectedIndex],
        bottomNavigationBar: BottomNavbar(
          currentIndex: _selectedIndex,
          onTap: _onTabTapped,
        ),
      ),
    );
  }
}

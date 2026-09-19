import 'package:flutter/material.dart';
import 'home.dart';
import 'materi.dart';
import 'profile.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});
  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [Home(), Materi(), Profile()];

  final List<String> _titles = ['Home', 'Materi', 'Profile', 'ListView'];

  void _onTap(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: PreferredSize(
      preferredSize: Size.fromHeight(56.0),
      child: AppBar(title: Text(_titles[_selectedIndex])),
    ),
    body: IndexedStack(index: _selectedIndex, children: _pages),
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onTap,
      selectedItemColor: Colors.blue,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Materi'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    ),
  );
}

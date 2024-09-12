import 'package:flutter/material.dart';
import 'package:multi_store_app/views/nav_screens/account_screen.dart';
import 'package:multi_store_app/views/nav_screens/cart_screen.dart';
import 'package:multi_store_app/views/nav_screens/favorite_screen.dart';
import 'package:multi_store_app/views/nav_screens/home_screen.dart';
import 'package:multi_store_app/views/nav_screens/store_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentPage = 0;
  final List<Widget> _pages = [
    const HomeScreen(),
    const FavoriteScreen(),
    const StoreScreen(),
    const CartScreen(),
    const AccountScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentPage],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentPage,
        onTap: (value) {
          setState(() {
            _currentPage = value;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              _currentPage == 0 ? Icons.home : Icons.home_outlined,
              color: _currentPage == 0 ? Colors.blueAccent : Colors.grey,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _currentPage == 1 ? Icons.favorite : Icons.favorite_border,
              color: _currentPage == 1 ? Colors.blueAccent : Colors.grey,
            ),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _currentPage == 2 ? Icons.store : Icons.store_outlined,
              color: _currentPage == 2 ? Colors.blueAccent : Colors.grey,
            ),
            label: 'Stores',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _currentPage == 3
                  ? Icons.shopping_cart
                  : Icons.shopping_cart_outlined,
              color: _currentPage == 3 ? Colors.blueAccent : Colors.grey,
            ),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _currentPage == 4 ? Icons.person : Icons.person_outline,
              color: _currentPage == 4 ? Colors.blueAccent : Colors.grey,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

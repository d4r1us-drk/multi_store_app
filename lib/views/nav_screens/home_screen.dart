import 'package:flutter/material.dart';
import 'package:multi_store_app/widgets/banner_widget.dart';
import 'package:multi_store_app/widgets/category_widget.dart';
import 'package:multi_store_app/widgets/products_widget.dart';
import 'package:multi_store_app/widgets/top_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedCategory; // Holds the selected category

  void _onCategorySelected(String? category) {
    setState(() {
      selectedCategory = category; // Update the selected category
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(80.0),
        child: TopBar(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            const BannerWidget(),
            const SizedBox(height: 10),
            CategoryWidget(onCategorySelected: _onCategorySelected),
            const SizedBox(height: 20),
            ProductsWidget(
                selectedCategory: selectedCategory), // Filter products
          ],
        ),
      ),
    );
  }
}

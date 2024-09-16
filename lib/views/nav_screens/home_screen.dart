import 'package:flutter/material.dart';
import 'package:multi_store_app/widgets/banner_widget.dart';
import 'package:multi_store_app/widgets/category_widget.dart';
import 'package:multi_store_app/widgets/top_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(55.0),
        child: TopBar(),
      ),
      body: Center(
        child: Column(children: [
          SizedBox(height: 10),
          BannerWidget(),
          SizedBox(height: 10),
          CategoryWidget()
        ]),
      ),
    );
  }
}

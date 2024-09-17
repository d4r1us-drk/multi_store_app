import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BannerWidget extends StatefulWidget {
  const BannerWidget({super.key});

  @override
  State<BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  final Stream<QuerySnapshot> _bannersStream =
      FirebaseFirestore.instance.collection('banners').snapshots();
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Start the timer for auto-switching every 30 seconds
    _startAutoSlide();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel(); // Cancel the timer when widget is disposed
    super.dispose();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      setState(() {
        // Ensure we loop back to the first image after the last one
        if (_currentPage < _pageController.page!.toInt() - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
    });
  }

  void _previousImage() {
    setState(() {
      if (_currentPage > 0) {
        _currentPage--;
      } else {
        _currentPage = _pageController.positions.length - 1; // Loop back to the last image
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _nextImage(int totalPages) {
    setState(() {
      if (_currentPage < totalPages - 1) {
        _currentPage++;
      } else {
        _currentPage = 0; // Loop back to the first image after the last one
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _bannersStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading');
        }

        final totalPages = snapshot.data!.docs.length;

        return Stack(
          alignment: Alignment.center,
          children: [
            // Banner Carousel
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              height: 180,
              width: double.infinity,
              child: PageView.builder(
                controller: _pageController,
                itemCount: totalPages,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  final bannerUrl = snapshot.data!.docs[index]['bannerImage'];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: bannerUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                    ),
                  );
                },
              ),
            ),
            // Left Arrow
            Positioned(
              left: 10,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                ),
                onPressed: _previousImage,
              ),
            ),
            // Right Arrow
            Positioned(
              right: 10,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                ),
                onPressed: () => _nextImage(totalPages),
              ),
            ),
            // Indicator for the carousel
            Positioned(
              bottom: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(totalPages, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _currentPage == index ? 12 : 8,
                    height: _currentPage == index ? 12 : 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
                          ? Colors.blue
                          : Colors.grey.withOpacity(0.5),
                    ),
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }
}

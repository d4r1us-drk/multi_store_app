import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TopBar extends StatefulWidget {
  const TopBar({super.key});

  @override
  _TopBarState createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    _focusNode.unfocus();
    setState(() {
      _isFocused = false;
    });
  }

  void _submitSearch(String query) {
    // Placeholder function to handle the search submission
    // Implement your search logic here
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueAccent, // Background color for the top bar
      padding: const EdgeInsets.fromLTRB(
          16.0, 8.0, 16.0, 8.0), // Adjusted padding for top separation
      child: Row(
        children: [
          // SVG App Logo
          SvgPicture.asset(
            'assets/svg/shopping.svg',
            width: 40.0,
            height: 40.0,
            color: Colors.white,
          ),
          const SizedBox(width: 16.0),
          // Search Bar
          Expanded(
            child: Container(
              height: 45.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Search Icon
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(
                      Icons.search,
                      color: Colors.grey[600],
                    ),
                  ),
                  // Search TextField
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      decoration: const InputDecoration(
                        hintText: 'Search anything...',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 16.0,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                      ),
                      onSubmitted: _submitSearch, // Handles submission
                    ),
                  ),
                  // Conditionally Show Close Button
                  if (_isFocused)
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: _clearSearch,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

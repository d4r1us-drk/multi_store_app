import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_store_app/models/product_model.dart';
import 'package:multi_store_app/models/favorite_model.dart';
import 'package:multi_store_app/providers/product_notifier.dart';
import 'package:multi_store_app/providers/cart_notifier.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  bool _isFavorite = false;
  String? _userId;
  String? _favoriteId;

  @override
  void initState() {
    super.initState();
    _getUser();
    _checkIfFavorite();
  }

  // Get current user ID from FirebaseAuth
  void _getUser() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
      });
    }
  }

  // Check if the product is already in the user's favorites
  void _checkIfFavorite() async {
    if (_userId != null) {
      bool isFavorite = await ref
          .read(productProvider.notifier)
          .isFavorite(_userId!, widget.product.id);
      setState(() {
        _isFavorite = isFavorite;
      });
    }
  }

  // Add product to favorites
  void _addToFavorites() async {
    if (_userId == null) return;

    final favorite = FavoriteModel(
      userId: _userId!,
      productId: widget.product.id,
      productName: widget.product.productName,
      price: widget.product.price,
      imageUrl: widget.product.images[0],
    );

    await ref.read(productProvider.notifier).addFavorite(favorite);
    setState(() {
      _isFavorite = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Added to favorites')),
    );
  }

  // Remove product from favorites
  void _removeFromFavorites() async {
    if (_userId != null) {
      await ref
          .read(productProvider.notifier)
          .removeFavorite(_userId!, widget.product.id);
      setState(() {
        _isFavorite = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Removed from favorites')),
      );
    }
  }

  // Add product to the cart using CartNotifier
  Future<void> _addToCart() async {
    if (_userId == null) return;

    await ref.read(cartProvider.notifier).addProductToCart(
          productName: widget.product.productName,
          productPrice: widget.product.price,
          productCategory: widget.product.category,
          imageUrl: widget.product.images,
          quantity: 1, // Default to 1 when adding to cart
          stock: widget.product.size,
          productId: widget.product.id,
          productSize: widget.product.size,
          discount: widget.product.discount,
          description: widget.product.description,
          userId: _userId!, // Pass the logged-in user ID
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Added to cart')),
    );
  }

  @override
  Widget build(BuildContext context) {
    double discountedPrice = widget.product.price -
        (widget.product.price * (widget.product.discount / 100));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.productName),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
            tooltip: _isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
            onPressed: () {
              if (_isFavorite) {
                _removeFromFavorites();
              } else {
                _addToFavorites();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carousel for product images
            FlutterCarousel(
              options: FlutterCarouselOptions(
                height: 300,
                showIndicator: true,
                autoPlay: true,
                slideIndicator: CircularSlideIndicator(),
              ),
              items: widget.product.images.map((imageUrl) {
                return Builder(
                  builder: (BuildContext context) {
                    return CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    widget.product.productName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Product Price with Discount
                  Row(
                    children: [
                      Text(
                        '\$${discountedPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.product.discount > 0) ...[
                        const SizedBox(width: 10),
                        Text(
                          '\$${widget.product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${widget.product.discount}% off',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Product Description
                  const Text(
                    'Product Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  // Product Category
                  Text(
                    'Category: ${widget.product.category}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  // Product Size
                  Text(
                    'Size: ${widget.product.size}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _addToCart,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Add to Cart',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}

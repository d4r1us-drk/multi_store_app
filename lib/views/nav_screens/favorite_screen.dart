import 'package:flutter/material.dart';
import 'package:multi_store_app/controllers/favorite_controller.dart';
import 'package:multi_store_app/models/favorite_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:multi_store_app/models/product_model.dart';
import 'package:multi_store_app/views/popup_screens/product_details_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final FavoriteController _favoriteController = FavoriteController();
  String? _userId;

  @override
  void initState() {
    super.initState();
    _getUserId();
  }

  // Fetch current user ID from FirebaseAuth
  void _getUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
      });
    }
  }

  // Fetch product details from Firestore based on productId
  Future<ProductModel?> _fetchProductDetails(String productId) async {
    try {
      final productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();
      if (productSnapshot.exists) {
        return ProductModel.fromDocument(
            productSnapshot); // Adjust this according to your ProductModel constructor
      }
    } catch (e) {
      print('Error fetching product details: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        backgroundColor: Colors.green,
      ),
      body: _userId == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('favorites')
                  .where('userId', isEqualTo: _userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No favorites yet',
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                final favoriteDocs = snapshot.data!.docs;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header to display the number of favorite items
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      color: Colors.grey[200],
                      child: Text(
                        'You have ${favoriteDocs.length} item(s)',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: favoriteDocs.length,
                        itemBuilder: (context, index) {
                          final doc = favoriteDocs[index];
                          final favorite = FavoriteModel.fromMap(
                              doc.data() as Map<String, dynamic>);
                          final favoriteId =
                              doc.id; // This is the Firestore document ID

                          return FutureBuilder<ProductModel?>(
                            future: _fetchProductDetails(favorite.productId),
                            builder: (context, productSnapshot) {
                              if (productSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const ListTile(
                                  title: Text('Loading product details...'),
                                );
                              }

                              if (productSnapshot.hasError ||
                                  !productSnapshot.hasData) {
                                return const ListTile(
                                  title: Text('Failed to load product details'),
                                );
                              }

                              final product = productSnapshot.data!;

                              return GestureDetector(
                                onTap: () {
                                  // Navigate to the product details screen when clicked
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ProductDetailsScreen(
                                              product: product),
                                    ),
                                  );
                                },
                                child: Card(
                                  margin: const EdgeInsets.all(8.0),
                                  child: ListTile(
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: CachedNetworkImage(
                                        imageUrl: product.images[0],
                                        fit: BoxFit.cover,
                                        width: 50,
                                        height: 50,
                                        placeholder: (context, url) =>
                                            const CircularProgressIndicator(),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                      ),
                                    ),
                                    title: Text(product.productName),
                                    subtitle: Text(
                                        '\$${product.price.toStringAsFixed(2)}'),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () async {
                                        try {
                                          await _favoriteController
                                              .removeFromFavorites(favoriteId);
                                          if (mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Removed from favorites'),
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Failed to remove favorite'),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

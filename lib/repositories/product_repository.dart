import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_store_app/models/product_model.dart';
import 'package:multi_store_app/models/favorite_model.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch a product by its ID
  Future<ProductModel?> getProductById(String productId) async {
    try {
      final docSnapshot =
          await _firestore.collection('products').doc(productId).get();
      if (docSnapshot.exists) {
        return ProductModel.fromDocument(docSnapshot);
      }
      return null;
    } catch (e) {
      throw Exception("Failed to fetch product details: $e");
    }
  }

  // Add a product to favorites
  Future<void> addToFavorites(FavoriteModel favorite) async {
    try {
      await _firestore.collection('favorites').add(favorite.toMap());
    } catch (e) {
      throw Exception("Failed to add product to favorites: $e");
    }
  }

  // Remove a product from favorites by Firestore document ID
  Future<void> removeFromFavorites(String favoriteId) async {
    try {
      await _firestore.collection('favorites').doc(favoriteId).delete();
    } catch (e) {
      throw Exception("Failed to remove product from favorites: $e");
    }
  }

  // Check if the product is a favorite
  Future<bool> checkIfFavorite(String userId, String productId) async {
    final QuerySnapshot snapshot = await _firestore
        .collection('favorites')
        .where('userId', isEqualTo: userId)
        .where('productId', isEqualTo: productId)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  // Fetch favorite ID based on userId and productId
  Future<String?> getFavoriteId(String userId, String productId) async {
    final QuerySnapshot snapshot = await _firestore
        .collection('favorites')
        .where('userId', isEqualTo: userId)
        .where('productId', isEqualTo: productId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.id; // Return the favorite document ID
    }
    return null; // No favorite found
  }

  // Stream user favorites
  Stream<List<FavoriteModel>> getUserFavorites(String userId) {
    return _firestore
        .collection('favorites')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return FavoriteModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
}

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_store_app/models/favorite_model.dart';
import 'package:multi_store_app/models/product_model.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

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

  // Add a new product to Firestore
  Future<void> addProduct(ProductModel product, List<File> imageFiles) async {
    try {
      List<String> imageUrls = [];

      // Upload each image and get the URL
      for (File imageFile in imageFiles) {
        String imageUrl =
            await _uploadProductImage(imageFile, product.productName);
        imageUrls.add(imageUrl);
      }

      // Create a new product with the image URLs
      final newProduct = product.copyWith(images: imageUrls);

      // Add product to Firestore
      await _firestore.collection('products').add(newProduct.toMap());
    } catch (e) {
      throw Exception("Failed to add product: $e");
    }
  }

  // Update an existing product in Firestore
  Future<void> updateProduct(ProductModel product, [File? imageFile]) async {
    try {
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _uploadProductImage(imageFile, product.productName);
      }

      final updatedProduct =
          imageUrl != null ? product.copyWith(images: [imageUrl]) : product;
      await _firestore
          .collection('products')
          .doc(product.id)
          .update(updatedProduct.toMap());
    } catch (e) {
      throw Exception("Failed to update product: $e");
    }
  }

  // Helper method to upload a product image to Firebase Storage
  Future<String> _uploadProductImage(File imageFile, String productName) async {
    try {
      final ref = _firebaseStorage
          .ref()
          .child('product_images')
          .child('$productName-${DateTime.now()}.jpg');
      final uploadTask = await ref.putFile(imageFile);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception("Failed to upload product image: $e");
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
        return FavoriteModel.fromMap(doc.data());
      }).toList();
    });
  }
}

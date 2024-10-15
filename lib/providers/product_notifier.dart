import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_store_app/models/favorite_model.dart';
import 'package:multi_store_app/models/product_model.dart';
import 'package:multi_store_app/repositories/product_repository.dart';

final productProvider =
    StateNotifierProvider<ProductNotifier, List<ProductModel>>(
  (ref) => ProductNotifier(ref),
);

class ProductNotifier extends StateNotifier<List<ProductModel>> {
  final ProductRepository _productRepository;

  ProductNotifier(Ref ref)
      : _productRepository = ref.read(productRepositoryProvider),
        super([]);

  // Fetch product by ID and add it to the state
  Future<ProductModel?> fetchProductById(String productId) async {
    final product = await _productRepository.getProductById(productId);
    if (product != null) {
      state = [...state, product]; // Add fetched product to the state
    }
    return product;
  }

  // Add a new product
  Future<void> addProduct(ProductModel product, List<File> imageFiles) async {
    try {
      await _productRepository.addProduct(product, imageFiles);
      // Once the product is added, refresh the state
      state = [...state, product];
    } catch (e) {
      throw Exception("Failed to add product: $e");
    }
  }

  // Update an existing product
  Future<void> updateProduct(ProductModel product, [File? imageFile]) async {
    try {
      await _productRepository.updateProduct(product, imageFile);
      // Update the product in the state
      state = [
        for (final prod in state)
          if (prod.id == product.id) product else prod,
      ];
    } catch (e) {
      throw Exception("Failed to update product: $e");
    }
  }

  // Stream user favorites
  Stream<List<FavoriteModel>> getUserFavorites(String userId) {
    return _productRepository.getUserFavorites(userId);
  }

  // Add a favorite product
  Future<void> addFavorite(FavoriteModel favorite) async {
    await _productRepository.addToFavorites(favorite);
  }

  // Remove a favorite product using userId and productId
  Future<void> removeFavorite(String userId, String productId) async {
    final favoriteId =
        await _productRepository.getFavoriteId(userId, productId);
    if (favoriteId != null) {
      await _productRepository.removeFromFavorites(favoriteId);
    } else {
      throw Exception("Favorite not found");
    }
  }

  // Check if a product is a favorite
  Future<bool> isFavorite(String userId, String productId) async {
    return await _productRepository.checkIfFavorite(userId, productId);
  }
}

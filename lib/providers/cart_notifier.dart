import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_store_app/models/cart_model.dart';
import 'package:multi_store_app/repositories/cart_repository.dart';

final cartProvider =
    StateNotifierProvider<CartNotifier, Map<String, CartModel>>(
  (ref) => CartNotifier(ref),
);

class CartNotifier extends StateNotifier<Map<String, CartModel>> {
  final CartRepository _cartRepository;

  CartNotifier(Ref ref)
      : _cartRepository = ref.read(cartRepositoryProvider),
        super({});

  /// Add a product to the cart and save to Firebase
  Future<void> addProductToCart({
    required String productName,
    required double productPrice,
    required String productCategory,
    required List<String> imageUrl,
    required int quantity,
    required String stock,
    required String productId,
    required String productSize,
    required double discount,
    required String description,
    required String userId,
  }) async {
    final cartItem = CartModel(
      productName: productName,
      productPrice: productPrice,
      productCategory: productCategory,
      imageUrl: imageUrl,
      quantity: quantity,
      stock: stock,
      productId: productId,
      productSize: productSize,
      discount: discount,
      description: description,
    );

    // First update the local state
    state = {
      ...state,
      productId: cartItem,
    };

    // Then call the repository to persist data in Firebase
    await _cartRepository.addProductToCart(userId, cartItem);
  }

  /// Remove an item from the cart and Firebase
  Future<void> removeItem(String productId, String userId) async {
    state.remove(productId);
    state = {...state};

    await _cartRepository.removeProductFromCart(userId, productId);
  }

  /// Increment the quantity in Firebase
  Future<void> incrementItem(String productId, String userId) async {
    if (state.containsKey(productId)) {
      final currentQuantity = state[productId]!.quantity + 1;
      state = {
        ...state,
        productId: state[productId]!.copyWith(quantity: currentQuantity),
      };

      await _cartRepository.updateCartQuantity(
          userId, productId, currentQuantity);
    }
  }

  /// Decrement the quantity and remove if zero
  Future<void> decrementItem(String productId, String userId) async {
    if (state.containsKey(productId)) {
      final currentQuantity = state[productId]!.quantity - 1;
      if (currentQuantity > 0) {
        state = {
          ...state,
          productId: state[productId]!.copyWith(quantity: currentQuantity),
        };

        await _cartRepository.updateCartQuantity(
            userId, productId, currentQuantity);
      } else {
        await removeItem(productId, userId);
      }
    }
  }

  /// Clear the cart locally and in Firebase
  Future<void> clearCart(String userId) async {
    state = {}; // Clear local state
    await _cartRepository.clearCart(userId); // Clear Firebase cart
  }

  /// Calculate total price
  double calculateTotal() {
    double totalAmount = 0.0;
    state.forEach((productId, cartItem) {
      totalAmount +=
          (cartItem.quantity * (cartItem.productPrice - cartItem.discount));
    });
    return totalAmount;
  }
}

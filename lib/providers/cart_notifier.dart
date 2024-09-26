import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_store_app/models/cart_model2.dart';

final cartProvider =
    StateNotifierProvider<CartNotifier, Map<String, CartModel2>>(
        (ref) => CartNotifier());

class CartNotifier extends StateNotifier<Map<String, CartModel2>> {
  CartNotifier() : super({});

  void addProductToCart(
      {required productName,
      required productPrice,
      required productCategory,
      required imageUrl,
      required quantity,
      required stock,
      required productId,
      required productSize,
      required discount,
      required description}) {
    if (state.containsKey(productId)) {
      state = {
        ...state,
        productId: CartModel2(
            productName: state[productId]!.productName,
            productPrice: state[productId]!.productPrice,
            productCategory: state[productId]!.productCategory,
            imageUrl: state[productId]!.imageUrl,
            quantity: state[productId]!.quantity++,
            stock: state[productId]!.stock,
            productId: state[productId]!.productId,
            productSize: state[productId]!.productSize,
            discount: state[productId]!.discount,
            description: state[productId]!.description)
      };
    } else {
      state = {
        ...state,
        productId: CartModel2(
            productName: productName,
            productPrice: productPrice,
            productCategory: productCategory,
            imageUrl: imageUrl,
            quantity: quantity,
            stock: stock,
            productId: productId,
            productSize: productSize,
            discount: discount,
            description: description)
      };
    }
  }

  void removeItem(String productId) {
    state.remove(productId);
    state = {...state};
  }

  void incrementItem(String productId) {
    if (state.containsKey(productId)) {
      state[productId]!.quantity++;
    } else {
      return;
    }
    state = {...state};
  }

  void decrementItem(String productId) {
    if (state.containsKey(productId)) {
      state[productId]!.quantity--;
    } else {
      return;
    }
    state = {...state};
  }

  double calculateTotal() {
    double totalAmout = 0.0;
    state.forEach((productId, cartItem) {
      totalAmout +=
          (cartItem.quantity * (cartItem.productPrice - cartItem.discount));
    });
    return totalAmout;
  }
}

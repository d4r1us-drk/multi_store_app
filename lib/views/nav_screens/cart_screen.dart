import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multi_store_app/controllers/cart_controller.dart';
import 'package:multi_store_app/controllers/product_controller.dart';
import 'package:multi_store_app/models/cart_model.dart';
import 'package:multi_store_app/views/popup_screens/product_details_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartController _cartController = CartController();
  final ProductController _productController =
      ProductController(); // Initialize ProductController
  String? _userId;
  double totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _getUserId();
  }

  void _getUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _userId == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<QueryDocumentSnapshot>>(
              stream: _cartController
                  .getUserCartItemsWithDocumentSnapshot(_userId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Your cart is empty'));
                }

                final cartItems = snapshot.data!;
                totalPrice = _calculateTotalPrice(cartItems);

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final cartItemDoc = cartItems[index];
                          final cartItem = CartModel.fromMap(
                              cartItemDoc.data() as Map<String, dynamic>);

                          // Calculate discounted price for the item
                          double discountedPrice = cartItem.price -
                              (cartItem.price * (cartItem.discount / 100));

                          return GestureDetector(
                            onTap: () async {
                              // Fetch full product details from Firestore using ProductController
                              final product = await _productController
                                  .getProductById(cartItem.productId);

                              if (product != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailsScreen(
                                      product: product,
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Failed to load product details')),
                                );
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: SizedBox(
                                  height: 120, // Define the card height
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Product Image
                                      Container(
                                        width: 100,
                                        height: 100,
                                        margin: const EdgeInsets.all(8.0),
                                        child: Image.network(
                                          cartItem.imageUrl,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Product Name
                                              Text(
                                                cartItem.productName,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 8),
                                              // Discounted Price with original price and discount percentage
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '\$${discountedPrice.toStringAsFixed(2)}',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.green,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  if (cartItem.discount > 0)
                                                    Row(
                                                      children: [
                                                        Text(
                                                          '\$${cartItem.price.toStringAsFixed(2)}',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.red,
                                                            decoration:
                                                                TextDecoration
                                                                    .lineThrough,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 5),
                                                        Text(
                                                          '${cartItem.discount}% off',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                Colors.orange,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Quantity and Remove Button aligned bottom-right
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 8.0, right: 8.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              _buildQuantitySelector(
                                                  cartItem, cartItemDoc.id),
                                              // Remove Button as an IconButton
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () {
                                                  _cartController
                                                      .removeFromCart(
                                                          cartItemDoc.id);
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Cart Summary
                    _buildCartSummary(context),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildQuantitySelector(CartModel cartItem, String cartItemDocId) {
    return Row(
      mainAxisSize: MainAxisSize.min, // Constrain the row width
      children: [
        IconButton(
          onPressed: () {
            if (cartItem.quantity > 1) {
              _cartController.updateCartQuantity(
                  cartItemDocId, cartItem.quantity - 1);
            }
          },
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Text(cartItem.quantity.toString()),
        IconButton(
          onPressed: () {
            _cartController.updateCartQuantity(
                cartItemDocId, cartItem.quantity + 1);
          },
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }

  Widget _buildCartSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey[200],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Total: \$${totalPrice.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Handle checkout functionality
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Proceed to Checkout',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  // Update the total price to account for discounts
  double _calculateTotalPrice(List<QueryDocumentSnapshot> cartItems) {
    double total = 0;
    for (var doc in cartItems) {
      final cartItem = CartModel.fromMap(doc.data() as Map<String, dynamic>);
      double discountedPrice =
          cartItem.price - (cartItem.price * (cartItem.discount / 100));
      total += discountedPrice * cartItem.quantity;
    }
    return total;
  }
}

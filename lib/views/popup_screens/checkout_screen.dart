import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_store_app/providers/cart_notifier.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final totalAmount = ref.watch(cartProvider.notifier).calculateTotal();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.green,
      ),
      body: cartItems.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Order Summary',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final cartItem = cartItems.values.elementAt(index);
                        return ListTile(
                          leading: Image.network(cartItem.imageUrl[0]),
                          title: Text(cartItem.productName),
                          subtitle: Text(
                              '\$${cartItem.productPrice.toStringAsFixed(2)} x ${cartItem.quantity}'),
                          trailing: Text(
                            '\$${(cartItem.productPrice * cartItem.quantity).toStringAsFixed(2)}',
                          ),
                        );
                      },
                    ),
                  ),
                  Text(
                    'Total: \$${totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Choose a payment method:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  // Stripe Payment Button
                  ElevatedButton.icon(
                    onPressed: () {
                      // Logic for Stripe Payment
                    },
                    icon: const Icon(Icons.credit_card),
                    label: const Text('Pay with Stripe'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6772E5), // Stripe's blue
                      foregroundColor: Colors.white, // White text and icon
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // PayPal Payment Button
                  ElevatedButton.icon(
                    onPressed: () {
                      // Logic for PayPal Payment
                    },
                    icon: const Icon(Icons.account_balance_wallet),
                    label: const Text('Pay with PayPal'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF003087), // PayPal's blue
                      foregroundColor: Colors.white, // White text and icon
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Monero Payment Button
                  ElevatedButton.icon(
                    onPressed: () {
                      // Logic for Monero Payment
                    },
                    icon: const Icon(Icons.monetization_on),
                    label: const Text('Pay with Monero'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFFF26822), // Monero's orange
                      foregroundColor: Colors.white, // White text and icon
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // Handle order confirmation
                      _confirmOrder(ref, context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white, // White text
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Confirm Purchase',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _confirmOrder(WidgetRef ref, BuildContext context) async {
    // Simulate order processing
    await ref
        .read(cartProvider.notifier)
        .clearCart(FirebaseAuth.instance.currentUser!.uid);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order placed successfully!')),
    );
    Navigator.pop(context); // Go back after placing the order
  }
}

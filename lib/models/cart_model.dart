class CartModel {
  final String userId;
  final String productId;
  final String productName;
  final double price;
  final double discount;
  final int quantity;
  final String imageUrl;

  CartModel({
    required this.userId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.discount,
    required this.quantity,
    required this.imageUrl,
  });

  // Convert a CartModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'productId': productId,
      'productName': productName,
      'price': price,
      'discount': discount, // Include discount in the map
      'quantity': quantity,
      'imageUrl': imageUrl,
    };
  }

  // Create a CartModel from a Firestore document
  static CartModel fromMap(Map<String, dynamic> map) {
    return CartModel(
      userId: map['userId'],
      productId: map['productId'],
      productName: map['productName'],
      price: map['price'],
      discount: map['discount'] ?? 0.0,
      quantity: map['quantity'],
      imageUrl: map['imageUrl'],
    );
  }
}

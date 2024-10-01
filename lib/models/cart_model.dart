class CartModel {
  final String productName;
  final double productPrice;
  final String productCategory;
  final List<String> imageUrl;
  final int quantity;
  final String stock;
  final String productId;
  final String productSize;
  final double discount;
  final String description;

  CartModel({
    required this.productName,
    required this.productPrice,
    required this.productCategory,
    required this.imageUrl,
    required this.quantity,
    required this.stock,
    required this.productId,
    required this.productSize,
    required this.discount,
    required this.description,
  });

  /// CopyWith method to create a modified copy of CartModel2
  CartModel copyWith({
    String? productName,
    double? productPrice,
    String? productCategory,
    List<String>? imageUrl,
    int? quantity,
    String? stock,
    String? productId,
    String? productSize,
    double? discount,
    String? description,
  }) {
    return CartModel(
      productName: productName ?? this.productName,
      productPrice: productPrice ?? this.productPrice,
      productCategory: productCategory ?? this.productCategory,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
      stock: stock ?? this.stock,
      productId: productId ?? this.productId,
      productSize: productSize ?? this.productSize,
      discount: discount ?? this.discount,
      description: description ?? this.description,
    );
  }

  /// Convert CartModel2 to a Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'productName': productName,
      'productPrice': productPrice,
      'productCategory': productCategory,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'stock': stock,
      'productId': productId,
      'productSize': productSize,
      'discount': discount,
      'description': description,
    };
  }

  /// Create CartModel2 from a Map (for reading from Firebase)
  factory CartModel.fromMap(Map<String, dynamic> map) {
    return CartModel(
      productName: map['productName'],
      productPrice: map['productPrice'],
      productCategory: map['productCategory'],
      imageUrl: List<String>.from(map['imageUrl']),
      quantity: map['quantity'],
      stock: map['stock'],
      productId: map['productId'],
      productSize: map['productSize'],
      discount: map['discount'],
      description: map['description'],
    );
  }
}

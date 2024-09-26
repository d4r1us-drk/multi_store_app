class FavoriteModel {
  final String userId;
  final String productId;
  final String productName;
  final double price;
  final String imageUrl;

  FavoriteModel({
    required this.userId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'productId': productId,
      'productName': productName,
      'price': price,
      'imageUrl': imageUrl,
    };
  }

  static FavoriteModel fromMap(Map<String, dynamic> map) {
    return FavoriteModel(
      userId: map['userId'],
      productId: map['productId'],
      productName: map['productName'],
      price: map['price'],
      imageUrl: map['imageUrl'],
    );
  }
}

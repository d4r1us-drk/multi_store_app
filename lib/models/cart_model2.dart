class CartModel2 {
  final String productName;
  final double productPrice;
  final String productCategory;
  final List<dynamic> imageUrl;
  int quantity;
  final int stock;
  final String productId;
  final String productSize;
  final double discount;
  final String description;

  CartModel2(
      {required this.productName,
      required this.productPrice,
      required this.productCategory,
      required this.imageUrl,
      required this.quantity,
      required this.stock,
      required this.productId,
      required this.productSize,
      required this.discount,
      required this.description});
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:multi_store_app/models/product_model.dart';

class ProductController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
}

import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String productName;
  final double price;
  final double discount;
  final int quantity;
  final String description;
  final String category;
  final String size;
  final List<String> images;

  ProductModel({
    required this.id,
    required this.productName,
    required this.price,
    required this.discount,
    required this.quantity,
    required this.description,
    required this.category,
    required this.size,
    required this.images,
  });

  // Factory method to create a ProductModel from Firestore document
  factory ProductModel.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return ProductModel(
      id: doc.id,
      productName: data['productName'],
      price: (data['price'] is int)
          ? (data['price'] as int).toDouble()
          : data['price'],
      discount: (data['discount'] is int)
          ? (data['discount'] as int).toDouble()
          : data['discount'],
      quantity: data['quantity'],
      description: data['description'],
      category: data['category'],
      size: data['size'],
      images: List<String>.from(data['images']),
    );
  }

  // Convert a ProductModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'productName': productName,
      'price': price,
      'discount': discount,
      'quantity': quantity,
      'description': description,
      'category': category,
      'size': size,
      'images': images,
    };
  }

  // copyWith method to update only certain fields while keeping others the same
  ProductModel copyWith({
    String? id,
    String? productName,
    double? price,
    double? discount,
    int? quantity,
    String? description,
    String? category,
    String? size,
    List<String>? images,
  }) {
    return ProductModel(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      discount: discount ?? this.discount,
      quantity: quantity ?? this.quantity,
      description: description ?? this.description,
      category: category ?? this.category,
      size: size ?? this.size,
      images: images ?? this.images,
    );
  }
}

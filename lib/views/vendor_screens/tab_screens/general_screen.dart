import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_store_app/models/product_model.dart';
import 'package:multi_store_app/providers/product_notifier.dart';

class GeneralScreen extends ConsumerStatefulWidget {
  GeneralScreen({super.key});

  @override
  ConsumerState<GeneralScreen> createState() => _GeneralScreenState();
}

class _GeneralScreenState extends ConsumerState<GeneralScreen> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  List<String> _categoriesList = [];
  List<File> _selectedImages = []; // List to store multiple images

  // Text editing controllers
  final productNameController = TextEditingController();
  final priceController = TextEditingController();
  final quantityController = TextEditingController();
  final descriptionController = TextEditingController();
  final discountController = TextEditingController(); // Controller for discount
  final sizeController = TextEditingController(); // Controller for size

  String? _selectedCategory;

  // Fetch categories from Firestore
  Future<void> _getCategories() async {
    final querySnapshot =
        await _firebaseFirestore.collection('categories').get();
    setState(() {
      _categoriesList = querySnapshot.docs
          .map((doc) => doc['categoryName'] as String)
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _getCategories();
  }

  // Pick multiple images for the product
  Future<void> _pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true, // Allow selecting multiple images
    );
    if (result != null) {
      setState(() {
        _selectedImages = result.paths.map((path) => File(path!)).toList();
      });
    }
  }

  // Save product using the product provider
  Future<void> _saveProduct() async {
    if (productNameController.text.isEmpty ||
        _selectedCategory == null ||
        _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please fill out all fields and upload images.')));
      return;
    }

    final product = ProductModel(
      id: '',
      productName: productNameController.text,
      price: double.parse(priceController.text),
      discount:
          double.tryParse(discountController.text) ?? 0.0, // Handle discount
      quantity: int.parse(quantityController.text),
      description: descriptionController.text,
      category: _selectedCategory!,
      size: sizeController.text, // Add size
      images: [], // Will be populated after image upload
    );

    // Add product via provider
    await ref
        .read(productProvider.notifier)
        .addProduct(product, _selectedImages);

    // Show confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product saved successfully!')),
    );

    // Clear form fields and selected images after saving the product
    _clearForm();
  }

  // Clear form fields
  void _clearForm() {
    setState(() {
      productNameController.clear();
      priceController.clear();
      quantityController.clear();
      descriptionController.clear();
      discountController.clear();
      sizeController.clear();
      _selectedCategory = null;
      _selectedImages = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: productNameController,
                decoration:
                    const InputDecoration(labelText: 'Enter Product Name'),
              ),
              TextFormField(
                controller: priceController,
                decoration:
                    const InputDecoration(labelText: 'Enter Product Price'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: quantityController,
                decoration:
                    const InputDecoration(labelText: 'Enter Product Quantity'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: discountController,
                decoration:
                    const InputDecoration(labelText: 'Enter Product Discount'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: sizeController,
                decoration:
                    const InputDecoration(labelText: 'Enter Product Size'),
              ),
              DropdownButtonFormField<String>(
                hint: const Text("Please Select"),
                value: _selectedCategory,
                items: _categoriesList.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: descriptionController,
                maxLines: 6,
                maxLength: 800,
                decoration: InputDecoration(
                  labelText: 'Enter Product Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _pickImages,
                child: const Text('Pick Product Images'),
              ),
              const SizedBox(height: 10),
              // Display selected images
              if (_selectedImages.isNotEmpty)
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: Image.file(
                          _selectedImages[index],
                          height: 200,
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProduct,
                child: const Text('Save Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

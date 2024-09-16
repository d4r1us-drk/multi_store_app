import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multi_store_app/models/category_model.dart';

class CategoryWidget extends StatefulWidget {
  const CategoryWidget({super.key});

  @override
  State<CategoryWidget> createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends State<CategoryWidget> {
  final Stream<QuerySnapshot> _categoryStream =
      FirebaseFirestore.instance.collection('categories').snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _categoryStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading");
        }

        return Column(children: [
          GridView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data!.docs.length,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 4,
                crossAxisSpacing:
                    4), // SliverGridDelegateWithFixedCrossAxisCount
            itemBuilder: (context, index) {
              CategoryModel category = CategoryModel(
                  categoryName: snapshot.data!.docs[index]['categoryName'],
                  categoryImage: snapshot.data!.docs[index]['categoryImage']);
              return GestureDetector(
                onTap: () {},
                child: Column(children: [
                  Image.network(category.categoryImage,
                      width: 47, height: 47, fit: BoxFit.cover),
                  Text(category.categoryName)
                ]),
              );
            },
          )
        ]);
      },
    );
  }
}

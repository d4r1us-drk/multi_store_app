import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GeneralScreen extends StatefulWidget {
   GeneralScreen({super.key});

  @override
  State<GeneralScreen> createState() => _GeneralScreenState();
}

class _GeneralScreenState extends State<GeneralScreen> {
   final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

   List _categoriesList = [];

   _getCategories() async{
     return _firebaseFirestore.collection('categories').get().then((QuerySnapshot querySnapshot) {
       querySnapshot.docs.forEach((element) {
         setState(() {
           _categoriesList.add(element['categoryName']);
         });

       });
     },);
   }


   @override
  void initState() {
    // TODO: implement initState
     _getCategories();
    super.initState();
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
                decoration: InputDecoration(
                  labelText: 'Enter Product Name'
                ),
              ),
              TextFormField(
                decoration: InputDecoration(
                    labelText: 'Enter Product Price'
                ),
              ),
              TextFormField(
                decoration: InputDecoration(
                    labelText: 'Enter Product Quantity',
                ),
              ),
              DropdownButtonFormField(
                hint: Text("Please Select"),
                items: _categoriesList.map((value) {
                  return DropdownMenuItem(
                    //alignment: Alignment.bottomRight,
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {

                  });
                },
              ),
              SizedBox(
                height: 30,
              ),
              TextFormField(
                maxLines: 6,
                maxLength: 800,
                decoration: InputDecoration(
                  labelText: 'Enter Product Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0)
                    )
                ),
              ),
              Row(
                children: [
                  TextButton(
                      onPressed: (){
                        showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2050));
                      },
                      child: Text('Schedule')
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

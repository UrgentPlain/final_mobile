import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Makeup Products',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: TextTheme(
          headline1: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.black),
          headline2: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black),
          bodyText1: TextStyle(fontSize: 16.0, color: Colors.black),
          bodyText2: TextStyle(fontSize: 14.0, color: Colors.grey[800]),
        ),
      ),
      home: MakeupProductsScreen(),
    );
  }
}

class MakeupProductsScreen extends StatefulWidget {
  @override
  _MakeupProductsScreenState createState() => _MakeupProductsScreenState();
}

class _MakeupProductsScreenState extends State<MakeupProductsScreen> {
  late Future<List<dynamic>> _selectedProducts;
  String _selectedProductType = 'lipstick';
  String _selectedBrand = 'Maybelline';

  Future<List<dynamic>> fetchProductsByProductTypeAndBrand(String productType, String brand) async {
    final response = await http.get(Uri.parse('http://makeup-api.herokuapp.com/api/v1/products.json?product_type=$productType&brand=$brand'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load products');
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedProducts = fetchProductsByProductTypeAndBrand(_selectedProductType, _selectedBrand);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Makeup Products', style: Theme.of(context).textTheme.headline1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Brand:',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    SizedBox(height: 8),
                    DropdownButton<String>(
                      value: _selectedBrand,
                      items: <String>[
                        'Maybelline', 'L\'almay', 'alva', 'anna sui', 'annabelle', 'benefit', 'boosh', 'butter london', 'cargo cosmetics', 'china glaze', 'clinique', 'coastal classic creation', 'colourpop', 'covergirl', 'dalish', 'deciem'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: Theme.of(context).textTheme.bodyText1),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedBrand = newValue!;
                          _selectedProducts = fetchProductsByProductTypeAndBrand(_selectedProductType, _selectedBrand);
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Product Type:',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    SizedBox(height: 8),
                    DropdownButton<String>(
                      value: _selectedProductType,
                      items: <String>['lipstick', 'eyeliner', 'foundation', 'eyeshadow', 'blush', 'bronzer', 'lip liner']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: Theme.of(context).textTheme.bodyText1),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedProductType = newValue!;
                          _selectedProducts = fetchProductsByProductTypeAndBrand(_selectedProductType, _selectedBrand);
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _selectedProducts,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}', style: Theme.of(context).textTheme.bodyText1));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No products found.', style: Theme.of(context).textTheme.bodyText1));
                  } else {
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 350, // กำหนดขนาดสูงสุดของแกนที่แนวนอน
                        crossAxisSpacing: 5.0,
                        mainAxisSpacing: 5.0,
                        childAspectRatio: 0.7, // กำหนดสัดส่วนของแต่ละช่องใน GridView
                      ),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        var product = snapshot.data![index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailScreen(product: product),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: SizedBox(
                              width: 200, // Adjust the width of the Card
                              height: 200, // Adjust the height of the Card
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                                    child: Image.network(
                                      product['image_link'],
                                      fit: BoxFit.scaleDown, // Adjust BoxFit as per your need
                                      height: 160, // Adjust the height of the image
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      product['name'],
                                      style: Theme.of(context).textTheme.headline2,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0, bottom: 8.0, right: 8.0),
                                    child: Text(
                                      'Brand: ${product['brand']}',
                                      style: Theme.of(context).textTheme.bodyText2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductDetailScreen extends StatelessWidget {
  final dynamic product;

  const ProductDetailScreen({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Details', style: Theme.of(context).textTheme.headline1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  product['image_link'],
                  fit: BoxFit.fitHeight,
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Product Name:',
                      style: Theme.of(context).textTheme.headline2,
                    ),
                    SizedBox(height: 5),
                    Text(
                      product['name'],
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Brand:',
                      style: Theme.of(context).textTheme.headline2,
                    ),
                    SizedBox(height: 5),
                    Text(
                      product['brand'],
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Price:',
                      style: Theme.of(context).textTheme.headline2,
                    ),
                    SizedBox(height: 5),
                    Text(
                      '\$${product['price']}',
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Description:',
                      style: Theme.of(context).textTheme.headline2,
                    ),
                    SizedBox(height: 5),
                    Text(
                      product['description'],
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

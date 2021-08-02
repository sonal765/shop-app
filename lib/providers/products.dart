import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';

import './product.dart';

class Products with ChangeNotifier {
  // a mixin(with) keyword
  List<Product> _items = [
    //   Product(
    //     id: 'p1',
    //     title: 'Shirt',
    //     desc: 'A red shirt - it is pretty red!',
    //     price: 29.99,
    //     imageUrl:
    //         'https://images.unsplash.com/photo-1511746315387-c4a76990fdce?ixid=MnwxMjA3fDB8MHxzZWFyY2h8M3x8c2hpcnQlMjByZWR8ZW58MHx8MHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=600&q=60',
    //   ),
    //   Product(
    //     id: 'p2',
    //     title: 'Trousers',
    //     desc: 'A nice pair of trousers.',
    //     price: 59.99,
    //     imageUrl:
    //         'https://images.unsplash.com/photo-1515459961680-58264ee27219?ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTB8fHRyb3VzZXJ8ZW58MHx8MHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=600&q=60',
    //   ),
    //   Product(
    //     id: 'p3',
    //     title: 'Scarf',
    //     desc: 'Warm and cozy - exactly what you need for the winter.',
    //     price: 19.99,
    //     imageUrl:
    //         'https://images.unsplash.com/photo-1536678000738-c379f493719b?ixid=MnwxMjA3fDB8MHxzZWFyY2h8MjV8fHllbGxvdyUyMHNjYXJmfGVufDB8fDB8fA%3D%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=600&q=60',
    //   ),
    //   Product(
    //     id: 'p4',
    //     title: 'Pan',
    //     desc: 'Prepare any meal you want.',
    //     price: 49.99,
    //     imageUrl:
    //         'https://images.unsplash.com/photo-1588279102819-f4520e40b1c6?ixid=MnwxMjA3fDB8MHxzZWFyY2h8M3x8cGFufGVufDB8fDB8fA%3D%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=600&q=60',
    //   ),
    //
  ];

  // var _showFavouriteOnly = false;

  final String authToken;
  final String userId;

  Products(this.authToken, this.userId, this._items);

  List<Product> get items {
    // if (_showFavouriteOnly) {
    //   return _items.where((prodItem) => prodItem.isFavourite).toList();
    // }
    return [
      ..._items
    ]; //returing a copy of items(private properties) i.e. returning all items
  }

  List<Product> get favitems {
    return _items.where((prodItem) => prodItem.isFavourite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  // void showFavouriteOnly() {
  //   _showFavouriteOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavouriteOnly = false;
  //   notifyListeners();
  // }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url = Uri.parse(
        'https://flutter-update-eb028-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString');

    try {
      final response = await http.get(url); //get for fetching a product
      // we can also provide a header as parameter.
      print(json.decode(response.body));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      url = Uri.parse(
          'https://flutter-update-eb028-default-rtdb.firebaseio.com/userFavourites/$userId.json?auth=$authToken');
      final favouriteResponse = await http.get(url);
      final favouriteData = json.decode(favouriteResponse.body);
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          desc: prodData['description'],
          price: prodData['price'],
          isFavourite:
              favouriteData == null ? false : favouriteData[prodId] ?? false,
          imageUrl: prodData['imageUrl'],
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    //  final url = Uri.https('https://flutter-update-eb028-default-rtdb.firebaseio.com/', /products.json);
    final url = Uri.parse(
        'https://flutter-update-eb028-default-rtdb.firebaseio.com/products.json?auth=$authToken');

    try {
      final response = await http.post(
        //post for adding a product
        url,
        body: json.encode({
          'title': product.title,
          'description': product.desc,
          'imageUrl': product.imageUrl,
          'price': product.price,
          //this is converted into JSON format
          'creatorId': userId,
        }),
      );
      print(json.decode(response.body));
      final newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        price: product.price,
        desc: product.desc,
        imageUrl: product.imageUrl,
      );
      _items.add(newProduct);
      //_items.insert(0,newProduct); at the start of the list
      notifyListeners(); //only the widgets which are listening will be re-built up
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url = Uri.parse(
          'https://flutter-update-eb028-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.desc,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
        'https://flutter-update-eb028-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken'); //query parameter
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    print(response.statusCode);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException("Couldn't delete product.");
    }
    existingProduct = null;
  }
}

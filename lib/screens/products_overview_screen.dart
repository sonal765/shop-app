import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './cart_screen.dart';
import '../widgets/products_grid.dart';
import '../widgets/app_drawer.dart';
import '../widgets/badge.dart';
import '../providers/cart.dart';
import '../providers/products.dart';

enum FilterOptions {
  Favourites,
  All,
}

class ProductsOverviewScreens extends StatefulWidget {
  @override
  _ProductsOverviewScreensState createState() =>
      _ProductsOverviewScreensState();
}

class _ProductsOverviewScreensState extends State<ProductsOverviewScreens> {
  var _showOnlyFavourites = false;
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    // http.get();
    // Provider.of<Products>(context).fetchAndSetProducts();// won't work!
    Future.delayed(Duration.zero).then((_) {
      Provider.of<Products>(context,listen: false).fetchAndSetProducts();
    }); //this is also consider a todo action by dart
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
         _isLoading = true;
      });
      Provider.of<Products>(context,listen: false)
          .fetchAndSetProducts()
          .then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Shop'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              print(selectedValue);
              setState(() {
                if (selectedValue == FilterOptions.Favourites) {
                  // show only Favourites items
                  _showOnlyFavourites = true;
                } else {
                  // showing all items
                  _showOnlyFavourites = false;
                }
              });
            },
            icon: Icon(Icons.more_vert),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Only Favourites'),
                value: FilterOptions.Favourites,
              ),
              PopupMenuItem(
                child: Text('Show All'),
                value: FilterOptions.All,
              ),
            ],
          ),
          Consumer<Cart>(
            builder: (_, cart, ch) => Badge(
              child: ch,
              value: cart.itemCount.toString(),
            ),
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          )
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(_showOnlyFavourites),
    );
  }
}

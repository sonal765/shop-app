import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/widgets/app_drawer.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  // var _isLoading = false;
  @override
  void initState() {
    // Future.delayed(Duration.zero).then((_) async {

    // _isLoading = true;
    // Provider.of<Orders>(context, listen: false).fetchAndSetOrders().then((_) {
    //   setState(() {
    //     _isLoading = false;
    //   });
    // });

    //Alternative in body i.e. FutureBuilder widget

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('Building Orders');
    // final orderData = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Yours Orders'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<Orders>(
          context,
          listen: false,
        ).fetchAndSetOrders(),
        builder: (ctx, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            if (dataSnapshot.connectionState == null) {
              //...
              //Do error handling stuff
              return Center(
                child: Text('An error Occured'),
              );
            } else {
              return Consumer<Orders>(
                builder: (ctx, orderData, child) => ListView.builder(
                  itemBuilder: (ctx, i) => OrderItem(
                    orderData.orders[i],
                  ),
                  itemCount: orderData.orders.length,
                ),
              );
            }
          }
        },
      ),
      //Alternative way
      //  _isLoading
      //     ? Center(
      //         child: CircularProgressIndicator(),
      //       )
      //     : ListView.builder(
      //         itemBuilder: (ctx, i) => OrderItem(
      //           orderData.orders[i],
      //         ),
      //         itemCount: orderData.orders.length,
      //       ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';

class ProductDetailScreen extends StatelessWidget {
  // final String title;
  // final double price;

  // ProductDetailScreen(this.price,this.title);

  static const routeName = '/product-detail';

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context).settings.arguments
        as String; // this will at end give us the id
    // get all the product data through id
    final loadedProduct = Provider.of<Products>(
      context,
      listen: false,
    ).findById(productId);

    return Scaffold(
      // appBar: AppBar(
      //   title: Text(loadedProduct.title),
      // ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 300,
            pinned: true, //appbar is visible always
            flexibleSpace: FlexibleSpaceBar(
              title: Text(loadedProduct.title),
              background: Hero(
                tag: loadedProduct.id,
                child: Image.network(
                  loadedProduct.imageUrl,
                  fit: BoxFit.cover,
                  
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Rs${loadedProduct.price}',
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  width: double.infinity,
                  child: Text(
                    loadedProduct.desc,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                    softWrap: true,
                  ),
                ),
                SizedBox(
                  height: 800,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
//       body: SingleChildScrollView(
//         child: Column(children: <Widget>[
//           Container(
//             height: 300,
//             width: double.infinity,
//             child: Image.network(
//               loadedProduct.imageUrl,
//               fit: BoxFit.cover,
//             ),
//           ),
//           SizedBox(
//             height: 10,
//           ),
//           Text(
//             'Rs${loadedProduct.price}',
//             style: TextStyle(
//               color: Colors.blueGrey,
//               fontSize: 20,
//             ),
//           ),
//           SizedBox(
//             height: 10,
//           ),
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 10),
//             width: double.infinity,
//             child: Text(
//               loadedProduct.desc,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontWeight: FontWeight.w600,
//               ),
//               softWrap: true,
//             ),
//           ),
//         ]),
//       ),
//     );
//   }
// }

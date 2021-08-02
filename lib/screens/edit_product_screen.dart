import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editProduct = Product(
    id: null,
    title: ' ',
    price: 0,
    desc: '',
    imageUrl: '',
  );
  var _intiValues = {
    'title': ' ',
    'price': '',
    'desc': '',
    'imageUrl': '',
  };
  var _isInit = true;
  var _isLoading = false;

  void _updateimageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if (_imageUrlController.text.isEmpty ||
          (!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.png') ||
              !_imageUrlController.text.endsWith('jpg') ||
              !_imageUrlController.text.endsWith('.jpeg'))) {
        return;
      }
      setState(() {});
    }
  }

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateimageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _intiValues = {
          'title': _editProduct.title,
          'price': _editProduct.price.toString(),
          'desc': _editProduct.desc,
          // 'imageUrl': _editProduct.imageUrl, as contoller is used we cannot use this
          'imageUrl': '',
        };
        _imageUrlController.text = _editProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    //free up the memory they occupy when we restart the form
    _priceFocusNode.dispose();
    _descFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_editProduct.id != null) {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editProduct.id, _editProduct);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editProduct);
      } catch (errot) {
        await showDialog<Null>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('An error Occured!'),
            content: Text('Something went wrong.'),
            actions: <Widget>[
              TextButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              )
            ],
          ),
        );
      }
      // finally {
      //   setState(() {
      //     _isLoading = false;
      //   });
      //   Navigator.of(context).pop();
      // }
    }
    print(_editProduct.title);
    print(_editProduct.imageUrl);
    print(_editProduct.desc);
    print(_editProduct.price);
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Products'),
        actions: [
          IconButton(
              onPressed: () {
                _saveForm();
              },
              icon: Icon(Icons.save))
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _intiValues['title'],
                      decoration: InputDecoration(labelText: 'Title'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Please enter a title";
                        }
                        //return null;//this is treated as their is no error n input is correct
                        //return "text";//returning text is treated as it is wrong  or incorrect

                        return null;
                      },
                      onSaved: (value) {
                        _editProduct = Product(
                          id: _editProduct.id,
                          isFavourite: _editProduct.isFavourite,
                          title: value,
                          price: _editProduct.price,
                          desc: _editProduct.desc,
                          imageUrl: _editProduct.imageUrl,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _intiValues['price'],
                      decoration: InputDecoration(
                        labelText: 'Price',
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType
                          .number, //number keyword comes on cursor is clicked
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_descFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Please enter a price.";
                        }
                        if (double.tryParse(value) == null) {
                          return "Please enter a valid number.";
                        }
                        if (double.parse(value) <= 0) {
                          return "Please a enter a number greater than zero";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editProduct = Product(
                          id: _editProduct.id,
                          isFavourite: _editProduct.isFavourite,
                          title: _editProduct.title,
                          price: double.parse(value),
                          desc: _editProduct.desc,
                          imageUrl: _editProduct.imageUrl,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _intiValues['desc'],
                      decoration: InputDecoration(
                        labelText: 'Description',
                      ),
                      maxLines:
                          3, //how many lines as description need more lines
                      keyboardType: TextInputType.multiline,
                      focusNode: _descFocusNode,
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Please enter a description.";
                        }

                        if (value.length < 10) {
                          return "Should be atleast 10 characters long";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editProduct = Product(
                          id: _editProduct.id,
                          isFavourite: _editProduct.isFavourite,
                          title: _editProduct.title,
                          price: _editProduct.price,
                          desc: value,
                          imageUrl: _editProduct.imageUrl,
                        );
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(top: 9, right: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? Text('Enter a URL')
                              : FittedBox(
                                  child: Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Image URL',
                            ),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            onEditingComplete: () {
                              setState(() {});
                            },
                            focusNode: _imageUrlFocusNode,
                            onFieldSubmitted: (_) {
                              _saveForm();
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return "Please enter an image URL.";
                              }
                              if (!value.startsWith('http') &&
                                  !value.startsWith('https')) {
                                return "Please enter a valid URL";
                              }
                              if (!value.endsWith('.png') &&
                                  !value.endsWith('jpg') &&
                                  !value.endsWith('.jpeg')) {
                                return "Please enter a valid image URL";
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _editProduct = Product(
                                id: _editProduct.id,
                                isFavourite: _editProduct.isFavourite,
                                title: _editProduct.title,
                                price: _editProduct.price,
                                desc: _editProduct.desc,
                                imageUrl: value,
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}

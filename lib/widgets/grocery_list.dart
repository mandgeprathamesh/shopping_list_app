import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/models/groceryitem.dart';
import 'package:shopping_list_app/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryitems = [];
  var _isloading = true;
  String? _error;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loaditems();
  }

  void _loaditems() async {
    final url = await Uri.https(
        'flutter-prep-eac86-default-rtdb.firebaseio.com', 'shopping-list.json');
    try {
      final response = await http.get(url);
      if (response.statusCode >= 400) {
        setState(() {
          _error = "Failed to Fetch the Data . Please Try Again Later !...";
        });
      }
      if (response.body == 'null') {
        setState(() {
          _isloading = false;
        });
        return;
      }
      final Map<String, dynamic> listdata = json.decode(response.body);
      final List<GroceryItem> _loadeditems = [];
      for (final item in listdata.entries) {
        final category = categories.entries
            .firstWhere(
                (catitem) => catitem.value.title == item.value['category'])
            .value;
        _loadeditems.add(GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category));
      }
      setState(() {
        _groceryitems = _loadeditems;
        _isloading = false;
      });
    } catch (error) {
      setState(() {
        _error = "Something went Wrong . Please Try Again Later !...";
      });
    }
  }

  void _additem() async {
    final newitem =
        await Navigator.of(context).push<GroceryItem>(MaterialPageRoute(
      builder: (context) => const NewItem(),
    ));
    if (newitem == null) {
      return;
    } else {
      _groceryitems.add(newitem);
    }
    _loaditems();
  }

  void _removeitem(GroceryItem item) async {
    final index = _groceryitems.indexOf(item);
    final url = await Uri.https(
        'flutter-prep-eac86-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      setState(() {
        _groceryitems.insert(index, item);
      });
    }
    setState(() {
      _groceryitems.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Text("No Items There!.."),
    );
    if (_isloading) {
      content = Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_groceryitems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryitems.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: ValueKey(_groceryitems[index].id),
            onDismissed: (direction) {
              _removeitem(_groceryitems[index]);
            },
            child: ListTile(
                title: Text(_groceryitems[index].name),
                leading: Container(
                  width: 24,
                  height: 24,
                  color: _groceryitems[index].category.color,
                ),
                trailing: Text(
                  _groceryitems[index].quantity.toString(),
                )),
          );
        },
      );
    }

    if (_error != null) {
      content = Center(
        child: Text(_error!),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Your Groceries"),
        actions: [
          IconButton(onPressed: _additem, icon: Icon(Icons.add)),
        ],
      ),
      body: content,
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/models/category.dart';
import 'package:shopping_list_app/models/groceryitem.dart';
import 'package:http/http.dart' as http;

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final _formkey = GlobalKey<FormState>();
  var _enteredname = ' ';
  var _enteredquantity = 1;
  var _selectedcategory = categories[Categories.vegetables]!;
  var _issending = false;

  void _saveitem() async {
    if (_formkey.currentState!.validate()) {
      setState(() {
        _issending = true;
      });
      _formkey.currentState!.save();
      final url = await Uri.https(
          'flutter-prep-eac86-default-rtdb.firebaseio.com',
          'shopping-list.json');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(
          {
            'name': _enteredname,
            'quantity': _enteredquantity,
            'category': _selectedcategory.title,
          },
        ),
      );
      final Map<String, dynamic> resdata = json.decode(response.body);

      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pop(GroceryItem(
          id: resdata['name'],
          name: _enteredname,
          quantity: _enteredquantity,
          category: _selectedcategory));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add a  new item"),
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Form(
            key: _formkey,
            child: Column(
              children: [
                TextFormField(
                  maxLength: 50,
                  decoration: InputDecoration(label: Text("Name")),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length <= 1 ||
                        value.trim().length >= 50) {
                      return "Must be between 1 and 50 characters .";
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    _enteredname = newValue!;
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextFormField(
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              int.tryParse(value) == null ||
                              int.tryParse(value)! <= 0) {
                            return "Must be valid positive number";
                          }
                          return null;
                        },
                        decoration: InputDecoration(label: Text("Quantity")),
                        keyboardType: TextInputType.number,
                        initialValue: _enteredquantity.toString(),
                        cursorColor: Color.fromARGB(255, 201, 214, 13),
                        onSaved: (newValue) {
                          _enteredquantity = int.parse(newValue!);
                        },
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: DropdownButtonFormField(
                        value: _selectedcategory,
                        items: [
                          for (final category in categories.entries)
                            DropdownMenuItem(
                              value: category.value,
                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    color: category.value.color,
                                  ),
                                  SizedBox(
                                    width: 6,
                                  ),
                                  Text(category.value.title),
                                ],
                              ),
                            )
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedcategory = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 12,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: _issending
                            ? null
                            : () {
                                _formkey.currentState!.reset();
                              },
                        child: Text("Reset..")),
                    ElevatedButton(
                        onPressed: _issending ? null : _saveitem,
                        child: _issending
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(),
                              )
                            : Text("Add Item"))
                  ],
                )
              ],
            )),
      ),
    );
  }
}

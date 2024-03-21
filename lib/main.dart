import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:http/http.dart' as http;
import 'package:http_project_one/item_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // jsonEncode();
  // jsonDecode();
  List todos = [];
  void getTodos() async {
    final response =
        await http.get(Uri.parse('https://fakestoreapi.com/products'));

    setState(() {
      todos = jsonDecode(response.body);
    });
  }

  @override
  void initState() {
    super.initState();
    getTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Http Sample Project'),
        backgroundColor: Colors.blue[200],
      ),
      body: Center(
        child: ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, int index) {
              return Card(
                child: SizedBox(
                    child: ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProductDetail(
                                  id: todos[index]["id"],
                                ),
                            settings: RouteSettings(
                              arguments: todos[index],
                            )));
                  },
                  leading: Image(
                      width: 100,
                      height: 300,
                      fit: BoxFit.fitHeight,
                      image: NetworkImage(
                        todos[index]['image'],
                      )),
                  title: Text(todos[index]['title']),
                  subtitle: Text(todos[index]['price'].toString()),
                )),
              );
            }),
      ),
    );
  }
}

class ProductDetail extends StatefulWidget {
  final int id;
  const ProductDetail({super.key, required this.id});

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  late SharedPreferences press;
  static const String keyone = 'PRICEKEY';
  static const String keytwo = 'COUNTKEY';
  static const String keythree = 'TitleKey';
  static const String keyfour = 'KEYFOUR';
  late double _totalprice = 0.0;
  int _countOne = 0;

  @override
  void initState() {
    super.initState();
    getValue(widget.id);
  }

  int _counter = 0;

  void _noticounone() {
    _countOne++;
  }

  void _addCount() {
    setState(() {
      _counter++;
    });
  }

  void _minus(int num1, double num2) {
    if (num1 <= 1) {
      setState(() {
        _counter = 0;
        _totalprice = 0;
      });
    } else {
      setState(() {
        _counter--;
        _totalprice = num2 / _counter;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> productDetails =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    double pPrice = productDetails['price'].toDouble();
    final int mainID = widget.id;
    final String imageUrl = productDetails['image'];
    final String imgTitle = productDetails['title'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple[200],
        title: Text('Product Detail'),
        actions: [
          Stack(children: [
            Positioned(
              child: Container(
                child: IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Shopping(),
                          ));
                    },
                    icon: Icon(
                      Icons.shopping_cart,
                      size: 40,
                    )),
              ),
            ),
            Positioned(
              left: 30,
              child: Container(
                alignment: Alignment.center,
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                    color: Colors.red, borderRadius: BorderRadius.circular(20)),
                child: Text(
                  textAlign: TextAlign.center,
                  '$_countOne',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ]),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: 50,
            child: SizedBox(
              width: 200,
              height: 200,
              child: Image(image: NetworkImage(imageUrl)),
            ),
          ),
          const Positioned(
              top: 280,
              left: 50,
              child: Text(
                'Detail',
                style: TextStyle(fontSize: 30),
              )),
          Positioned(
              top: 50,
              left: 200,
              child: Text(
                'Price : $pPrice',
                style: TextStyle(fontSize: 20),
              )),
          Positioned(
              top: 90,
              left: 200,
              child: Text(
                'Total Price : $_totalprice',
                style: TextStyle(fontSize: 20),
              )),
          Positioned(
            top: 350,
            child: SizedBox(width: 400, child: Text(imgTitle)),
          ),
          Positioned(
            top: 120,
            left: 240,
            child: Row(
              children: [
                IconButton(
                    onPressed: () {
                      _addCount();
                      setState(() {
                        _totalprice = pPrice * _counter;
                      });
                    },
                    icon: Icon(Icons.add_circle_outlined)),
                Text('$_counter'),
                IconButton(
                    onPressed: () {
                      setState(() {
                        _minus(_counter, pPrice);
                      });
                    },
                    icon: Icon(Icons.remove_circle))
              ],
            ),
          ),
          Positioned(
              top: 200,
              left: 210,
              child: Column(children: [
                ElevatedButton.icon(
                    onPressed: () async {
                      final SharedPreferences press =
                          await SharedPreferences.getInstance();
                      setState(() {
                        _noticounone();
                      });
                      await press.setInt(keytwo, _countOne);
                      print(_countOne);

                      List prev =
                          await jsonDecode(press.getString(keyone) ?? "[]");

                      ItemModel curr = ItemModel(
                          id: '$mainID',
                          img: imageUrl,
                          title: imgTitle,
                          price: pPrice,
                          count: _counter);

                      if (prev.isEmpty) prev.add(curr.toJson());

                      for (int i = 0; i < prev.length; i++) {
                        if (prev[i]["id"] == curr.id) {
                          prev[i] = curr.toJson();
                        } else {
                          prev.add(curr.toJson());
                        }
                      }

                      print(prev);
                      await press.setString(keyone, jsonEncode(prev));
                    },
                    icon: Icon(Icons.shopping_cart),
                    label: Text('Add To Shop Cart')),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton.icon(
                    onPressed: () async {
                      press.remove(keyone);
                      press.remove(keyfour);
                    },
                    icon: Icon(Icons.payment),
                    label: Text('Buy Now')),
              ]))
        ],
      ),
    );
  }

  // void getValue(int id) async {
  //   press = await SharedPreferences.getInstance();

  //   String? jsonString = press.getString(keyone);
  //   if (jsonString != null) {
  //     Map<String, dynamic> data = jsonDecode(jsonString);
  //     setState(() {
  //       _countOne = press.getInt(keytwo) ?? 0;
  //       print(_countOne);
  //       _totalprice = data["$id"] is double ? data["$id"] : 0.0;
  //     });
  //   }
  // }
  void getValue(int id) async {
    press = await SharedPreferences.getInstance();

    String? jsonString = press.getString(keyone);
    if (jsonString != null) {
      List<dynamic> dataList = jsonDecode(jsonString);
      setState(() {
        _countOne = press.getInt(keytwo) ?? 0;
        print(_countOne);
        for (var item in dataList) {
          if (item['id'] == id.toString()) {
            _totalprice = item['price'].toDouble() * item['count'];
            break;
          }
        }
      });
    }
  }
}

class Shopping extends StatefulWidget {
  const Shopping({super.key});

  @override
  State<Shopping> createState() => _ShoppingState();
}

class _ShoppingState extends State<Shopping> {
  static const String keyfour = 'KEYFOUR';
  static const String keyone = 'PRICEKEY';

  SharedPreferences? press;
  late double totalPriceone;
  late int totalPricetwo;
  List<ItemModel>? items;
  double mainone(double num, int num2) {
    totalPriceone = num * num2;
    return totalPriceone;
  }

  @override
  void initState() {
    super.initState();
    getValues();
  }

  int _noticounter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
          itemCount: items?.length ?? 0,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                leading: SizedBox(
                  width: 200,
                  height: 50,
                  child: Image(
                      width: 100,
                      height: 300,
                      fit: BoxFit.fitHeight,
                      image: NetworkImage(items?[index].img ?? "")),
                ),
                title: Text(items?[index].title ?? ""),
                subtitle: Text(
                    'Total Price : ${items![index].count * items![index].price}'),
                trailing: IconButton(
                    onPressed: () async {
                      for (int i = 0; i < items!.length; i++) {
                        if (items![i].id == items![index].id) {
                          items!.remove(items![i]);

                          final result = items!.map((e) => e.toJson()).toList();
                          await press!.setString(keyone, jsonEncode(result));
                          
                          setState(() {
                            
                          });
                        } else {}
                      }
                    },
                    icon: Icon(Icons.delete)),
              ),
            );
          }),
    );
  }

  void getValues() async {
    press = await SharedPreferences.getInstance();

    String? jsonString = await press!.getString(keyone);
    if (jsonString != null) {
      List<dynamic> decodedJson = jsonDecode(jsonString);
      print(decodedJson);
      items = decodedJson.map((e) => ItemModel.fromJson(e)).toList();
    }

    setState(() {
      _noticounter = press!.getInt(keyfour) ?? 0;
    });
  }
}

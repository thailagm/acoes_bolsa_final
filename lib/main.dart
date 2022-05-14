import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request =
    "https://api.hgbrasil.com/finance/stock_price?key=ac9f5d99&symbol=";

void main() async {
  runApp(MaterialApp(
    home: MyHomePage(),
    theme: ThemeData(
        hintColor: Colors.pink.shade200, primaryColor: Colors.pink.shade200),
  ));
}

Future<Map> getData(symbol) async {
  http.Response response = await http.get(Uri.parse(request + symbol));
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load post');
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController symbolController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController updateController = TextEditingController();

  String _symbol = "";
  String _name = "";
  String _price = "";
  String _update = "";

  void _consultar() {
    print(request + symbolController.text);
    _symbol = symbolController.text;
    getData(_symbol);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("\$ Ações na bolsa \$"),
          centerTitle: true,
          backgroundColor: Colors.pink.shade200),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SingleChildScrollView(
              padding: EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Icon(Icons.ssid_chart,
                      size: 150.0, color: Colors.pink.shade100),
                  buildTextFormField("Código:", "", symbolController),
                  ElevatedButton(
                    onPressed: () {
                      _consultar();
                      setState(() {
                        //print("teste");
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.pink.shade300),
                    ),
                    child: Text(
                      "Consultar",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25.0,
                          fontStyle: FontStyle.italic),
                    ),
                  ),
                  buildFutureBuilder(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextFormField(
      String label, String prefix, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.pink.shade200),
          border: OutlineInputBorder(),
          prefixText: "$prefix "),
      style: TextStyle(color: Colors.pink.shade200, fontSize: 25.0),
      //keyboardType: TextInputType.numberWithOptions(decimal: true),
    );
  }

  buildFutureBuilder() {
    return FutureBuilder<Map>(
        future: getData(_symbol),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.active:
            case ConnectionState.waiting:
              return Center(
                  child: Text(
                "Carregando dados...",
                style: TextStyle(color: Colors.pink.shade200, fontSize: 25.0),
                textAlign: TextAlign.center,
              ));
            default:
              if (snapshot.hasError) {
                return Center(
                    child: Text(
                  "Erro ao carregar dados...",
                  style: TextStyle(color: Colors.red.shade400, fontSize: 25.0),
                  textAlign: TextAlign.center,
                ));
              } else {
                _name =
                    snapshot.data!["results"][_symbol.toUpperCase()]["name"];
                _price = (snapshot.data!["results"][_symbol.toUpperCase()]
                        ["price"])
                    .toString();
                _update = (snapshot.data!["results"][_symbol.toUpperCase()]
                        ["updated_at"])
                    .toString();

                nameController.text = _name;
                priceController.text = _price;
                print(_name);
                print(_price);
                print(_update);

                return Center(
                  child: Column(children: <Widget>[
                    Divider(),
                    Text(
                      ("Nome: $_name"),
                      style: TextStyle(
                        color: Colors.pink.shade300,
                        fontSize: 25,
                      ),
                    ),
                    Divider(),
                    Text(
                      ("Preço: R\$$_price"),
                      style: TextStyle(
                        color: Colors.pink.shade300,
                        fontSize: 25,
                      ),
                    ),
                    Divider(),
                    Text(
                      ("Atualizado em: $_update"),
                      style: TextStyle(
                        color: Colors.pink.shade300,
                        fontSize: 20,
                      ),
                    ),
                  ]),
                );
              }
          }
        });
  }
}

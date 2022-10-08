import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request =
    "https://api.hgbrasil.com/finance?format=json-cors&key=efe1904a";

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(hintColor: Colors.amber, primaryColor: Colors.amber),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(Uri.parse(request));
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final dolarController = TextEditingController();
  final euroController = TextEditingController();
  final realController = TextEditingController();

  String _mensagemConversao = "Status da Conversão: ";
  
  void _alterarMensagemConversao(String texto){
    setState(() {
      _mensagemConversao = "Status da Conversão: ";
      if(texto.isNotEmpty){
        _mensagemConversao += texto;
      }  
    });

  }

  double dolar = 0;
  double euro = 0;

  void _converterReal(String valor) {
    if (valor.isEmpty) {
      _limparCampos();
      return;
    }
    _alterarMensagemConversao("Real convertido para dólar e euro");
    double real = double.parse(valor);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
    
  }

  void _converterDolar(String valor) {
    if (valor.isEmpty) {
      _limparCampos();
      return;
    }
    _alterarMensagemConversao("Dólar convertido para real e euro");
    double dolar = double.parse(valor);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _converterEuro(String valor) {
    if (valor.isEmpty) {
      _limparCampos();
      return;
    }
    _alterarMensagemConversao("Euro convertido para real e dólar");
    double euro = double.parse(valor);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  void _limparCampos() {
    _alterarMensagemConversao("");
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            title: const Text("\$ Conversor de Moedas by Cleiane \$"),
            centerTitle: true,
            backgroundColor: Colors.amber),
        body: FutureBuilder<Map>(
            future: getData(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.active:
                case ConnectionState.waiting:
                  return const Center(
                      child: Text(
                    "Carregando dados...",
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ));
                default:
                  if (snapshot.hasError) {
                    return const Center(
                        child: Text(
                      "Erro ao carregar dados...",
                      style: TextStyle(color: Colors.amber, fontSize: 25.0),
                      textAlign: TextAlign.center,
                    ));
                  } else {

                    dolar = snapshot.data?["results"]["currencies"]["USD"]["buy"];
                    euro = snapshot.data?["results"]["currencies"]["EUR"]["buy"];

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          const Icon(Icons.monetization_on,
                              size: 150.0, color: Colors.amber),
                          buildTextFormField(
                              "Reais", "R\$", realController, _converterReal),
                          const Divider(),
                          buildTextFormField(
                              "Dólar", "US\$", dolarController, _converterDolar),
                          const Divider(),
                          buildTextFormField(
                              "Euro", "EUR", euroController, _converterEuro),
                          Text(
                          _mensagemConversao,
                          style: const TextStyle(
                              color: Color.fromARGB(255, 114, 227, 255),
                              fontSize: 20),
                        )
                        ],
                      ),
                    );
                  }
              }
            }));
  }

  Widget buildTextFormField(String label, String prefix,
      TextEditingController controller, Function metodoControllerCampo) {
    return TextField(
      onSubmitted: (entradaCampo) {
        metodoControllerCampo(entradaCampo);
      },
      controller: controller,
      decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.amber),
          border: const OutlineInputBorder(),
          prefixText: "$prefix "),
      style: const TextStyle(color: Colors.amber, fontSize: 25.0),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
  }
}
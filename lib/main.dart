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

Future<Map> getClima() async {
  http.Response respostaClima = await http.get(Uri.parse(
      "https://api.hgbrasil.com/weather?format=json-cors&key=efe1904a&user_ip=remote"));
  return json.decode(respostaClima.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final dolarController = TextEditingController();
  final euroController = TextEditingController();
  final realController = TextEditingController();

  double dolar = 0;
  double euro = 0;
  String cidade = "";

  void _converterReal(String valor) {
    if (valor.isEmpty) {
      _limparCampos();
      return;
    }
    double real = double.parse(valor);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _converterDolar(String valor) {
    if (valor.isEmpty) {
      _limparCampos();
      return;

    } 
    double dolar = double.parse(valor);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);

  }

  void _converterEuro(String valor) {
    if (valor.isEmpty) {
      _limparCampos();
      return;
    }

    double euro = double.parse(valor);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  void _limparCampos() {
    realController.clear();
    dolarController.clear();
    euroController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: const Text("\$ Conversor de Moedas by Cleiane \$"),
          centerTitle: true,
          backgroundColor: Colors.amber),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder<Map>(
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
                        dolar = snapshot.data?["results"]["currencies"]["USD"]
                            ["buy"];
                        euro = snapshot.data?["results"]["currencies"]["EUR"]
                            ["buy"];

                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              const Icon(Icons.monetization_on,
                                  size: 150.0, color: Colors.amber),
                              buildTextFormField("Reais", "R\$", realController,
                                  _converterReal),
                              const Divider(),
                              buildTextFormField("Dólar", "US\$",
                                  dolarController, _converterDolar),
                              const Divider(),
                              buildTextFormField("Euro", "EUR", euroController,
                                  _converterEuro),
                            ],
                          ),
                        );
                      }
                  }
                }),
            FutureBuilder<Map>(
                future: getClima(),
                builder: (context, snapshot2) {
                  if (!(snapshot2.hasError)) {
                    
                    if(snapshot2.data?["results"]["city"] != null){
                      cidade = snapshot2.data?["results"]["city"];
                    }
                    int temp = 0;
                    if(snapshot2.data?["results"]["city"] != null){
                      temp = snapshot2.data?["results"]["temp"];
                    }
                    String? hora = snapshot2.data?["results"]["time"];
                    String recomendacao = "";
                    if (temp <= 22) {
                      recomendacao = "Melhor se agasalhar!";
                    } else {
                      recomendacao = "Melhor vestir uma roupa leve!";
                    }
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                      Text(
                        "Você está em: ${cidade}",
                        style: TextStyle(color: Colors.blue, fontSize: 20.0),
                      ),
                      Text(
                        "São ${hora} e está fazendo ${temp} graus",
                        style: TextStyle(color: Colors.blue, fontSize: 20.0),
                      ),
                      Text(
                        recomendacao,
                        style: TextStyle(color: Colors.blue, fontSize: 20.0),
                      ),
                    ]);
                  } else {
                    return Text("Ocorreu um erro",
                        style: TextStyle(color: Colors.blue, fontSize: 20.0));
                  }
                }),
          ],
        ),
      ),
    );
  }

  Widget buildTextFormField(String label, String prefix,
      TextEditingController controller, Function metodoControllerCampo) {
    return TextField(
      onChanged: (entradaCampo) {       
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

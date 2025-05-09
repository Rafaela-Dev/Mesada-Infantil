import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class telaMesada extends StatefulWidget {
  Map<String, dynamic> dados;

  telaMesada(this.dados, {super.key});

  @override
  State<telaMesada> createState() => _telaMesadaState();
}

class _telaMesadaState extends State<telaMesada> {
  @override
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  TextEditingController addMotivoMesada = TextEditingController();
  TextEditingController addValorMesada = TextEditingController();

  Future<QuerySnapshot<Map<String, dynamic>>> getDadosMesada() async {
    return await firebaseFirestore
        .collection('usuarios')
        .doc(firebaseAuth.currentUser!.uid)
        .collection('filhos')
        .doc(widget.dados['nome'])
        .collection('mesada')
        .orderBy('data')
        .get();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getTotal() {
    return firebaseFirestore
        .collection('usuarios')
        .doc(firebaseAuth.currentUser!.uid)
        .collection('filhos')
        .doc(widget.dados['nome'])
        .snapshots();
  }

  var verificaTotal = (valor, modo) {
      if (valor < 0) {
        return Colors.red;
      } else if (valor >= 0 && modo == true) {
        return Colors.white;
      } else {
        return Colors.black;
      }
    };

  var corFundo = (tipo) {
    if (tipo == 'despesa') {
      return Colors.red;
    } else {
      return Colors.green;
    }
  };

  void addValores(String tipo) {
    String text = '';
    if (tipo == 'receita') {
      text = 'Adicionar Mesada';
    } else if (tipo == 'despesa') {
      text = 'Retirar Mesada';
    }
    ;

    var colorDialog = (tipo) {
      if (tipo == 'receita') {
        return Color.fromARGB(255, 136, 194, 241);
      } else {
        return Color.fromARGB(255, 255, 227, 225);
      }
    };

    double padding = 5;
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              backgroundColor: colorDialog(tipo),
              title: Text('$text'),
              actions: <Widget>[
                TextFormField(
                  keyboardType: TextInputType.text,
                  controller: addMotivoMesada,
                  decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: "Motivo",
                      border:
                          OutlineInputBorder(borderSide: BorderSide(width: 1))),
                ),
                Padding(padding: EdgeInsets.all(padding)),
                TextFormField(
                  keyboardType: TextInputType.number,
                  controller: addValorMesada,
                  decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: "Valor",
                      border:
                          OutlineInputBorder(borderSide: BorderSide(width: 1))),
                ),
                Padding(padding: EdgeInsets.all(padding)),
                Center(
                  child: TextButton(
                      style: TextButton.styleFrom(
                          textStyle: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.04),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.zero))),
                      onPressed: () {
                        Navigator.pop(context, 'Cancelar');
                        addMotivoMesada.text = "";
                        addMotivoMesada.text = "";
                      },
                      child: const Text(
                        'Cancelar',
                      )),
                ),
                Padding(padding: EdgeInsets.all(padding)),
                Center(
                  child: TextButton(
                      style: TextButton.styleFrom(
                          textStyle: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.04),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.zero))),
                      onPressed: () async {
                        String motivo = addMotivoMesada.text;
                        num valor = double.parse(addValorMesada.text);
                        String uid = firebaseAuth.currentUser!.uid;
                        if (tipo == 'despesa') valor = valor * (-1);
                        //adicionar no banco o tipo receita
                        firebaseFirestore
                            .collection('usuarios')
                            .doc(uid)
                            .collection('filhos')
                            .doc(widget.dados['nome'])
                            .collection('mesada')
                            .doc()
                            .set({
                          'data': DateTime.now(),
                          'motivo': motivo,
                          'tipo': tipo,
                          'valor': valor
                        }).whenComplete(() async {
                          final documentoFilho = await firebaseFirestore
                              .collection('usuarios')
                              .doc(uid)
                              .collection('filhos')
                              .doc(widget.dados['nome'])
                              .get();
                          num valorMesada = documentoFilho.data()!['valor'];
                          valorMesada += valor;
                          firebaseFirestore
                              .collection('usuarios')
                              .doc(uid)
                              .collection('filhos')
                              .doc(widget.dados['nome'])
                              .update({'valor': valorMesada});
                        });
                        Navigator.pop(context, 'cancelar');
                        addMotivoMesada.text = "";
                        addValorMesada.text = "";
                        setState(() {});
                      },
                      child: Text('Enviar')),
                ),
              ],
            ));
  }

  var total = (dados) {
    return dados['valor'];
  };

  late SharedPreferences _prefs;
  String dropValue = 'normal';

  double getFont() {
    switch (dropValue) {
      case 'pequena':
        return 20.0;
      case 'normal':
        return 30.0;
      case 'grande':
        return 40.0;
      default:
        return 30.0;
    }
  }

  @override
  void initState() {
    super.initState();
    _read();
  }

  _read() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      dropValue = _prefs.getString('tamanhoFonte') ?? "normal"; // get the value
      modoDark = _prefs.getBool('dark') ?? false;
      modoNormal = _prefs.getBool('modoNormal') ?? true;
    });
  }

  var modoDark = false;
  var modoNormal = true;

  var corDeFundo = (normal, dark) {
    if (normal == true) {
      return Colors.white;
    } else if (dark == true) {
      return Colors.black;
    }
  };

  var corNome = (normal, dark) {
    if (normal == true) {
      return Colors.black;
    } else if (dark == true) {
      return Colors.white;
    }
  };

  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: corDeFundo(modoNormal, modoDark),
        appBar: AppBar(
          title:  Text(widget.dados['nome']),
          actions: [
            ToggleButtons(
              children: [Text('Modo Claro'), Text('Modo Escuro')],
              isSelected: [modoNormal, modoDark],
              onPressed: ((index) {
                if (index == 0) {
                  modoDark = false;
                  modoNormal = true;
                  _prefs.setBool('modoNormal', true);
                  _prefs.setBool('dark', false);
                  setState(() {});
                } else if (index == 1) {
                  modoDark = true;
                  modoNormal = false;
                  _prefs.setBool('modoNormal', false);
                  _prefs.setBool('dark', true);
                  setState(() {});
                }
              }),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.05,
            ),
            DropdownButton<String>(
                value: dropValue,
                items: ['pequena', 'normal', 'grande']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    dropValue = value!;
                    _prefs.setString('tamanhoFonte', value!);
                  });
                })
          ],
        ),
        body: FutureBuilder(
            future: getDadosMesada(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.active:
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                case ConnectionState.done:
                  final dadosMesada = snapshot.data!.docs;
                  return ListView.separated(
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(),
                    itemCount: dadosMesada.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Text(
                                  dadosMesada[index].data()['motivo'],
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    color: corFundo(
                                        dadosMesada[index].data()['tipo']),
                                    fontSize: getFont(),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                    "R\$" +
                                        dadosMesada[index]
                                            .data()['valor']
                                            .toString(),
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                        fontSize: getFont(),
                                        color: corFundo(
                                            dadosMesada[index].data()['tipo'])))
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  );
              }
            }),
        bottomNavigationBar: BottomAppBar(
          color: corDeFundo(modoNormal, modoDark),
          height: MediaQuery.of(context).size.height * 0.20,
          child: Column(
            children: [
              StreamBuilder(
                  stream: getTotal(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Container();
                    } else {
                      final dadosMesada = snapshot.data;
                      return SizedBox(
                        width: double.infinity,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('TOTAL',
                                    style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.05,
                                      color: verificaTotal(total(dadosMesada), modoDark),
                                    )),
                                Text(
                                  'R\$' +
                                      total(
                                        dadosMesada,
                                      ).toString(),
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.05,
                                    color: verificaTotal(total(dadosMesada), modoDark),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      );
                    }
                  }),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.45,
                    height: MediaQuery.of(context).size.height * 0.1,
                    color: Colors.red,
                    child: TextButton(
                      onPressed: () => addValores('despesa'),
                      child: Text("-",
                          style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.09)),
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.zero)),
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.45,
                    height: MediaQuery.of(context).size.height * 0.1,
                    color: Colors.blue,
                    child: TextButton(
                      onPressed: () => addValores('receita'),
                      child: Text(
                        "+",
                        style: TextStyle(
                            fontSize:
                                MediaQuery.of(context).size.height * 0.09),
                      ),
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.zero)),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ));
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Controle_de_mesada/views/telaMesada.dart';
import 'package:shared_preferences/shared_preferences.dart';

class telaInicialState extends StatefulWidget {
  telaInicialState({super.key});

  @override
  State<telaInicialState> createState() => _telaInicialStateState();
}

class _telaInicialStateState extends State<telaInicialState> {
  @override
  TextEditingController nomeCrianca = TextEditingController();

  TextEditingController valorRecebe = TextEditingController();

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> getChildren() {
    return firebaseFirestore
        .collection('usuarios')
        .doc(firebaseAuth.currentUser!.uid)
        .collection('filhos')
        .snapshots();
  }

  late SharedPreferences _prefs;
  String dropValue = 'normal';

  var corFundo = (tipo) {
    if (tipo == 'despesa') {
      return Colors.red;
    } else {
      return Colors.green;
    }
  };

  var corFundoInicial = (valor) {
    if (valor < 0) {
      return Colors.red;
    } else {
      return Colors.green;
    }
  };

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

  var modoDark = false;
  var modoNormal = true;

  _read() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      dropValue = _prefs.getString('tamanhoFonte') ?? "normal"; // get the value
      modoDark = _prefs.getBool('dark') ?? false;
      modoNormal = _prefs.getBool('modoNormal') ?? true;
    });
  }

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

  var corBorda = (normal, dark) {
    if (normal == true) {
      return Offset(0, 6);
    } else if (dark == true) {
      return Offset(0, 1);
    }
  };

  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: corDeFundo(modoNormal, modoDark),
        appBar: AppBar(
          title: Text("Controle de mesada"),
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
        floatingActionButton: FloatingActionButton(
          onPressed: () => showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('Criar'),
              content: const Text('Criar tabela de mesada'),
              actions: <Widget>[
                TextFormField(
                  keyboardType: TextInputType.name,
                  controller: nomeCrianca,
                  maxLength: 15,
                  decoration: const InputDecoration(
                      labelText: "",
                      hintText: "Digite o nome da criança",
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1),
                      )),
                ),
                TextButton(
                  onPressed: () async {
                    String nome = nomeCrianca.text;
                    String uid = firebaseAuth.currentUser!.uid;
                    firebaseFirestore
                        .collection('usuarios')
                        .doc(uid)
                        .collection('filhos')
                        .doc(nome)
                        .set({"nome": nome, "valor": 0.0});
                    setState(() {});
                    Navigator.pop(context, '');
                    nomeCrianca.text = "";
                  },
                  child: const Text('Criar'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context, 'Cancelar');
                    nomeCrianca.text = "";
                  },
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ),
          backgroundColor: Colors.red,
          child: Text("+"),
        ),
        body: StreamBuilder(
            stream: getChildren(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              } else {
                final dadosFilhos = snapshot.data!.docs;
                return ListView.separated(
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(color: Colors.white),
                  itemCount: dadosFilhos.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                        margin: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40.0),
                          color: corDeFundo(modoNormal, modoDark),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 1.0,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Container(
                            height: MediaQuery.of(context).size.height * 0.1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Text(dadosFilhos[index].data()['nome'],
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontSize: getFont(),
                                            color:
                                                corNome(modoNormal, modoDark))),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      "R\$" +
                                          dadosFilhos[index]
                                              .data()['valor']
                                              .toString(),
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                          fontSize: getFont(),
                                          color: corFundoInicial(
                                              dadosFilhos[index]
                                                  .data()['valor'])),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        telaMesada(dadosFilhos[index].data())));
                          },
                        ));
                  },
                );
              }
            }));
  }
}

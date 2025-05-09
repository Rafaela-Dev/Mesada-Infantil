import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Controle_de_mesada/views/telaInicial.dart';

class Cadastro extends StatefulWidget {
  const Cadastro({super.key});

  @override
  State<Cadastro> createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  TextEditingController emailUsuario = TextEditingController();
  TextEditingController nome = TextEditingController();
  TextEditingController senha = TextEditingController();
  TextEditingController confSenha = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String emailUser = "";
  String senhaUser = "";
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: const Color.fromRGBO(5, 118, 255, 100),
          height: MediaQuery.sizeOf(context).height,
          padding: const EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: Center(
              child: Column(
                children: [
                  Image.asset(
                    "images/LOGO.png",
                    width: MediaQuery.of(context).size.width * 0.3,
                    height: MediaQuery.of(context).size.height * 0.3,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.name,
                    maxLength: 100,
                    controller: nome,
                    decoration: const InputDecoration(
                      labelText: "Nome",
                      hintText: "Digite seu nome",
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 1,
                        ),
                      ),
                    ),
                    validator: (texto) {
                      if (texto == null || texto.length <= 10) {
                        return "O nome necessita ter 10 ou mais caracteres";
                      } else {
                        return null;
                      }
                    },
                  ),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: emailUsuario,
                    maxLength: 100,
                    decoration: const InputDecoration(
                        labelText: "E-mail",
                        hintText: "Digite um e-mail",
                        border: OutlineInputBorder(
                          borderSide: BorderSide(width: 1),
                        )),
                    validator: (texto) {
                      if (texto == null ||
                          (!texto.contains("@") || !texto.contains(".com"))) {
                        return "E-mail incompleto";
                      } else {
                        emailUser = emailUsuario.text;
                        return null;
                      }
                    },
                  ),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    controller: senha,
                    maxLength: 20,
                    decoration: const InputDecoration(
                        labelText: "Senha",
                        hintText: "Crie uma senha",
                        border: OutlineInputBorder(
                          borderSide: BorderSide(width: 1),
                        )),
                    validator: (texto) {
                      if (texto == null || texto.length < 6) {
                        return "Senha muito curta";
                      } else {
                        return null;
                      }
                    },
                  ),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    controller: confSenha,
                    maxLength: 20,
                    decoration: const InputDecoration(
                        labelText: "Confirmar senha",
                        hintText: "Confirme a senha criada",
                        border: OutlineInputBorder(
                          borderSide: BorderSide(width: 1),
                        )),
                    validator: (texto) {
                      if (texto == "") {
                        return "Confirme a sua senha";
                      } else if (texto != senha.text) {
                        return "Senhas diferentes";
                      } else {
                        return null;
                      }
                    },
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: TextButton(
                        style: TextButton.styleFrom(
                            backgroundColor:
                                const Color.fromRGBO(9, 51, 102, 40)),
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            if (senha.value == confSenha.value) {
                              print("senhas correta");
                              senhaUser = senha.text;
                            }
                            await firebaseAuth
                                .createUserWithEmailAndPassword(
                                    email: emailUser, password: senhaUser)
                                .then((value) {
                              // ignore: unnecessary_null_comparison
                            });
                            await firebaseAuth
                                .signInWithEmailAndPassword(
                                    email: emailUser, password: senhaUser)
                                .then((usuario) {
                              if (usuario != null) {
                                String uidUSer = usuario.user!.uid;
                                String nomeFinal = nome.text;
                                firebaseFirestore
                                    .collection('usuarios')
                                    .doc(uidUSer)
                                    .set({
                                  'nome': nomeFinal,
                                  'tamanhoFonte': "normal"
                                });
                              }
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => telaInicialState()));
                              ;
                            });
                          }
                        },
                        child: const Text("Criar conta",
                            style: TextStyle(color: Colors.white))),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

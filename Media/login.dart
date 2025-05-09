import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Controle_de_mesada/views/loginCrianca.dart';
import 'package:Controle_de_mesada/views/cadastro.dart';
import 'package:Controle_de_mesada/views/telaInicial.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController email = TextEditingController();
  TextEditingController senha = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;


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
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: MediaQuery.of(context).size.height * 0.5,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    maxLength: 100,
                    controller: email,
                    decoration: const InputDecoration(
                      labelText: "E-mail",
                      hintText: "Digite seu e-mail",
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 1,
                        ),
                      ),
                    ),
                    validator: (texto) {
                      if (texto == null ||
                          (!texto.contains("@") && !texto.contains(".com"))) {
                        return "Caractere @ obrigatório";
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    controller: senha,
                    obscureText: true,
                    maxLength: 20,
                    decoration: const InputDecoration(
                      labelText: "Senha",
                      hintText: "Digite sua senha",
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 1,
                        ),
                      ),
                    ),
                    validator: (texto) {
                      if (texto == null) {
                        return "senha obrigatoria";
                      } else if (texto.length < 8) {
                        return "senha muito curta";
                      } else {
                        return null;
                      }
                    },
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: TextButton(
                        style: TextButton.styleFrom(
                            backgroundColor:
                                const Color.fromRGBO(4, 82, 178, 70)),
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            await firebaseAuth
                                .signInWithEmailAndPassword(
                                    email: email.text, password: senha.text)
                                .then((usuario) {
                              // ignore: unnecessary_null_comparison
                              if (usuario != null) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => telaInicialState()));
                                // ignore: unnecessary_null_comparison
                              } else if (usuario == null) {
                                print("login errado");
                              }
                            });
                          }
                        },
                        child: const Text("Fazer Login",
                            style: TextStyle(color: Colors.white))),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(4, 82, 178, 70),
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const Cadastro()));
                      },
                      child: const Text(
                        "Criar conta",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
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

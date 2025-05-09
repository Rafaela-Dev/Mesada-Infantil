import 'package:flutter/material.dart';

class LoginCrianca extends StatefulWidget {
  const LoginCrianca({super.key});

  @override
  State<LoginCrianca> createState() => _LoginCriancaState();
}

class _LoginCriancaState extends State<LoginCrianca> {

  TextEditingController codigo = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child:Container(
          color: const Color.fromRGBO(5, 118, 255, 100),
          height: MediaQuery.sizeOf(context).height,
          padding: const EdgeInsets.all(16),
        child: Form(
          child: Center(
            child: Column(
              children: [
              Image.asset("images/LOGO.png", width: MediaQuery.of(context).size.width * 0.5, height: MediaQuery.of(context).size.height * 0.5,),
              TextFormField(
                keyboardType: TextInputType.number,
                maxLength: 6,
                controller: codigo,
                decoration: const InputDecoration(
                  labelText: "Código",
                  hintText: "Digite o código gerado",
                  border: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 1),),
                ),
              ),
              SizedBox(
                height:  MediaQuery.of(context).size.height * 0.05,
                width:  MediaQuery.of(context).size.width * 0.5,
                child: TextButton(onPressed: () {
                if (codigo.text == "123456"){
                  print("entrou");
                }else {
                  print("não entrou");
                }
              },
              style: TextButton.styleFrom(
                  backgroundColor: Color.fromRGBO(4, 82, 178, 70),
              ),
              // ignore: prefer_const_constructors
              child: Text("Fazer Login", style: TextStyle(color: Colors.white),) ),
              )
            ],
            ),
          ),
        ),
        ),
      ),
    );
  }
}
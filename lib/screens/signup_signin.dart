import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loginapp/services/firebase_methods.dart';
import 'package:loginapp/utils/app_routes.dart';

class SignUpSignIn extends StatefulWidget {
  const SignUpSignIn({Key? key}) : super(key: key);

  @override
  State<SignUpSignIn> createState() => _SignUpSignInPageState();
}

class _SignUpSignInPageState extends State<SignUpSignIn> {
  bool islogin = true;
  bool showPass = false;

  final displayName = TextEditingController();
  final email = TextEditingController();
  final senha = TextEditingController();
  final repsenha = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    checkAuthState();
  }

  void checkAuthState() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        print('User UID: ${user.uid}');
        Navigator.of(context).popAndPushNamed(AppRoutes.home);
      }
    });
  }

  register() async {
    await FirebaseMethods().register(email.text, senha.text);
  }

  login() async {
    await FirebaseMethods().login(email.text, senha.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.all(25),
          child: Column(
            children: [
              const Padding(padding: EdgeInsets.all(50)),
              Text(
                islogin == true ? 'Entrar' : 'Cadastrar',
                style: const TextStyle(fontSize: 32),
              ),
              const Padding(padding: EdgeInsets.all(70)),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (!islogin)
                      TextFormField(
                        controller: displayName,
                        decoration: const InputDecoration(labelText: 'Nome'),
                        textInputAction: TextInputAction.next,
                        validator: (_nome) {
                          final nome = _nome ?? '';
                          if (nome.trim().isEmpty) {
                            return 'Campo obrigatório.';
                          }
                          return null;
                        },
                      ),
                    TextFormField(
                      controller: email,
                      decoration: const InputDecoration(labelText: 'Email'),
                      textInputAction: TextInputAction.next,
                      validator: (_email) {
                        final email = _email ?? '';
                        if (email.trim().isEmpty) {
                          return 'Campo obrigatório.';
                        }
                        if (!email.trim().contains('@')) {
                          return 'Email inválido.';
                        }

                        return null;
                      },
                    ),
                    TextFormField(
                      validator: (_senha) {
                        final senha = _senha ?? '';
                        if (senha.trim().isEmpty) {
                          return 'Campo obrigatório.';
                        }
                        if (senha.trim().length < 6) {
                          return 'A senha precisa ter 6 caracteres.';
                        }

                        return null;
                      },
                      controller: senha,
                      decoration: InputDecoration(
                          labelText: 'Senha',
                          suffixIcon: IconButton(
                            icon: Icon(
                              showPass
                                  ? Icons.remove_red_eye
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                showPass = !showPass;
                              });
                            },
                          )),
                      obscureText: !showPass,
                      textInputAction: TextInputAction.next,
                    ),
                    if (!islogin)
                      TextFormField(
                        validator: (_repsenha) {
                          final repsenha = _repsenha ?? '';
                          if (repsenha.trim().isEmpty) {
                            return 'Senha é obrigatório.';
                          }
                          if (repsenha.trim().length < 6) {
                            return 'A senha precisa ter 6 caracteres.';
                          }
                          if (repsenha != senha.text) {
                            return 'As senhas precisam ser iguais.';
                          }
                          return null;
                        },
                        controller: repsenha,
                        decoration: InputDecoration(
                          labelText: 'Confirmar senha',
                          suffixIcon: IconButton(
                            icon: Icon(
                              showPass
                                  ? Icons.remove_red_eye
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                showPass = !showPass;
                              });
                            },
                          ),
                        ),
                        obscureText: !showPass,
                        textInputAction: TextInputAction.next,
                      ),
                    Row(
                      children: [
                        const Spacer(flex: 1),
                        if (islogin == true)
                          TextButton(
                            child: const Text('Esqueceu sua senha?'),
                            onPressed: () {},
                          ),
                      ],
                    ),
                    const Padding(padding: EdgeInsets.all(10)),
                    Center(
                      child: ElevatedButton(
                        style: ButtonStyle(
                            minimumSize: MaterialStateProperty.all(
                                const Size.fromHeight(50)),
                            backgroundColor:
                                MaterialStateProperty.all(Colors.blue)),
                        child: Text(
                          islogin == false ? 'Criar conta' : 'Login',
                          style: const TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            if (!islogin) {
                              register();
                              Navigator.of(context)
                                  .popAndPushNamed(AppRoutes.home);
                            } else {
                              login();
                              Navigator.of(context)
                                  .popAndPushNamed(AppRoutes.home);
                            }
                          }
                        },
                      ),
                    ),
                    const Padding(padding: EdgeInsets.all(10)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(islogin == true
                            ? 'Não tem uma conta?'
                            : 'Já tem conta?'),
                        TextButton(
                          child: Text(
                            islogin == true ? 'Inscreva-se!' : 'Voltar',
                            style: const TextStyle(color: Colors.blueAccent),
                          ),
                          onPressed: () {
                            setState(() {
                              islogin = !islogin;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

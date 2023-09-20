import 'package:chat_app/screens/auth_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final _firebase = FirebaseAuth.instance;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  String _emailText = '';
  String _passwordText = '';
  bool _hidePassword = true;
  String? _error;

  void _showLoginError(String? errorMessage) {
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage ?? 'Authentication failed'),
      ),
    );
  }

  void _onLogin() async {
    if (_loginFormKey.currentState!.validate()) {
      _loginFormKey.currentState!.save();
      /*This method will send a HTTP request to firebase*/
      try {
        await _firebase.signInWithEmailAndPassword(
          email: _emailText,
          password: _passwordText,
        );
      } on FirebaseAuthException catch (error) {
        if (error.code == 'invalid-email') {
          _showLoginError(error.message!);
        }

        if (error.code == 'user-disabled') {
          _showLoginError(error.message!);
        }

        if (error.code == 'user-not-found') {
          _showLoginError(error.message!);
        }

        if (error.code == 'wrong-password') {
          _showLoginError(error.message!);
        }

        _loginFormKey.currentState!.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 100.0,
          width: 100.0,
          alignment: Alignment.center,
          child: Image.asset(
            "assets/images/chat.png",
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 30.0),
        Container(
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.circular(20.0),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 16.0,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _loginFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    autocorrect: false,
                    textCapitalization: TextCapitalization.none,
                    maxLength: 100,
                    focusNode: _emailFocusNode,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      label: Text("Email"),
                      contentPadding: EdgeInsets.all(8.0),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        _error = "Email cannot be empty";
                        return _error;
                      }
                      if (value.length > 100) {
                        _error = "Email is too long";
                        return _error;
                      }
                      if (!RegExp(
                              r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
                          .hasMatch(value)) {
                        _error = 'Enter a valid email address';
                        return _error;
                      }
                      return null;
                    },
                    onFieldSubmitted: (value) {
                      FocusScope.of(context).requestFocus(_passwordFocusNode);
                    },
                    onSaved: (value) {
                      _emailText = value!;
                    },
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextFormField(
                          focusNode: _passwordFocusNode,
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            label: Text("Password"),
                            contentPadding: EdgeInsets.all(8.0),
                          ),
                          obscureText: _hidePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              _error = "Password cannot be empty";
                              return _error;
                            }
                            if (value.length < 8) {
                              _error =
                                  "Password should have 8 or more characters";
                              return _error;
                            }
                            if (value.length > 100) {
                              _error =
                                  "Password should have 100 or less characters";
                              return _error;
                            }
                            return null;
                          },
                          onFieldSubmitted: (value) {
                            if (_passwordFocusNode.hasFocus) {
                              FocusScope.of(context).unfocus();
                            }
                          },
                          onSaved: (value) {
                            _passwordText = value!;
                          },
                        ),
                      ),
                      TextButton(
                          onPressed: () {
                            setState(() {
                              _hidePassword = !_hidePassword;
                            });
                          },
                          child: _hidePassword == true
                              ? const Text("Show")
                              : const Text("Hide")),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: _onLogin,
                    child: const Text("Login"),
                  ),
                  const SizedBox(height: 20.0),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const AuthScreen(),
                          ),
                        );
                      });
                    },
                    child: const Text("Create an account"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

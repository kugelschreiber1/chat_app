import 'dart:io';

import 'package:chat_app/screens/login_screen.dart';
import 'package:chat_app/widgets/image_input.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _signupFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _usernameFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  String _emailText = '';
  String _usernameText = '';
  String _passwordText = '';
  bool _hidePassword = true;
  File? _selectedImage;
  String? _error;
  bool _isLogin = false;

  void _showSignupMessage(String? errorMessage) {
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

  void _onAddImage() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ImageInput(
        onGetImage: (image) {
          setState(() {
            _selectedImage = image;
          });
        },
      ),
    );
  }

  void _onSignup() async {
    final isValid = _signupFormKey.currentState!.validate();

    if (isValid) {
      _signupFormKey.currentState!.save();
      /*This method will send a HTTP request to firebase*/
      try {
        await _firebase.createUserWithEmailAndPassword(
          email: _emailText,
          password: _passwordText,
        );
      } on FirebaseAuthException catch (error) {
        if (error.code == 'email-already-in-use') {
          _showSignupMessage(error.message!);
        }

        if (error.code == 'invalid-email') {
          _showSignupMessage(error.message!);
        }

        if (error.code == 'operation-not-allowed') {
          _showSignupMessage(error.message!);
        }

        if (error.code == 'weak-password') {
          _showSignupMessage(error.message!);
        }

        _signupFormKey.currentState!.reset();
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String message = "Add Image";
    ImageProvider profilePicture =
        const AssetImage("assets/images/person_icon.png");

    if (_selectedImage != null) {
      profilePicture = FileImage(_selectedImage!);
      message = "Change Image";
    }

    Widget screenContent = Column(
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 50.0,
                  backgroundImage: profilePicture,
                ),
                const SizedBox(height: 16.0),
                ElevatedButton.icon(
                  onPressed: _onAddImage,
                  icon: const Icon(Icons.camera),
                  label: Text(message),
                ),
                Form(
                  key: _signupFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                          String email;

                          if (value == null || value.isEmpty) {
                            _error = "Email cannot be empty";
                            return _error;
                          }

                          email = value.trim();

                          if (email.length > 100) {
                            _error = "Email is too long";
                            return _error;
                          }
                          if (!RegExp(
                                  r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
                              .hasMatch(email)) {
                            _error = 'Enter a valid email address';
                            return _error;
                          }
                          return null;
                        },
                        onFieldSubmitted: (value) {
                          FocusScope.of(context)
                              .requestFocus(_usernameFocusNode);
                        },
                        onSaved: (value) {
                          _emailText = value!;
                        },
                      ),
                      const SizedBox(height: 10.0),
                      TextFormField(
                        autocorrect: false,
                        maxLength: 10,
                        focusNode: _usernameFocusNode,
                        controller: _usernameController,
                        keyboardType: TextInputType.name,
                        decoration: const InputDecoration(
                          label: Text("Username"),
                          contentPadding: EdgeInsets.all(8.0),
                        ),
                        validator: (value) {
                          String username;

                          if (value == null || value.isEmpty) {
                            _error = "Username cannot be empty";
                            return _error;
                          }
                          username = value.trim();

                          if (username.length < 3) {
                            _error = "Username is too short";
                            return _error;
                          }
                          if (username.length > 10) {
                            _error = "Username is too long";
                            return _error;
                          }
                          return null;
                        },
                        onFieldSubmitted: (value) {
                          FocusScope.of(context)
                              .requestFocus(_passwordFocusNode);
                        },
                        onSaved: (value) {
                          _usernameText = value!;
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
                                String password;

                                if (value == null || value.isEmpty) {
                                  _error = "Password cannot be empty";
                                  return _error;
                                }

                                password = value.trim();

                                if (password.length < 8) {
                                  _error =
                                      "Password should have 8 or more characters";
                                  return _error;
                                }
                                if (password.length > 100) {
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
                        onPressed: _onSignup,
                        child: const Text("Signup"),
                      ),
                      const SizedBox(height: 20.0),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isLogin = !_isLogin;
                          });
                        },
                        child: const Text("I already have an account"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    if (_isLogin) {
      screenContent = const LoginScreen();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).copyWith().scaffoldBackgroundColor,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 8.0,
          ),
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: screenContent,
          ),
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:chat_app/widgets/image_input.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _usernameFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  File? _selectedImage;
  String? _error;

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

  void _onSignup() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _formKey.currentState!.reset();
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

    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 8.0,
          ),
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Column(
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
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextFormField(
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
                                  FocusScope.of(context)
                                      .requestFocus(_usernameFocusNode);
                                },
                              ),
                              TextFormField(
                                maxLength: 10,
                                focusNode: _usernameFocusNode,
                                controller: _usernameController,
                                keyboardType: TextInputType.name,
                                decoration: const InputDecoration(
                                  label: Text("Username"),
                                  contentPadding: EdgeInsets.all(8.0),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    _error = "Username cannot be empty";
                                    return _error;
                                  }
                                  if (value.length < 3) {
                                    _error = "Username is too short";
                                    return _error;
                                  }
                                  if (value.length > 10) {
                                    _error = "Username is too long";
                                    return _error;
                                  }
                                  return null;
                                },
                                onFieldSubmitted: (value) {
                                  FocusScope.of(context)
                                      .requestFocus(_passwordFocusNode);
                                },
                              ),
                              TextFormField(
                                focusNode: _passwordFocusNode,
                                controller: _passwordController,
                                keyboardType: TextInputType.visiblePassword,
                                decoration: const InputDecoration(
                                  label: Text("Password"),
                                  contentPadding: EdgeInsets.all(8.0),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    _error = "Password cannot be empty";
                                    return _error;
                                  }
                                  if (value.length < 8) {
                                    _error = "Password is too short";
                                    return _error;
                                  }
                                  if (value.length > 100) {
                                    _error = "Password is too long";
                                    return _error;
                                  }
                                  return null;
                                },
                                onFieldSubmitted: (value) {
                                  FocusScope.of(context)
                                      .requestFocus(_passwordFocusNode);
                                },
                              ),
                              const SizedBox(height: 20.0),
                              ElevatedButton(
                                onPressed: _onSignup,
                                child: const Text("Signup"),
                              ),
                              const SizedBox(height: 20.0),
                              TextButton(
                                onPressed: () {},
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
            ),
          ),
        ),
      ),
    );
  }
}

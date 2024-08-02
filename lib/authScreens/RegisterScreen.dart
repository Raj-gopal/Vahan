import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vahan/authScreens/loginScreen.dart';
import 'package:vahan/screen/homepage.dart';
import 'package:vahan/services/auth.dart';
import 'package:vahan/utils/style.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobilenumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      String res = await AuthServices().signupUser(
        name: nameController.text,
        number: mobilenumberController.text,
        email: emailController.text,
        password: passwordController.text,
      );

      print('Registration result: $res'); // Debugging statement

      if (res == 'success') {
        setState(() {
          isLoading = true;
        });
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Homepage()),
              (Route<dynamic> route) => false,
        );

        print('Navigating to Homepage'); // Debugging statement
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: $res')),
        );
        print('Registration failed: $res'); // Debugging statement
      }
    } else {
      // If the form is not valid, reset the loading state
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const Text(
                  'Register',
                  style: TextStyle(
                    color: Color(0xff797979),
                    fontSize: 24,
                    fontFamily: 'Gelix',
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: nameController,
                  cursorColor: primarybuttonText,
                  style: const TextStyle(
                    color: Color(0xff797979),
                    fontSize: 18,
                    fontFamily: 'Gelix',
                  ),
                  decoration: InputDecoration(
                    focusColor: const Color(0xff797979),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    contentPadding: const EdgeInsets.only(
                        left: 24, right: 24, bottom: 20, top: 20),
                    hintText: 'Enter name',
                    hintStyle: const TextStyle(
                      color: Color(0xff797979),
                      fontSize: 18,
                      fontFamily: 'Gelix',
                    ),
                    filled: true,
                    fillColor: const Color(0xff242426),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: mobilenumberController,
                  keyboardType: TextInputType.phone,
                  cursorColor: primarybuttonText,
                  style: const TextStyle(
                    color: Color(0xff797979),
                    fontSize: 18,
                    fontFamily: 'Gelix',
                  ),
                  decoration: InputDecoration(
                    focusColor: const Color(0xff797979),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    contentPadding: const EdgeInsets.only(
                        left: 24, right: 24, bottom: 20, top: 20),
                    hintText: 'Enter mobile number',
                    hintStyle: const TextStyle(
                      color: Color(0xff797979),
                      fontSize: 18,
                      fontFamily: 'Gelix',
                    ),
                    filled: true,
                    fillColor: const Color(0xff242426),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your mobile number';
                    } else if (value.length != 10) {
                      return 'Please enter a valid 10-digit mobile number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  cursorColor: primarybuttonText,
                  style: const TextStyle(
                    color: Color(0xff797979),
                    fontSize: 18,
                    fontFamily: 'Gelix',
                  ),
                  decoration: InputDecoration(
                    focusColor: const Color(0xff797979),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    contentPadding: const EdgeInsets.only(
                        left: 24, right: 24, bottom: 20, top: 20),
                    hintText: 'Enter email',
                    hintStyle: const TextStyle(
                      color: Color(0xff797979),
                      fontSize: 18,
                      fontFamily: 'Gelix',
                    ),
                    filled: true,
                    fillColor: const Color(0xff242426),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  cursorColor: primarybuttonText,
                  style: const TextStyle(
                    color: Color(0xff797979),
                    fontSize: 18,
                    fontFamily: 'Gelix',
                  ),
                  decoration: InputDecoration(
                    focusColor: const Color(0xff797979),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    contentPadding: const EdgeInsets.only(
                        left: 24, right: 24, bottom: 20, top: 20),
                    hintText: 'Enter password',
                    hintStyle: const TextStyle(
                      color: Color(0xff797979),
                      fontSize: 18,
                      fontFamily: 'Gelix',
                    ),
                    filled: true,
                    fillColor: const Color(0xff242426),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    } else if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: isLoading ? null : register,
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: buttonColor,
                    ),
                    child: Center(
                      child: isLoading
                          ? CircularProgressIndicator(color: primarytextColor)
                          :  Text(
                        'Continue',
                        style: TextStyle(
                          color: primarytextColor,
                          fontSize: 20,
                          fontFamily: 'Gelix',
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account?',
                        style: TextStyle(
                          color: Color(0xff797979),
                          fontSize: 14,
                          fontFamily: 'Gelix',
                        ),
                      ),
                      Text(
                        '  Login',
                        style: TextStyle(
                          color: primarybuttonColor,
                          fontSize: 14,
                          fontFamily: 'Gelix',
                        ),
                      ),
                    ],
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

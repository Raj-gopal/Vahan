import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:country_picker/country_picker.dart';
import 'package:vahan/authScreens/RegisterScreen.dart';
import 'package:vahan/otp/otpscreen.dart';
import 'package:vahan/screen/homepage.dart';
import 'package:vahan/services/auth.dart';
import 'package:vahan/utils/style.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  List loginButtonData = [
    [AssetGen().google(height: 24), 'Google'],
    [AssetGen().apple(height: 24), 'Apple'],
    [AssetGen().facebook(height: 24), 'Facebook'],
    [AssetGen().mail(height: 24), 'Email']
  ];

  Future<void> login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      String res = await AuthServices().loginUser(
        email: emailController.text,
        password: passwordController.text,
      );

      setState(() {
        isLoading = false;
      });

      if (res == 'success') {
        setState(() {
          isLoading = true;
        });
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Homepage()),
              (Route<dynamic> route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: $res')),
        );
      }
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
                SizedBox(height: 8),
                Text(
                  'Enter your email and password',
                  style: TextStyle(
                    color: Color(0xff797979),
                    fontSize: 20,
                    fontFamily: 'Gelix',
                  ),
                ),
                SizedBox(height: 16),
                _buildTextFormField(
                  controller: emailController,
                  hintText: 'Enter email',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                _buildTextFormField(
                  controller: passwordController,
                  hintText: 'Enter password',
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    } else if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 32),
                GestureDetector(
                  onTap: isLoading ? null : login,
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: buttonColor,
                    ),
                    child: Center(
                      child: isLoading
                          ? CircularProgressIndicator(color: primarybuttonColor)
                          : Text(
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
                SizedBox(height: 32),
                ListView.builder(
                  itemCount: loginButtonData.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Container(
                      height: MediaQuery.of(context).size.height * .05,
                      margin: EdgeInsets.symmetric(vertical: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Color(0xffE1E1E1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 80),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            loginButtonData[index][0],
                            SizedBox(width: 32),
                            Text(
                              'Continue with ${loginButtonData[index][1]}',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                                fontFamily: 'Gelix',
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 32),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegistrationScreen()),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don’t have an account?',
                        style: TextStyle(
                          color: Color(0xff797979),
                          fontSize: 14,
                          fontFamily: 'Gelix',
                        ),
                      ),
                      Text(
                        '  Register',
                        style: TextStyle(
                          color: primarybuttonColor,
                          fontSize: 14,
                          fontFamily: 'Gelix',
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * .073),
                Text(
                  'By proceeding, you consent to get calls, WhatsApp or SMS messages, including by automated means, from Uber and its affiliates to the number provided.',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Color(0xff797979),
                    fontSize: 14,
                    fontFamily: 'Gelix',
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * .06),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'This site is protected by reCAPTCHA and the Google ',
                        style: TextStyle(
                          color: Color(0xff797979),
                          fontSize: 14,
                          fontFamily: 'Gelix',
                        ),
                      ),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Gelix',
                        ),
                      ),
                      TextSpan(
                        text: ' and ',
                        style: TextStyle(
                          color: Color(0xff797979),
                          fontSize: 14,
                          fontFamily: 'Gelix',
                        ),
                      ),
                      TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Gelix',
                        ),
                      ),
                      TextSpan(
                        text: ' apply',
                        style: TextStyle(
                          color: Color(0xff797979),
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

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      cursorColor: primarybuttonText,
      style: TextStyle(
        color: Color(0xff797979),
        fontSize: 18,
        fontFamily: 'Gelix',
      ),
      decoration: InputDecoration(
        focusColor: Color(0xff797979),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        hintText: hintText,
        hintStyle: TextStyle(
          color: Color(0xff797979),
          fontSize: 18,
          fontFamily: 'Gelix',
        ),
        filled: true,
        fillColor: Color(0xff242426),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      validator: validator,
    );
  }
}

class AssetGen {
  SvgPicture google({double? height}) {
    return SvgPicture.asset(
      'assets/authIcons/google.svg',
      height: height,
    );
  }

  SvgPicture apple({double? height}) {
    return SvgPicture.asset(
      'assets/authIcons/apple.svg',
      height: height,
    );
  }

  SvgPicture facebook({double? height}) {
    return SvgPicture.asset(
      'assets/authIcons/facebook.svg',
      height: height,
    );
  }

  SvgPicture mail({double? height}) {
    return SvgPicture.asset(
      'assets/authIcons/mail.svg',
      height: height,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:vahan/screen/homepage.dart';
import 'package:easy_splash_screen/easy_splash_screen.dart';


void main() {

  runApp(const MyApp());
}

//FlutterNativeSplash.remove();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vahan',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home:EasySplashScreen(
        logo: Image.asset(
            'assets/images/Vahan.png'),
        backgroundColor: Colors.black,
        showLoader: false,
        navigator: homepage(),
        durationInSeconds: 3,
      ),
    );
  }
}


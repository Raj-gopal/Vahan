import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:vahan/authScreens/loginScreen.dart';
import 'package:easy_splash_screen/easy_splash_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBuXGyqYqpewYzRD32R5tEsjoytb_D0BPo",
      appId: "1:774941537458:android:f42d8357967aaeaed6c5ab",
      messagingSenderId: "774941537458",
      projectId: "vahan-1036f",
      // storageBucket: "wealthwise-34466.appspot.com",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vahan',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: Center(
        child: EasySplashScreen(
          logo: Image.asset('assets/images/Vahan.png'),
          backgroundColor: Colors.black,
          showLoader: false,
          navigator: LoginScreen(),
          durationInSeconds: 3,
        ),
      ),
    );
  }
}

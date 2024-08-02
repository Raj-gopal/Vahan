import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:vahan/screen/homepage.dart';

import '../utils/style.dart';

class otpScreen extends StatefulWidget {
  String verificationid;

  otpScreen({required this.verificationid});

  @override
  State<otpScreen> createState() => _otpScreenState();
}

class _otpScreenState extends State<otpScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
            ),
            Text(
              'OTP Code',
              style: TextStyle(
                fontFamily: 'Gelix',
                fontWeight: FontWeight.w400,
                fontSize: 32,
                color: Color(0xff797979),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.08,
            ),
            Text(
              'Enter your OTP',
              style: TextStyle(
                fontFamily: 'Gelix',
                fontWeight: FontWeight.w400,
                fontSize: 20,
                color: Color(0xff797979),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            Pinput(
              controller: otpController,
              length: 6,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: focusedPinTheme,
              submittedPinTheme: submittedPinTheme,
              validator: (s) {
                return s == '2222' ? null : 'Pin is incorrect';
              },
              pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
              showCursor: true,
              onCompleted: (pin) => print(pin),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.055),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.07,
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  try {
                    PhoneAuthCredential credential =
                    await PhoneAuthProvider.credential(
                      verificationId: widget.verificationid,
                      smsCode: otpController.text.toString(),
                    );
                    FirebaseAuth.instance.signInWithCredential(credential).then((value){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Homepage()),
                      );
                    });
                  } catch (ex) {
                    log(ex.toString());
                  }
                },
                child: Text(
                  'Verify',
                  style: TextStyle(
                    fontFamily: 'Gelix',
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                    color: primarytextColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final defaultPinTheme = PinTheme(
  width: 66,
  height: 66,
  textStyle: TextStyle(
    fontFamily: 'Gelix',
    fontWeight: FontWeight.w400,
    fontSize: 20,
    color: Color(0xff797979),
  ),
  decoration: BoxDecoration(
    color: buttonColor,
    borderRadius: BorderRadius.circular(8),
  ),
);

final focusedPinTheme = defaultPinTheme.copyDecorationWith(
  color: buttonColor,
  borderRadius: BorderRadius.circular(8),
);

final submittedPinTheme = defaultPinTheme.copyWith(
  decoration: defaultPinTheme.decoration?.copyWith(
    color: buttonColor,
  ),
);

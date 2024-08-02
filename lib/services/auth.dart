import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // For SignUp
  Future<String> signupUser({
    required String name,
    required String number,
    required String email,
    required String password,
  }) async {
    try {
      // Create user with email and password
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the current user
      User? user = credential.user;

      if (user != null) {
        // Create a document in Firestore with the user's details
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'number': number,
          'email': email,
          'uid': user.uid,
        });

        return 'success'; // Registration successful
      }
      return 'An unexpected error occurred'; // If user is null
    } on FirebaseAuthException catch (e) {
      // Handle FirebaseAuth exceptions
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        return 'The email address is badly formatted.';
      } else {
        return 'An undefined Firebase error occurred.';
      }
    } catch (e) {
      // Handle other exceptions
      print('Firestore Error: ${e.toString()}'); // Print error for debugging
      return 'An error occurred: ${e.toString()}'; // Return a generic error message
    }
  }

  // For Login
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        // login user with email and password
        await _auth.signInWithEmailAndPassword(email: email, password: password);
        return 'success';
      }
    } catch (e) {
      return e.toString();
    }
    return 'Some error occurred';
  }
}

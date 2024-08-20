import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:vahan/driver/provider/provider.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static User? get currentUser => _auth.currentUser;
}

class LocationServices {
  static Future<LatLng> getCurrentLocation() async {
    loc.Location location = loc.Location();
    bool serviceEnabled;
    loc.PermissionStatus permissionGranted;
    loc.LocationData locationData;

    // Check if location services are enabled
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        throw Exception("Location services are disabled.");
      }
    }

    // Check for location permissions
    permissionGranted = await location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        throw Exception("Location permission not granted.");
      }
    }

    // Get the current location
    locationData = await location.getLocation();
    return LatLng(locationData.latitude!, locationData.longitude!);
  }
}

class GeoFireServices {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static CollectionReference get userStatusCollection =>
      _firestore.collection('DriverStatus');

  static Future<DocumentSnapshot> getDriverStatusDocument() async {
    final user = AuthService.currentUser;
    if (user != null) {
      return userStatusCollection.doc(user.email).get(); // Use email for document ID
    }
    throw Exception("User not authenticated.");
  }

  static Future<void> goOnline() async {
    try {
      LatLng currentLocation = await LocationServices.getCurrentLocation();
      User? user = AuthService.currentUser;

      if (user != null) {
        // Define GeoFirePoint based on current location
        final GeoFirePoint geoFirePoint = GeoFirePoint(
          GeoPoint(currentLocation.latitude, currentLocation.longitude),
        );

        // Use SetOptions(merge: true) to update the existing document or create it if it doesn't exist
        await FirebaseFirestore.instance.collection('DriverStatus').doc(user.email).set(
          <String, dynamic>{
            'status': 'ONLINE',
            'geo': geoFirePoint.data,
            'isVisible': true,
          },
          SetOptions(merge: true), // Merge to avoid overwriting other fields
        );
      } else {
        throw Exception("User not authenticated.");
      }
    } catch (e) {
      print('Error setting location: $e');
    }
  }

  static Future<void> goOffline() async {
    try {
      User? user = AuthService.currentUser;
      if (user != null) {
        // Use SetOptions(merge: true) to update the existing document
        await FirebaseFirestore.instance.collection('DriverStatus').doc(user.email).set(
          <String, dynamic>{
            'status': 'OFFLINE',
          },
          SetOptions(merge: true), // Merge to avoid overwriting other fields
        );
      } else {
        throw Exception("User not authenticated.");
      }
    } catch (e) {
      print('Error going offline: $e');
    }
  }

  static void updateLocationRealTime(BuildContext context) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      final user = AuthService.currentUser;

      if (user != null) {
        StreamSubscription<Position> driverPositionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
            distanceFilter: 10,
          ),
        ).listen((Position position) {
          context.read<LocationProviderDriver>().updateDriverPosition(position);
          userStatusCollection.doc(user.email).update({
            'location': {
              'latitude': position.latitude,
              'longitude': position.longitude,
            }
          });
        });

        // Optionally, store the subscription if you need to cancel it later
        // _driverPositionStream = driverPositionStream;
      } else {
        print("User not authenticated.");
      }
    }
  }
}

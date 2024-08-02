// import 'dart:convert';
//
// import 'package:flutter/cupertino.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'package:toasty_box/toast_service.dart';
// import 'package:vahan/services/APIsNKeys/Apis.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:vahan/services/pickupanddroploctaion.dart';
//
// class LocationServices {
//   static Future<LatLng?> getCurrentLocation() async {
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         return null;
//       }
//     }
//
//     if (permission == LocationPermission.deniedForever) {
//       // Handle the case where permissions are permanently denied.
//       return null;
//     }
//
//     Position currentPosition = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.bestForNavigation,
//     );
//
//     LatLng currentLocation =
//         LatLng(currentPosition.latitude, currentPosition.longitude);
//     return currentLocation;
//   }
//
//   static Future<Pickupanddroploctaion> getAddressFromLatLng({
//     required LatLng position,
//     required BuildContext context,
//   }) async {
//     final api = Uri.parse(APIs.geoCodingApi(position));
//     try {
//       var response = await http.get(api, headers: {
//         'Content-Type': 'application/json',
//       }).timeout(const Duration(seconds: 60), onTimeout: () {
//         Fluttertoast.showToast(
//           msg: "Oops! Connection Timed Out",
//           toastLength: Toast.LENGTH_SHORT,
//           gravity: ToastGravity.BOTTOM,
//         );
//         return http.Response('Error', 408); // Timeout response
//       });
//
//       if (response.statusCode == 200) {
//         var decodedResponse = jsonDecode(response.body);
//         Pickupanddroploctaion model = Pickupanddroploctaion(
//           name: decodedResponse['results'][0][' formatted_address'],
//           placeID: decodedResponse['results'][0]['place_id!'],
//           latitude: position.latitude.toString(),
//           longitude: position.latitude.toString(),
//         );
//         return model;
//       } else {
//         // Handle the error response
//         throw Exception('Failed to load address');
//       }
//     } catch (e) {
//       throw Exception('Error: $e');
//     }
//   }
// }

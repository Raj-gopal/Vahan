import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/APIsNKeys/Apis.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static User? get currentUser => _auth.currentUser;
}

class BookingScreen extends StatefulWidget {
  final LatLng startLocation;
  final LatLng nextLocation;
  final String startAddress;
  final String nextAddress;

  const BookingScreen({
    Key? key,
    required this.startLocation,
    required this.nextLocation,
    required this.startAddress,
    required this.nextAddress,
  }) : super(key: key);

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String? selectedRideType;
  bool isRequesting = false;
  bool isRequestAccepted = false;
  Map<String, dynamic>? driverDetails;
  Timer? _timer;
  String _phone = '+917783061661';
  final websiteUri = Uri.parse('https://heyflutter.com');

  @override
  void initState() {
    super.initState();
    getCoordinates();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer if the widget is disposed
    super.dispose();
  }

  List listofpoint = [];
  List<LatLng> points = [];

  // Function to consume the Mapbox API
  getCoordinates() async {
    try {
      var response = await http.get(
        getRouteUrl(
          '${widget.startLocation.longitude}',
          '${widget.startLocation.latitude}',
          '${widget.nextLocation.longitude}',
          '${widget.nextLocation.latitude}',
        ),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        listofpoint = data['routes'][0]['geometry']['coordinates'];
        points = listofpoint
            .map<LatLng>((e) => LatLng(e[1].toDouble(), e[0].toDouble()))
            .toList();
        setState(() {}); // Refresh map with new coordinates
      } else {
        print('Failed to load coordinates');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> bookRide(String rideType) async {
    setState(() {
      isRequesting = true;
      selectedRideType = rideType;
    });

    final user = AuthService.currentUser;

    // Fetch user data from Firestore
    DocumentSnapshot userSnapshot =
        await firestore.collection('users').doc(user!.uid).get();
    await firestore.collection('usersRequest').doc(user.email).set({
      'name': userSnapshot['name'],
      'number': userSnapshot['number'],
      'email': user.email,
      'car_type': rideType,
      'distance': '25',
      'fare': '300',
      'longitude': widget.startLocation.longitude,
      'latitude': widget.startLocation.latitude,
      'pick_up': widget.startAddress,
      'drop_loc': widget.nextAddress,
      'driver_name': null,
      'driver_car_num': null,
      'driver_loc': null,
      'driver_lat': null,
      'driver_long': null,
      'status': 'Searching',
      'time': 'now',
    });

    // Start a timer to periodically check the request status
    _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
      DocumentSnapshot userReqSnapshot =
          await firestore.collection('usersRequest').doc(user.email).get();
      if (userReqSnapshot.exists && userReqSnapshot['status'] == 'Founded') {
        setState(() {
          isRequesting = false;
          isRequestAccepted = true;
          driverDetails = {
            'name': 'John Doe',
            'carNumber': 'ABC-1234',
            'location': LatLng(20.5937, 78.9629), // Sample driver location
          };
        });
        _timer?.cancel(); // Stop the timer once the request is accepted
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              center: LatLng(widget.startLocation.latitude,
                  widget.startLocation.longitude),
              zoom: 13,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://api.mapbox.com/styles/v1/mapbox/dark-v10/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1IjoibWFwYm94LW1hcC1kZXNpZ24iLCJhIjoiY2syeHpiaHlrMDJvODNidDR5azU5NWcwdiJ9.x0uSqSWGXdoFKuHZC5Eo_Q',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: points,
                    color: Color(0xffE1E1E1),
                    strokeWidth: 3,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(widget.startLocation.latitude,
                        widget.startLocation.longitude),
                    child: Container(
                      height: 16,
                      width: 16,
                      decoration: BoxDecoration(
                        color: Color(0xffE1E1E1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Marker(
                    point: LatLng(widget.nextLocation.latitude,
                        widget.nextLocation.longitude),
                    child: Container(
                      height: 16,
                      width: 16,
                      decoration: BoxDecoration(
                        color: Color(0xffB3FD14),
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.52,
              decoration: BoxDecoration(
                color: Color(0xff191A1A),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: EdgeInsets.all(24),
              child: isRequesting
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        LinearProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xffB3FD14)),
                          backgroundColor: Color(0xff383838),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Searching for a driver...',
                          style: TextStyle(
                            color: Color(0xffD0CCCC),
                            fontSize: 20,
                            fontFamily: 'Gelix',
                          ),
                        ),
                      ],
                    )
                  : isRequestAccepted && driverDetails != null
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                                height:
                                    MediaQuery.of(context).size.height * .15,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: Color(0xff242426),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          radius: 45,
                                          backgroundImage: AssetImage(
                                              'assets/images/profile.jpg'),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .02,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${driverDetails!['name']}',
                                              style: TextStyle(
                                                color: Color(0xffD0CCCC),
                                                fontSize: 20,
                                                fontFamily: 'Gelix',
                                              ),
                                            ),
                                            // SizedBox(height: MediaQuery.of(context).size.height*.005,),
                                            Text(
                                              '${driverDetails!['carNumber']}',
                                              style: TextStyle(
                                                color: Color(0xffD0CCCC),
                                                fontSize: 16,
                                                fontFamily: 'Gelix',
                                              ),
                                            ),
                                            Icon(
                                              Icons.star_rate_rounded,
                                              color: Colors.limeAccent,
                                            ),
                                          ],
                                        ),
                                        GestureDetector(
                                          onTap: () async {
                                            final Uri url = Uri(
                                                scheme: 'tel',
                                                path: '+917783061661');
                                            if (await canLaunchUrl(url)) {
                                              launchUrl(url);
                                            } else {
                                              print(
                                                  'Could not launch the dialer: ${url.toString()}');
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Could not launch the phone dialer. Please try again later.')),
                                              );
                                            }
                                          },
                                          child: Icon(
                                            Icons.call,
                                            color: Colors.limeAccent,
                                          ),
                                        ),
                                        Icon(
                                          Icons.chat_rounded,
                                          color: Colors.limeAccent,
                                        )
                                      ]),
                                )),
                            Text(
                              'Driver Found!',
                              style: TextStyle(
                                color: Color(0xffB3FD14),
                                fontSize: 24,
                                fontFamily: 'Gelix',
                              ),
                            ),
                            SizedBox(height: 16),
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Container(
                                  height: 24,
                                  width: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xffE1E1E1),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    widget.startAddress,
                                    style: TextStyle(
                                      color: Color(0xffD0CCCC),
                                      fontSize: 20,
                                      fontFamily: 'Gelix',
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Divider(
                              thickness: 1,
                              color: Color(0xff383838),
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Container(
                                  height: 24,
                                  width: 24,
                                  decoration: BoxDecoration(
                                    color: Color(0xffB3FD14),
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    widget.nextAddress,
                                    style: TextStyle(
                                      color: Color(0xffD0CCCC),
                                      fontSize: 20,
                                      fontFamily: 'Gelix',
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 24),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Suggests Rides',
                                style: TextStyle(
                                  color: Color(0xffD0CCCC),
                                  fontSize: 18,
                                  fontFamily: 'Gelix',
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                RideOption(
                                  image: 'assets/images/handle.png',
                                  type: 'PRO',
                                  price: '₹80.00',
                                  seats: 4,
                                  onTap: () => bookRide('PRO'),
                                ),
                                RideOption(
                                  image: 'assets/images/car.png',
                                  type: 'Mini',
                                  price: '₹80.00',
                                  seats: 4,
                                  onTap: () => bookRide('Mini'),
                                ),
                                RideOption(
                                  image: 'assets/images/car.png',
                                  type: 'Sedan',
                                  price: '₹120.00',
                                  seats: 4,
                                  onTap: () => bookRide('Sedan'),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            GestureDetector(
                              onTap: getCoordinates,
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.085,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: Color(0xff242426),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: Text(
                                    'Book Now',
                                    style: TextStyle(
                                      color: Color(0xffB3FD14),
                                      fontSize: 20,
                                      fontFamily: 'Gelix',
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
            ),
          ),
        ],
      ),
    );
  }
}

class RideOption extends StatelessWidget {
  final String type;
  final String price;
  final int seats;
  final String image;
  final VoidCallback onTap;

  RideOption({
    required this.type,
    required this.price,
    required this.seats,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Image.asset(image),
          SizedBox(height: 8),
          Text(
            type,
            style: TextStyle(
              color: Color(0xffE1E1E1),
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Gelix',
            ),
          ),
          SizedBox(height: 4),
          Text(
            price,
            style: TextStyle(
              color: Color(0xffE1E1E1),
              fontSize: 16,
              fontWeight: FontWeight.w400,
              fontFamily: 'Gelix',
            ),
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person, color: Color(0xffE1E1E1), size: 14),
              SizedBox(width: 4),
              Text(
                '$seats',
                style: TextStyle(
                  color: Color(0xffE1E1E1),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Gelix',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

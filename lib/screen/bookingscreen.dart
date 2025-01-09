import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vahan/screen/homepage.dart';
import 'package:vahan/utils/style.dart';
import '../services/APIsNKeys/Apis.dart';
import 'dart:math' as math;
import 'package:flutter_rating/flutter_rating.dart';

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
  //String? selectedRideType;
  bool isRequesting = false;
  bool isCancel = false;
  bool isSuggest = true;
  bool isInitial = true;
  String SelectedRideType = ''; // Stores the selected ride type
  bool isRequestAccepted = false;
  bool Selected = false;
  bool isbooknow = false;
  Map<String, dynamic>? driverDetails;
  Timer? _timer;
  String? _phone;
  String? status;
  final websiteUri = Uri.parse('https://heyflutter.com');
  final ref = FirebaseFirestore.instance.collection('usersRequest');
  final user = AuthService.currentUser;
  String? ArrivalTime;
  String? ArrivalDistance;
  double? DistanceStartToEnd;
  Timer? timer;
  int _start = 0;
  double rating = 0;
  int starCount = 5;
  String reviewText = "";
  final TextEditingController _reviewController = TextEditingController();

  bool _timerTriggered = false;

  @override
  void initState() {
    super.initState();
    getCoordinates();
    Future<void> fetchFieldValue() async {
      try {
        // Reference to Firestore collection
        var collection = FirebaseFirestore.instance.collection('usersRequest');

        // Fetch the document snapshot
        var docSnapshot = await collection.doc('rajgk0000@gmail.com').get();

        // Check if the document exists
        if (docSnapshot.exists) {
          // Retrieve the data as a map
          Map<String, dynamic>? data = docSnapshot.data();

          // Access the specific field
          var value = data?['status'];

          setState(() {
            status = value;
          });
          print('Retrieved value: $value');

          // Optional: Use setState to update UI (if inside a StatefulWidget)
          // setState(() {
          //   _someFieldValue = value;
          // });
        } else {
          print('No document found for the provided ID.');
        }
      } catch (error) {
        print('Error fetching data: $error');
      }
    }
    _calculateStarttoEnd(
        widget.startLocation.latitude,
        widget.startLocation.longitude,
        widget.nextLocation.latitude,
        widget.nextLocation.longitude,
        30);
  }

  // Haversine formula for distance calculation
  double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0; // Radius of Earth in kilometers
    final lat1Rad = lat1 * math.pi / 180;
    final lon1Rad = lon1 * math.pi / 180;
    final lat2Rad = lat2 * math.pi / 180;
    final lon2Rad = lon2 * math.pi / 180;

    final dlat = lat2Rad - lat1Rad;
    final dlon = lon2Rad - lon1Rad;

    final a = math.pow(math.sin(dlat / 2), 2) +
        math.cos(lat1Rad) * math.cos(lat2Rad) * math.pow(math.sin(dlon / 2), 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return R * c; // Distance in kilometers
  }

  // Function to calculate travel time using average speed
  String _calculateTime(double distanceInKm, double speedInKmPerHr) {
    double timeInHours = distanceInKm / speedInKmPerHr;
    double timeInMinutes = timeInHours * 60;

    return '${timeInMinutes.toStringAsFixed(2)} min'; // Return time in minutes
  }

  // Main function to calculate distance and time
  void _calculateDistanceAndTime(double startLat, double startLng,
      double endLat, double endLng, double speed) {
    double distance = _haversine(startLat, startLng, endLat, endLng);
    String time = _calculateTime(distance, speed);

    // Print or show the results
    print('Distance: ${distance.toStringAsFixed(2)} km');
    print('Time: $time');

    ArrivalTime = time;
    ArrivalDistance =
        distance.toStringAsFixed(2); // Correct if ArrivalDistance is String
  }

  //distance start to end
  void _calculateStarttoEnd(double startLat, double startLng, double endLat,
      double endLng, double speed) {
    double distance = _haversine(startLat, startLng, endLat, endLng);
    String time = _calculateTime(distance, speed);

    // Print or show the results
    print('Distance: ${distance.toStringAsFixed(2)} km');
    print('Time: $time');

    DistanceStartToEnd = distance; // Correct if ArrivalDistance is String
  }

//status data

  Future<void> fetchFieldValue() async {
    try {
      // Reference to Firestore collection
      var collection = FirebaseFirestore.instance.collection('usersRequest');

      // Fetch the document snapshot
      var docSnapshot = await collection.doc('rajgk0000@gmail.com').get();

      // Check if the document exists
      if (docSnapshot.exists) {
        // Retrieve the data as a map
        Map<String, dynamic>? data = docSnapshot.data();

        // Access the specific field
        var value = data?['status'];

        setState(() {
          status = value;
        });
        print('Retrieved value: $value');

        // Optional: Use setState to update UI (if inside a StatefulWidget)
        // setState(() {
        //   _someFieldValue = value;
        // });
      } else {
        print('No document found for the provided ID.');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  bool isSelected = false;
  void toggleSelection() {
    setState(() {
      isSelected = !isSelected; // Toggle the selection state
    });
  }

  // Function to handle booking and suggesting a ride
  void bookride(String rideType) {
    // Booking logic here
    print("Booking $rideType ride...");

    // Then, trigger the Suggest Ride logic
    suggestRides();
  }

  // Function to suggest a ride
  void suggestRides() {
    // Your suggest ride logic here
    print("Suggesting rides...");
    // For example, you can set the state or trigger any further UI changes
    setState(() {
      // Update some state if needed, like suggesting rides
      isSuggest = true;
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer if the widget is disposed
    _reviewController.dispose();
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
      isCancel = false;
      isSuggest = false;
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
      'fare': '300',
      'longitude': widget.startLocation.longitude,
      'latitude': widget.startLocation.latitude,
      'dest_latitude': widget.nextLocation.latitude,
      'dest_longitude': widget.nextLocation.longitude,
      'pick_up': widget.startAddress,
      'drop_loc': widget.nextAddress,
      'driver_name': null,
      'driver_car_num': null,
      'driver_loc': null,
      'driver_lat': null,
      'driver_long': null,
      'status': 'Searching',
      'review_star': null,
      'review_desc': null,
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

  // Variable to store the selected ride type
  String? selectedRideType;
  double? distanceStartToEnd;


  List<Map<String, dynamic>> getRideOptions() {
    if (DistanceStartToEnd == null) {
      throw Exception('DistanceStartToEnd must be calculated first!');
    }

    return [
      {
        'type': 'Mini',
        'price': '₹' + (DistanceStartToEnd! * 50).toStringAsFixed(2),
        'seats': 4,
        'image': 'assets/images/car.png'
      },
      {
        'type': 'Sedan',
        'price': '₹' + (DistanceStartToEnd! * 100).toStringAsFixed(2),
        'seats': 6,
        'image': 'assets/images/sedan.png'
      },
      {
        'type': 'Suv',
        'price': '₹' + (DistanceStartToEnd! * 150).toStringAsFixed(2),
        'seats': 8,
        'image': 'assets/images/suv.png'
      },
    ];
  }



  @override

  Widget build(BuildContext context) {
    List<Map<String, dynamic>> rideOptions;
    try {
      // Dynamically generate ride options
      rideOptions = getRideOptions();
    } catch (e) {
      return Center(
        child: Text('Error: ${e.toString()}'),
      );
    }
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
                    strokeWidth: 4,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(widget.startLocation.latitude,
                        widget.startLocation.longitude),
                    child: Container(
                      height: 8,
                      width: 8,
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
              height: MediaQuery.of(context).size.height * 0.578,
              decoration: BoxDecoration(
                color: Color(0xff191A1A),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              //padding: EdgeInsets.only(left: 16,right: 16,),
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: StreamBuilder(
                  stream: ref.doc(user!.email).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData && snapshot.data!.exists) {
                        String status = snapshot.data!['status'].toString();
                        String ride = snapshot.data!['car_type'].toString();

                        if (status == 'Founded') {
                          // Example coordinates (San Francisco to Oakland)
                          double startLat = widget.startLocation.latitude;
                          double startLng = widget.startLocation.longitude;
                          double endLat = snapshot.data!['driver_lat'];
                          double endLng = snapshot.data!['driver_long'];

                          // Average speed (in km/h)
                          double averageSpeed = 30.0;

                          _calculateDistanceAndTime(
                              startLat, startLng, endLat, endLng, averageSpeed);

                          _calculateStarttoEnd(
                              startLat,
                              startLng,
                              widget.nextLocation.latitude,
                              widget.nextLocation.longitude,
                              averageSpeed);
                        }

                        if (status == 'Arrived') {
                          void startTimer() {
                            const oneSec = const Duration(seconds: 1);
                            timer = new Timer.periodic(
                                oneSec,
                                (Timer timer) => setState(() {
                                      if (_start > 300) {
                                        timer.cancel();
                                        final user = AuthService.currentUser;
                                        firestore
                                            .collection('users')
                                            .doc(user!.uid)
                                            .get();
                                        firestore
                                            .collection('usersRequest')
                                            .doc(user.email)
                                            .delete();
                                      } else {
                                        _start = _start + 1;
                                      }
                                    }));
                          }
                        }

                        // var data = snapshot.data['status']; // Fetch the document's data
                        // String status = data['status'] ?? '';

                        return ListView.builder(
                            itemCount: 1,
                            itemBuilder: (context, index) {
                              return status == 'Searching'
                                  ? Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Searching for a driver...',
                                          style: TextStyle(
                                            color: Color(0xffD0CCCC),
                                            fontSize: 20,
                                            fontFamily: 'Gelix',
                                          ),
                                        ),
                                        SizedBox(height: 16),
                                        LinearProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Color(0xffB3FD14)),
                                          backgroundColor: Color(0xff383838),
                                        ),
                                        SizedBox(height: 32),
                                        Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .2,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .5,
                                          child: Image.asset(
                                              'assets/images/cab_animation.gif'),
                                        ),
                                      ],
                                    )
                                  : status == 'Founded'
                                      ? Column(
                                          // mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    .15,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                decoration: BoxDecoration(
                                                  color: Color(0xff242426),
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(16),
                                                  child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        CircleAvatar(
                                                          radius: 45,
                                                          backgroundImage:
                                                              AssetImage(
                                                                  'assets/images/profile.jpg'),
                                                        ),
                                                        SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              .02,
                                                        ),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                              snapshot.data![
                                                                      'driver_name']
                                                                  .toString(),
                                                              style: TextStyle(
                                                                color: Color(
                                                                    0xffD0CCCC),
                                                                fontSize: 20,
                                                                fontFamily:
                                                                    'Gelix',
                                                              ),
                                                            ),
                                                            Text(
                                                              snapshot.data![
                                                                      'car_type']
                                                                  .toString(),
                                                              style: TextStyle(
                                                                color: Color(
                                                                    0xffD0CCCC),
                                                                fontSize: 16,
                                                                fontFamily:
                                                                    'Gelix',
                                                              ),
                                                            ),
                                                            // SizedBox(height: MediaQuery.of(context).size.height*.005,),
                                                            Text(
                                                              snapshot.data![
                                                                      'driver_car_num']
                                                                  .toString(),
                                                              style: TextStyle(
                                                                color: Color(
                                                                    0xffD0CCCC),
                                                                fontSize: 16,
                                                                fontFamily:
                                                                    'Gelix',
                                                              ),
                                                            ),
                                                            Icon(
                                                              Icons
                                                                  .star_rate_rounded,
                                                              color: Color(
                                                                  0xffB3FD14),
                                                            ),
                                                          ],
                                                        ),
                                                        Spacer(),
                                                        GestureDetector(
                                                          onTap: () async {
                                                            final Uri url = Uri(
                                                                scheme: 'tel',
                                                                path: snapshot
                                                                    .data![
                                                                        'driver_car_num']
                                                                    .toString());
                                                            if (await canLaunchUrl(
                                                                url)) {
                                                              launchUrl(url);
                                                            } else {
                                                              print(
                                                                  'Could not launch the dialer: ${url.toString()}');
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                SnackBar(
                                                                    content: Text(
                                                                        'Could not launch the phone dialer. Please try again later.')),
                                                              );
                                                            }
                                                          },
                                                          child: Icon(
                                                            Icons.call,
                                                            color: Color(
                                                                0xffB3FD14),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 28,
                                                        ),
                                                        Icon(
                                                          Icons.chat_rounded,
                                                          color:
                                                              Color(0xffB3FD14),
                                                        ),
                                                      ]),
                                                )),
                                            SizedBox(
                                              height: 16,
                                            ),
                                            Container(
                                              // height: MediaQuery.of(context).size.height *
                                              //     .15,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              decoration: BoxDecoration(
                                                color: Color(0xff242426),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(16),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Container(
                                                          height: 24,
                                                          width: 24,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: Color(
                                                                0xffE1E1E1),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 12,
                                                        ),
                                                        Expanded(
                                                          // Use Expanded to allow Text to take up available space
                                                          child: Text(
                                                            widget.startAddress,
                                                            style: TextStyle(
                                                              color: Color(
                                                                  0xff797979),
                                                              fontSize: 20,
                                                              fontFamily:
                                                                  'Gelix',
                                                            ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 12,
                                                    ),
                                                    Divider(
                                                      color: Color(0xff797979),
                                                    ),
                                                    SizedBox(
                                                      height: 12,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Container(
                                                          height: 24,
                                                          width: 24,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape: BoxShape
                                                                .rectangle,
                                                            color: Color(
                                                                0xffB3FD14),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 12,
                                                        ),
                                                        Expanded(
                                                          // Use Expanded to allow Text to take up available space
                                                          child: Text(
                                                            widget.nextAddress,
                                                            style: TextStyle(
                                                              color: Color(
                                                                  0xff797979),
                                                              fontSize: 20,
                                                              fontFamily:
                                                                  'Gelix',
                                                            ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 20,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Spacer(),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              'Arrival',
                                                              style: TextStyle(
                                                                color: Color(
                                                                    0xff797979),
                                                                fontSize: 12,
                                                                fontFamily:
                                                                    'Gelix',
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 4,
                                                            ),
                                                            Text(
                                                              ArrivalTime!,
                                                              style: TextStyle(
                                                                color: Color(
                                                                    0xffB3FD14),
                                                                fontSize: 20,
                                                                fontFamily:
                                                                    'Gelix',
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Spacer(),
                                                        Container(
                                                          height: 30.0,
                                                          width: 1.0,
                                                          color: Colors.white30,
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 10.0,
                                                                  right: 10.0),
                                                        ),
                                                        Spacer(),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              'Distance',
                                                              style: TextStyle(
                                                                color: Color(
                                                                    0xff797979),
                                                                fontSize: 12,
                                                                fontFamily:
                                                                    'Gelix',
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 4,
                                                            ),
                                                            Text(
                                                              DistanceStartToEnd!
                                                                      .toStringAsFixed(
                                                                          2) +
                                                                  ' Km',
                                                              style: TextStyle(
                                                                color: Color(
                                                                    0xffB3FD14),
                                                                fontSize: 20,
                                                                fontFamily:
                                                                    'Gelix',
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Spacer(),
                                                        Container(
                                                          height: 30.0,
                                                          width: 1.0,
                                                          color: Colors.white30,
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 10.0,
                                                                  right: 10.0),
                                                        ),
                                                        Spacer(),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              'Price',
                                                              style: TextStyle(
                                                                color: Color(
                                                                    0xff797979),
                                                                fontSize: 12,
                                                                fontFamily:
                                                                    'Gelix',
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 4,
                                                            ),

                                                            (ride=='Mini')?
                                                            Text(
                                                              '₹' +
                                                                  (DistanceStartToEnd! *
                                                                      50)
                                                                      .toStringAsFixed(
                                                                      2),
                                                              style:
                                                              TextStyle(
                                                                color: Color(
                                                                    0xffB3FD14),
                                                                fontSize:
                                                                20,
                                                                fontFamily:
                                                                'Gelix',
                                                              ),
                                                            ): (ride=='Sedan')?Text(
                                                              '₹' +
                                                                  (DistanceStartToEnd! *
                                                                      100)
                                                                      .toStringAsFixed(
                                                                      2),
                                                              style:
                                                              TextStyle(
                                                                color: Color(
                                                                    0xffB3FD14),
                                                                fontSize:
                                                                20,
                                                                fontFamily:
                                                                'Gelix',
                                                              ),
                                                            ):Text(
                                                              '₹' +
                                                                  (DistanceStartToEnd! *
                                                                      150)
                                                                      .toStringAsFixed(
                                                                      2),
                                                              style:
                                                              TextStyle(
                                                                color: Color(
                                                                    0xffB3FD14),
                                                                fontSize:
                                                                20,
                                                                fontFamily:
                                                                'Gelix',
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                        Spacer(),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 24),
                                            GestureDetector(
                                              onTap: () async {
                                                final user =
                                                    AuthService.currentUser;
                                                await firestore
                                                    .collection('users')
                                                    .doc(user!.uid)
                                                    .get();
                                                await firestore
                                                    .collection('usersRequest')
                                                    .doc(user.email)
                                                    .delete();
                                              },
                                              child: Container(
                                                height: 64,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  color: buttonColor,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'Cancel',
                                                    style: TextStyle(
                                                      color: Color(0xffF2613F),
                                                      fontSize: 20,
                                                      fontFamily: 'Gelix',
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                          ],
                                        )
                                      : status == 'Arrived'
                                          ? Column(
                                              // mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            .15,
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    decoration: BoxDecoration(
                                                      color: Color(0xff242426),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              16),
                                                      child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            CircleAvatar(
                                                              radius: 45,
                                                              backgroundImage:
                                                                  AssetImage(
                                                                      'assets/images/profile.jpg'),
                                                            ),
                                                            SizedBox(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  .02,
                                                            ),
                                                            Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Text(
                                                                  snapshot
                                                                      .data![
                                                                          'driver_name']
                                                                      .toString(),
                                                                  style:
                                                                      TextStyle(
                                                                    color: Color(
                                                                        0xffD0CCCC),
                                                                    fontSize:
                                                                        20,
                                                                    fontFamily:
                                                                        'Gelix',
                                                                  ),
                                                                ),
                                                                Text(
                                                                  snapshot
                                                                      .data![
                                                                          'car_type']
                                                                      .toString(),
                                                                  style:
                                                                      TextStyle(
                                                                    color: Color(
                                                                        0xffD0CCCC),
                                                                    fontSize:
                                                                        16,
                                                                    fontFamily:
                                                                        'Gelix',
                                                                  ),
                                                                ),
                                                                // SizedBox(height: MediaQuery.of(context).size.height*.005,),
                                                                Text(
                                                                  snapshot
                                                                      .data![
                                                                          'driver_car_num']
                                                                      .toString(),
                                                                  style:
                                                                      TextStyle(
                                                                    color: Color(
                                                                        0xffD0CCCC),
                                                                    fontSize:
                                                                        16,
                                                                    fontFamily:
                                                                        'Gelix',
                                                                  ),
                                                                ),
                                                                Icon(
                                                                  Icons
                                                                      .star_rate_rounded,
                                                                  color: Color(
                                                                      0xffB3FD14),
                                                                ),
                                                              ],
                                                            ),
                                                            Spacer(),
                                                            GestureDetector(
                                                              onTap: () async {
                                                                final Uri url = Uri(
                                                                    scheme:
                                                                        'tel',
                                                                    path: snapshot
                                                                        .data![
                                                                            'driver_car_num']
                                                                        .toString());
                                                                if (await canLaunchUrl(
                                                                    url)) {
                                                                  launchUrl(
                                                                      url);
                                                                } else {
                                                                  print(
                                                                      'Could not launch the dialer: ${url.toString()}');
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                    SnackBar(
                                                                        content:
                                                                            Text('Could not launch the phone dialer. Please try again later.')),
                                                                  );
                                                                }
                                                              },
                                                              child: Icon(
                                                                Icons.call,
                                                                color: Color(
                                                                    0xffB3FD14),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 28,
                                                            ),
                                                            Icon(
                                                              Icons
                                                                  .chat_rounded,
                                                              color: Color(
                                                                  0xffB3FD14),
                                                            ),
                                                          ]),
                                                    )),
                                                SizedBox(
                                                  height: 16,
                                                ),
                                                Container(
                                                  // height: MediaQuery.of(context).size.height *
                                                  //     .15,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  decoration: BoxDecoration(
                                                    color: Color(0xff242426),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Container(
                                                              height: 24,
                                                              width: 24,
                                                              decoration:
                                                                  BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: Color(
                                                                    0xffE1E1E1),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 12,
                                                            ),
                                                            Expanded(
                                                              // Use Expanded to allow Text to take up available space
                                                              child: Text(
                                                                widget
                                                                    .startAddress,
                                                                style:
                                                                    TextStyle(
                                                                  color: Color(
                                                                      0xff797979),
                                                                  fontSize: 20,
                                                                  fontFamily:
                                                                      'Gelix',
                                                                ),
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 12,
                                                        ),
                                                        Divider(
                                                          color:
                                                              Color(0xff797979),
                                                        ),
                                                        SizedBox(
                                                          height: 12,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Container(
                                                              height: 24,
                                                              width: 24,
                                                              decoration:
                                                                  BoxDecoration(
                                                                shape: BoxShape
                                                                    .rectangle,
                                                                color: Color(
                                                                    0xffB3FD14),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 12,
                                                            ),
                                                            Expanded(
                                                              // Use Expanded to allow Text to take up available space
                                                              child: Text(
                                                                widget
                                                                    .nextAddress,
                                                                style:
                                                                    TextStyle(
                                                                  color: Color(
                                                                      0xff797979),
                                                                  fontSize: 20,
                                                                  fontFamily:
                                                                      'Gelix',
                                                                ),
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 20,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Spacer(),
                                                            Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  'Waiting',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Color(
                                                                        0xff797979),
                                                                    fontSize:
                                                                        12,
                                                                    fontFamily:
                                                                        'Gelix',
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 4,
                                                                ),
                                                                Text(
                                                                  '5 min',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Color(
                                                                        0xffB3FD14),
                                                                    fontSize:
                                                                        20,
                                                                    fontFamily:
                                                                        'Gelix',
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Spacer(),
                                                            Container(
                                                              height: 30.0,
                                                              width: 1.0,
                                                              color: Colors
                                                                  .white30,
                                                              margin:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left:
                                                                          10.0,
                                                                      right:
                                                                          10.0),
                                                            ),
                                                            Spacer(),
                                                            Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  'Distance',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Color(
                                                                        0xff797979),
                                                                    fontSize:
                                                                        12,
                                                                    fontFamily:
                                                                        'Gelix',
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 4,
                                                                ),
                                                                Text(
                                                                  DistanceStartToEnd!
                                                                          .toStringAsFixed(
                                                                              2) +
                                                                      ' Km',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Color(
                                                                        0xffB3FD14),
                                                                    fontSize:
                                                                        20,
                                                                    fontFamily:
                                                                        'Gelix',
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Spacer(),
                                                            Container(
                                                              height: 30.0,
                                                              width: 1.0,
                                                              color: Colors
                                                                  .white30,
                                                              margin:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left:
                                                                          10.0,
                                                                      right:
                                                                          10.0),
                                                            ),
                                                            Spacer(),
                                                            Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  'Price',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Color(
                                                                        0xff797979),
                                                                    fontSize:
                                                                        12,
                                                                    fontFamily:
                                                                        'Gelix',
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 4,
                                                                ),

                                                                (ride=='Mini')?
                                                                Text(
                                                                  '₹' +
                                                                      (DistanceStartToEnd! *
                                                                              50)
                                                                          .toStringAsFixed(
                                                                              2),
                                                                  style:
                                                                      TextStyle(
                                                                    color: Color(
                                                                        0xffB3FD14),
                                                                    fontSize:
                                                                        20,
                                                                    fontFamily:
                                                                        'Gelix',
                                                                  ),
                                                                ): (ride=='Sedan')?Text(
                                                                  '₹' +
                                                                      (DistanceStartToEnd! *
                                                                          100)
                                                                          .toStringAsFixed(
                                                                          2),
                                                                  style:
                                                                  TextStyle(
                                                                    color: Color(
                                                                        0xffB3FD14),
                                                                    fontSize:
                                                                    20,
                                                                    fontFamily:
                                                                    'Gelix',
                                                                  ),
                                                                ):Text(
                                                                  '₹' +
                                                                      (DistanceStartToEnd! *
                                                                          150)
                                                                          .toStringAsFixed(
                                                                          2),
                                                                  style:
                                                                  TextStyle(
                                                                    color: Color(
                                                                        0xffB3FD14),
                                                                    fontSize:
                                                                    20,
                                                                    fontFamily:
                                                                    'Gelix',
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                            Spacer(),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 24),
                                                GestureDetector(
                                                  onTap: () async {
                                                    final user =
                                                        AuthService.currentUser;
                                                    await firestore
                                                        .collection('users')
                                                        .doc(user!.uid)
                                                        .get();
                                                    await firestore
                                                        .collection(
                                                            'usersRequest')
                                                        .doc(user.email)
                                                        .delete();
                                                  },
                                                  child: Container(
                                                    height: 64,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                      color: buttonColor,
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        'Cancel',
                                                        style: TextStyle(
                                                          color:
                                                              Color(0xffF2613F),
                                                          fontSize: 20,
                                                          fontFamily: 'Gelix',
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 8),
                                              ],
                                            )
                                          : status == 'Start_Ride'
                                              ? Column(
                                                  // mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            .15,
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Color(0xff242426),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(16),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(16),
                                                          child: Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                CircleAvatar(
                                                                  radius: 45,
                                                                  backgroundImage:
                                                                      AssetImage(
                                                                          'assets/images/profile.jpg'),
                                                                ),
                                                                SizedBox(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      .02,
                                                                ),
                                                                Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Text(
                                                                      snapshot
                                                                          .data![
                                                                              'driver_name']
                                                                          .toString(),
                                                                      style:
                                                                          TextStyle(
                                                                        color: Color(
                                                                            0xffD0CCCC),
                                                                        fontSize:
                                                                            20,
                                                                        fontFamily:
                                                                            'Gelix',
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      snapshot
                                                                          .data![
                                                                              'car_type']
                                                                          .toString(),
                                                                      style:
                                                                          TextStyle(
                                                                        color: Color(
                                                                            0xffD0CCCC),
                                                                        fontSize:
                                                                            16,
                                                                        fontFamily:
                                                                            'Gelix',
                                                                      ),
                                                                    ),
                                                                    // SizedBox(height: MediaQuery.of(context).size.height*.005,),
                                                                    Text(
                                                                      snapshot
                                                                          .data![
                                                                              'driver_car_num']
                                                                          .toString(),
                                                                      style:
                                                                          TextStyle(
                                                                        color: Color(
                                                                            0xffD0CCCC),
                                                                        fontSize:
                                                                            16,
                                                                        fontFamily:
                                                                            'Gelix',
                                                                      ),
                                                                    ),
                                                                    Icon(
                                                                      Icons
                                                                          .star_rate_rounded,
                                                                      color: Color(
                                                                          0xffB3FD14),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Spacer(),
                                                                GestureDetector(
                                                                  onTap:
                                                                      () async {
                                                                    final Uri url = Uri(
                                                                        scheme:
                                                                            'tel',
                                                                        path: snapshot
                                                                            .data!['driver_car_num']
                                                                            .toString());
                                                                    if (await canLaunchUrl(
                                                                        url)) {
                                                                      launchUrl(
                                                                          url);
                                                                    } else {
                                                                      print(
                                                                          'Could not launch the dialer: ${url.toString()}');
                                                                      ScaffoldMessenger.of(
                                                                              context)
                                                                          .showSnackBar(
                                                                        SnackBar(
                                                                            content:
                                                                                Text('Could not launch the phone dialer. Please try again later.')),
                                                                      );
                                                                    }
                                                                  },
                                                                  child: Icon(
                                                                    Icons.call,
                                                                    color: Color(
                                                                        0xffB3FD14),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 28,
                                                                ),
                                                                Icon(
                                                                  Icons
                                                                      .chat_rounded,
                                                                  color: Color(
                                                                      0xffB3FD14),
                                                                ),
                                                              ]),
                                                        )),
                                                    SizedBox(
                                                      height: 16,
                                                    ),
                                                    Container(
                                                      // height: MediaQuery.of(context).size.height *
                                                      //     .15,
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Color(0xff242426),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(16),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Container(
                                                                  height: 24,
                                                                  width: 24,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    color: Color(
                                                                        0xffE1E1E1),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 12,
                                                                ),
                                                                Expanded(
                                                                  // Use Expanded to allow Text to take up available space
                                                                  child: Text(
                                                                    widget
                                                                        .startAddress,
                                                                    style:
                                                                        TextStyle(
                                                                      color: Color(
                                                                          0xff797979),
                                                                      fontSize:
                                                                          20,
                                                                      fontFamily:
                                                                          'Gelix',
                                                                    ),
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                              height: 12,
                                                            ),
                                                            Divider(
                                                              color: Color(
                                                                  0xff797979),
                                                            ),
                                                            SizedBox(
                                                              height: 12,
                                                            ),
                                                            Row(
                                                              children: [
                                                                Container(
                                                                  height: 24,
                                                                  width: 24,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    shape: BoxShape
                                                                        .rectangle,
                                                                    color: Color(
                                                                        0xffB3FD14),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 12,
                                                                ),
                                                                Expanded(
                                                                  // Use Expanded to allow Text to take up available space
                                                                  child: Text(
                                                                    widget
                                                                        .nextAddress,
                                                                    style:
                                                                        TextStyle(
                                                                      color: Color(
                                                                          0xff797979),
                                                                      fontSize:
                                                                          20,
                                                                      fontFamily:
                                                                          'Gelix',
                                                                    ),
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                              height: 20,
                                                            ),
                                                            Row(
                                                              children: [
                                                                Spacer(),
                                                                Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      'Arrived in ',
                                                                      style:
                                                                          TextStyle(
                                                                        color: Color(
                                                                            0xff797979),
                                                                        fontSize:
                                                                            12,
                                                                        fontFamily:
                                                                            'Gelix',
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height: 4,
                                                                    ),
                                                                    Text(
                                                                      ((DistanceStartToEnd! / 30) *
                                                                              60)
                                                                          .toStringAsFixed(
                                                                              2),
                                                                      style:
                                                                          TextStyle(
                                                                        color: Color(
                                                                            0xffB3FD14),
                                                                        fontSize:
                                                                            20,
                                                                        fontFamily:
                                                                            'Gelix',
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Spacer(),
                                                                Container(
                                                                  height: 30.0,
                                                                  width: 1.0,
                                                                  color: Colors
                                                                      .white30,
                                                                  margin: const EdgeInsets
                                                                      .only(
                                                                      left:
                                                                          10.0,
                                                                      right:
                                                                          10.0),
                                                                ),
                                                                Spacer(),
                                                                Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      'Distance',
                                                                      style:
                                                                          TextStyle(
                                                                        color: Color(
                                                                            0xff797979),
                                                                        fontSize:
                                                                            12,
                                                                        fontFamily:
                                                                            'Gelix',
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height: 4,
                                                                    ),
                                                                    Text(
                                                                      DistanceStartToEnd!
                                                                              .toStringAsFixed(2) +
                                                                          ' Km',
                                                                      style:
                                                                          TextStyle(
                                                                        color: Color(
                                                                            0xffB3FD14),
                                                                        fontSize:
                                                                            20,
                                                                        fontFamily:
                                                                            'Gelix',
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Spacer(),
                                                                Container(
                                                                  height: 30.0,
                                                                  width: 1.0,
                                                                  color: Colors
                                                                      .white30,
                                                                  margin: const EdgeInsets
                                                                      .only(
                                                                      left:
                                                                          10.0,
                                                                      right:
                                                                          10.0),
                                                                ),
                                                                Spacer(),
                                                                Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      'Price',
                                                                      style:
                                                                          TextStyle(
                                                                        color: Color(
                                                                            0xff797979),
                                                                        fontSize:
                                                                            12,
                                                                        fontFamily:
                                                                            'Gelix',
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height: 4,
                                                                    ),

                                                                    (ride=='Mini')?
                                                                    Text(
                                                                      '₹' +
                                                                          (DistanceStartToEnd! *
                                                                              50)
                                                                              .toStringAsFixed(
                                                                              2),
                                                                      style:
                                                                      TextStyle(
                                                                        color: Color(
                                                                            0xffB3FD14),
                                                                        fontSize:
                                                                        20,
                                                                        fontFamily:
                                                                        'Gelix',
                                                                      ),
                                                                    ): (ride=='Sedan')?Text(
                                                                      '₹' +
                                                                          (DistanceStartToEnd! *
                                                                              100)
                                                                              .toStringAsFixed(
                                                                              2),
                                                                      style:
                                                                      TextStyle(
                                                                        color: Color(
                                                                            0xffB3FD14),
                                                                        fontSize:
                                                                        20,
                                                                        fontFamily:
                                                                        'Gelix',
                                                                      ),
                                                                    ):Text(
                                                                      '₹' +
                                                                          (DistanceStartToEnd! *
                                                                              150)
                                                                              .toStringAsFixed(
                                                                              2),
                                                                      style:
                                                                      TextStyle(
                                                                        color: Color(
                                                                            0xffB3FD14),
                                                                        fontSize:
                                                                        20,
                                                                        fontFamily:
                                                                        'Gelix',
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                                Spacer(),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 24),
                                                    GestureDetector(
                                                      onTap: () async {
                                                        final user = AuthService
                                                            .currentUser;
                                                        await firestore
                                                            .collection('users')
                                                            .doc(user!.uid)
                                                            .get();
                                                        await firestore
                                                            .collection(
                                                                'usersRequest')
                                                            .doc(user.email)
                                                            .delete();
                                                      },
                                                      child: Container(
                                                        height: 64,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(16),
                                                          color: buttonColor,
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            'Cancel',
                                                            style: TextStyle(
                                                              color: Color(
                                                                  0xffF2613F),
                                                              fontSize: 20,
                                                              fontFamily:
                                                                  'Gelix',
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 8),
                                                  ],
                                                )
                                              : status == 'Review'
                                                  ? Center(
                                                    child: Column(
                                                        children: [
                                                          Container(
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                .15,
                                                            width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Color(
                                                                  0xff242426),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          16),
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(16),
                                                              child: Row(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    CircleAvatar(
                                                                      radius: 45,
                                                                      backgroundImage:
                                                                          AssetImage(
                                                                              'assets/images/profile.jpg'),
                                                                    ),
                                                                    SizedBox(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          .05,
                                                                    ),
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Row(
                                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                                                            Column(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Text(
                                                                                  snapshot
                                                                                      .data!['driver_name']
                                                                                      .toString(),
                                                                                  style:
                                                                                      TextStyle(
                                                                                    color:
                                                                                        Color(0xffD0CCCC),
                                                                                    fontSize:
                                                                                        20,
                                                                                    fontFamily:
                                                                                        'Gelix',
                                                                                  ),
                                                                                ),
                                                                                Text(
                                                                                  snapshot
                                                                                      .data!['car_type']
                                                                                      .toString(),
                                                                                  style:
                                                                                  TextStyle(
                                                                                    color:
                                                                                    Color(0xffD0CCCC),
                                                                                    fontSize:
                                                                                    20,
                                                                                    fontFamily:
                                                                                    'Gelix',
                                                                                  ),
                                                                                ),

                                                                              ],
                                                                            ),
                                                                            SizedBox(width: MediaQuery.of(context).size.width*.4,),
                                                                            Text(
                                                                              snapshot
                                                                                  .data!['driver_car_num']
                                                                                  .toString(),
                                                                              style:
                                                                              TextStyle(
                                                                                color:
                                                                                Color(0xffD0CCCC),
                                                                                fontSize:
                                                                                20,
                                                                                fontFamily:
                                                                                'Gelix',
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),

                                                                        // SizedBox(height: MediaQuery.of(context).size.height*.005,),

                                                                        // Icon(
                                                                        //   Icons
                                                                        //       .star_rate_rounded,
                                                                        //   color: Color(
                                                                        //       0xffB3FD14),
                                                                        // ),
                                                                      ],
                                                                    ),


                                                                  ]),
                                                            ),
                                                          ),
                                                          SizedBox(height: 32,),
                                                          Text(
                                                            'How would you rate your driver?',
                                                            style: TextStyle(
                                                              color: Color(
                                                                  0xffD0CCCC),
                                                              fontSize: 20,
                                                              fontFamily: 'Gelix',
                                                            ),
                                                          ),
                                                          SizedBox(height: 16),
                                                          StarRating(
                                                            size: 40.0,
                                                            rating: rating,
                                                            color:
                                                                Color(0xffFBBC05),
                                                            borderColor: Color(
                                                                    0xffE1E1E1)
                                                                .withOpacity(.4),
                                                            allowHalfRating:
                                                                false,
                                                            starCount: starCount,
                                                            onRatingChanged:
                                                                (rating) =>
                                                                    setState(() {
                                                              this.rating =
                                                                  rating;
                                                              print(rating);
                                                            }),
                                                          ),
                                                          SizedBox(height: 96),
                                                          GestureDetector(
                                                            onTap: () {
                                                              print(
                                                                  "Review Submitted: $reviewText");
                                                              final user = AuthService.currentUser;
                                                              firestore
                                                                  .collection('users')
                                                                  .doc(user!.uid)
                                                                  .get();
                                                              firestore
                                                                  .collection('usersRequest')
                                                                  .doc(user.email)
                                                                  .delete();
                                                              Navigator.push(context,MaterialPageRoute(builder: (context) =>Homepage()));

                                                            },
                                                            child: Container(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.075,
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.9,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Color(
                                                                    0xff242426),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            16),
                                                              ),
                                                              child: Center(
                                                                child: Text(
                                                                  'Submit',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Color(
                                                                        0xffB3FD14),
                                                                    fontSize: 20,
                                                                    fontFamily:
                                                                        'Gelix',
                                                                  ),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                  )
                                                  : Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Container(
                                                              height: 24,
                                                              width: 24,
                                                              decoration:
                                                                  BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: Color(
                                                                    0xffE1E1E1),
                                                              ),
                                                            ),
                                                            SizedBox(width: 16),
                                                            Expanded(
                                                              child: Text(
                                                                widget
                                                                    .startAddress,
                                                                style:
                                                                    TextStyle(
                                                                  color: Color(
                                                                      0xffD0CCCC),
                                                                  fontSize: 20,
                                                                  fontFamily:
                                                                      'Gelix',
                                                                ),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(height: 16),
                                                        Divider(
                                                          thickness: 1,
                                                          color:
                                                              Color(0xff383838),
                                                        ),
                                                        SizedBox(height: 16),
                                                        Row(
                                                          children: [
                                                            Container(
                                                              height: 24,
                                                              width: 24,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Color(
                                                                    0xffB3FD14),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            32),
                                                              ),
                                                            ),
                                                            SizedBox(width: 16),
                                                            Expanded(
                                                              child: Text(
                                                                widget
                                                                    .nextAddress,
                                                                style:
                                                                    TextStyle(
                                                                  color: Color(
                                                                      0xffD0CCCC),
                                                                  fontSize: 20,
                                                                  fontFamily:
                                                                      'Gelix',
                                                                ),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(height: 24),
                                                        Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            'Suggests Rides',
                                                            style: TextStyle(
                                                              color: Color(
                                                                  0xffD0CCCC),
                                                              fontSize: 18,
                                                              fontFamily:
                                                                  'Gelix',
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(height: 8),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceAround,
                                                          children: rideOptions
                                                              .map((ride) {
                                                            return RideOption(
                                                              type:
                                                                  ride['type'],
                                                              price:
                                                                  ride['price'],
                                                              seats:
                                                                  ride['seats'],
                                                              image:
                                                                  ride['image'],
                                                              isSelected:
                                                                  selectedRideType ==
                                                                      ride[
                                                                          'type'], // Check if this option is selected
                                                              onTap: () {
                                                                setState(() {
                                                                  selectedRideType =
                                                                      ride[
                                                                          'type']; // Update selected ride type on tap
                                                                  SelectedRideType =
                                                                      selectedRideType!;
                                                                  isbooknow =
                                                                      true;
                                                                });
                                                              },
                                                            );
                                                          }).toList(),
                                                        ),
                                                        SizedBox(height: 16),
                                                        Container(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              .04,
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                            color: Color(
                                                                0xff383838),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 8.0,
                                                                    right: 8.0),
                                                            child: Row(
                                                              children: [
                                                                Text(
                                                                  'Cash',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Color(
                                                                        0xffE1E1E1),
                                                                    fontSize:
                                                                        16,
                                                                    fontFamily:
                                                                        'Gelix',
                                                                  ),
                                                                ),
                                                                Spacer(),
                                                                Icon(
                                                                  Icons
                                                                      .arrow_forward_ios_rounded,
                                                                  color: Color(
                                                                      0xffE1E1E1),
                                                                  size: 16,
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(height: 16),
                                                        Row(
                                                          children: [
                                                            Container(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.075,
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.16,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Color(
                                                                    0xff242426),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            16),
                                                              ),
                                                              child: Image(
                                                                width: 40,
                                                                height: 40,
                                                                image: Svg(
                                                                    'assets/svg/calendar.svg'),
                                                              ),
                                                            ),
                                                            Spacer(),
                                                            isbooknow
                                                                ? GestureDetector(
                                                                    onTap:
                                                                        () async {
                                                                      bookRide(
                                                                          SelectedRideType);
                                                                      print(
                                                                          "Selected ride type: $SelectedRideType");
                                                                      isbooknow =
                                                                          false;

                                                                      fetchFieldValue();
                                                                      print(
                                                                          'Found: $status');
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      height: MediaQuery.of(context)
                                                                              .size
                                                                              .height *
                                                                          0.075,
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.7,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Color(
                                                                            0xff242426),
                                                                        borderRadius:
                                                                            BorderRadius.circular(16),
                                                                      ),
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            Text(
                                                                          'Book Now',
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Color(0xffB3FD14),
                                                                            fontSize:
                                                                                20,
                                                                            fontFamily:
                                                                                'Gelix',
                                                                          ),
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  )
                                                                : GestureDetector(
                                                                    onTap:
                                                                        () {},
                                                                    child:
                                                                        Container(
                                                                      height: MediaQuery.of(context)
                                                                              .size
                                                                              .height *
                                                                          0.075,
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.7,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Color(
                                                                            0xff242426),
                                                                        borderRadius:
                                                                            BorderRadius.circular(16),
                                                                      ),
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            Text(
                                                                          'Book Now',
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Color(0xffB3FD14),
                                                                            fontSize:
                                                                                20,
                                                                            fontFamily:
                                                                                'Gelix',
                                                                          ),
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                          ],
                                                        ),
                                                      ],
                                                    );
                            });
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            '${snapshot.hasError.toString()}',
                            style: TextStyle(
                              color: Color(0xff797979),
                              fontSize: 20,
                              fontFamily: 'Gelix',
                            ),
                          ),
                        );
                      }
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Container(
                        height: 32,
                        width: 32,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xffB3FD14),
                          ),
                        ),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 40.0),
                      child: Column(
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
                            children: rideOptions.map((ride) {
                              return RideOption(
                                type: ride['type'],
                                price: ride['price'],
                                seats: ride['seats'],
                                image: ride['image'],
                                isSelected: selectedRideType ==
                                    ride[
                                        'type'], // Check if this option is selected
                                onTap: () {
                                  setState(() {
                                    selectedRideType = ride[
                                        'type']; // Update selected ride type on tap
                                    SelectedRideType = selectedRideType!;
                                    isbooknow = true;
                                  });
                                },
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 16),
                          Container(
                            height: MediaQuery.of(context).size.height * .04,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Color(0xff383838),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, right: 8.0),
                              child: Row(
                                children: [
                                  Text(
                                    'Cash',
                                    style: TextStyle(
                                      color: Color(0xffE1E1E1),
                                      fontSize: 16,
                                      fontFamily: 'Gelix',
                                    ),
                                  ),
                                  Spacer(),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: Color(0xffE1E1E1),
                                    size: 16,
                                  )
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.075,
                                width: MediaQuery.of(context).size.width * 0.16,
                                decoration: BoxDecoration(
                                  color: Color(0xff242426),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Image(
                                  width: 40,
                                  height: 40,
                                  image: Svg('assets/svg/calendar.svg'),
                                ),
                              ),
                              Spacer(),
                              isbooknow
                                  ? GestureDetector(
                                      onTap: () async {
                                        bookRide(SelectedRideType);
                                        print(
                                            "Selected ride type: $SelectedRideType");
                                        isbooknow = false;

                                        fetchFieldValue();
                                        print('Found: $status');

                                        // Example coordinates (San Francisco to Oakland)
                                        double startLat = 37.7749;
                                        double startLng = -122.4194;
                                        double endLat = 37.8044;
                                        double endLng = -122.2711;

                                        // Average speed (in km/h)
                                        double averageSpeed = 50.0;

                                        _calculateDistanceAndTime(
                                            startLat,
                                            startLng,
                                            endLat,
                                            endLng,
                                            averageSpeed);
                                      },
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.075,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.7,
                                        decoration: BoxDecoration(
                                          color: Color(0xff242426),
                                          borderRadius:
                                              BorderRadius.circular(16),
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
                                    )
                                  : GestureDetector(
                                      onTap: () {},
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.075,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.7,
                                        decoration: BoxDecoration(
                                          color: Color(0xff242426),
                                          borderRadius:
                                              BorderRadius.circular(16),
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
                        ],
                      ),
                    );
                  },
                ),
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
  final bool isSelected;
  final VoidCallback onTap;

  const RideOption({
    required this.type,
    required this.price,
    required this.seats,
    required this.image,
    required this.onTap,
    required this.isSelected,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Call onTap when the option is tapped
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.1,
            width: MediaQuery.of(context).size.width * 0.27,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isSelected
                  ? const Color(0xFFE1E1E1) // Selected color
                  : const Color(0xFF383838), // Initial color
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                image,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                type,
                style: const TextStyle(
                  color: Color(0xFFE1E1E1),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Gelix',
                ),
              ),
              SizedBox(width: 32),
              Row(
                children: [
                  const Icon(Icons.person, color: Color(0xFFE1E1E1), size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '$seats',
                    style: const TextStyle(
                      color: Color(0xFFE1E1E1),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Gelix',
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            price,
            style: const TextStyle(
              color: Color(0xFFE1E1E1),
              fontSize: 16,
              fontWeight: FontWeight.w400,
              fontFamily: 'Gelix',
            ),
          ),
        ],
      ),
    );
  }
}

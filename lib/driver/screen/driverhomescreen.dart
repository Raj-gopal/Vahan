import 'dart:convert';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:latlong2/latlong.dart' as latlong;
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as LocationServices;
import 'package:location/location.dart';
import 'package:vahan/driver/services/services.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:vahan/services/APIsNKeys/Apis.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final _firestore = FirebaseFirestore.instance.collection('usersRequest');
  latlong.LatLng? _currentLocation;
  double rating = 0;
  int starCount = 5;
  String reviewText = "";
  bool _isOnline = false;
  double? _distance;
  double? Dis;
  final firestore =
      FirebaseFirestore.instance.collection('usersRequest').snapshots();
  final ref = FirebaseFirestore.instance.collection('usersRequest');
  double? la;
  double? lo;
  int _index = 0;
  double? DistanceStartToEnd;
  // double? userLat;
  // double? userLng;
  final FirebaseFirestore _firestor = FirebaseFirestore.instance;
  //LatLng? _currentLocation;
  String? _status;
  LatLng? _destination;
  bool _isFoundedCoordinatesFetched =
      false; // Tracks if getCoordinates was called
  bool _isArrivedCoordinatesFetched =
      false; // Tracks if getCoordinates was called
  bool _isStartRideCoordinatesFetched =
      false; // Tracks if getCoordinates was called

  List listofpoint = [];
  List<LatLng> points = [];

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
    _checkDriverStatus(); // Check status on initialization
    _startFirestoreListener();
  }

  Future<void> getCoordinates(
      double startLng, double startLat, double destLng, double destLat) async {
    try {
      var response = await http.get(
        Uri.parse(
          getRouteUrl(startLng, startLat, destLng, destLat),
        ),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);

        // Decode the geometry coordinates
        var listofpoint = responseData['routes'][0]['geometry']['coordinates'];

        // Map to LatLng
        points = listofpoint
            .map<LatLng>((e) => LatLng(e[1].toDouble(), e[0].toDouble()))
            .toList();

        setState(() {}); // Refresh map with new coordinates
      } else {
        print('Failed to load coordinates: ${response.body}');
      }
    } catch (e) {
      print('Error fetching route coordinates: $e');
    }
  }

  String getRouteUrl(
      double startLng, double startLat, double destLng, double destLat) {
    final String apiKey =
        'pk.eyJ1IjoibWFwYm94LW1hcC1kZXNpZ24iLCJhIjoiY2syeHpiaHlrMDJvODNidDR5azU5NWcwdiJ9.x0uSqSWGXdoFKuHZC5Eo_Q';
    return 'https://api.mapbox.com/directions/v5/mapbox/driving/$startLng,$startLat;$destLng,$destLat?alternatives=true&annotations=distance%2Cduration%2Cspeed&geometries=geojson&language=en&overview=full&steps=true&access_token=$apiKey';
  }

  // Haversine formula for calculating distance between driver and rider
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

  /// Fetches the current location of the driver
  Future<void> _fetchCurrentLocation() async {
    try {
      var location = await LocationServices.Location().getLocation();
      setState(() {
        _currentLocation =
            latlong.LatLng(location.latitude!, location.longitude!);
      });
      print(
          "Current Location: ${_currentLocation?.latitude}, ${_currentLocation?.longitude}");
    } catch (e) {
      print('Error fetching location: $e');
    }
  }

  /// Calculates distance from the driver's current location to a given point
  double? _calculateDistanceTo(double lat2, double lon2) {
    if (_currentLocation == null) return null;
    return _haversine(
      _currentLocation!.latitude,
      _currentLocation!.longitude,
      lat2,
      lon2,
    );
  }

  /// Fetch Firestore data and calculate distance for each document
  void _startFirestoreListener() {
    _firestore.snapshots().listen((snapshot) {
      print('Fetched ${snapshot.docs.length} requests');
      for (var doc in snapshot.docs) {
        _processFirestoreDocument(doc);
      }
    });
  }

  /// Process each Firestore document and calculate distance
  void _processFirestoreDocument(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>;
      final double lat2 = data['latitude'] ?? 0.0;
      final double lon2 = data['longitude'] ?? 0.0;

      la = lat2;
      lo = lon2;

      final distance = _calculateDistanceTo(lat2, lon2);

      print('Distance to ${doc.id}: ${distance?.toStringAsFixed(2)} km');
      Dis = distance;
    } catch (e) {
      print('Error processing document ${doc.id}: $e');
    }
  }

  // Check driver status
  Future<void> _checkDriverStatus() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('driverStatus')
          .doc('driver1') // Replace with your driver status doc ID
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          _isOnline = data['status'] == 'ONLINE';
          print('online');
          print(_isOnline);
        });
      }
    } catch (e) {
      print('Error checking driver status: $e');
    }
  }

  void _toggleStatus() async {
    try {
      if (_isOnline) {
        await GeoFireServices.goOffline();
      } else {
        await GeoFireServices.goOnline();
        GeoFireServices.updateLocationRealTime(
            context); // Update location only when going online
      }
      setState(() {
        _isOnline = !_isOnline; // Correctly toggle the state
      });
    } catch (e) {
      print('Error toggling status: $e');
    }
  }

  String _calculateTime(double distanceInKm, double speedInKmPerHr) {
    double timeInHours = distanceInKm / speedInKmPerHr;
    double timeInMinutes = timeInHours * 60;

    return '${timeInMinutes.toStringAsFixed(2)} min'; // Return time in minutes
  }

  void _calculateStarttoEnd(double startLat, double startLng, double endLat,
      double endLng, double speed) {
    double distance = _haversine(startLat, startLng, endLat, endLng);
    String time = _calculateTime(distance, speed);

    // Print or show the results
    print('Distance: ${distance.toStringAsFixed(2)} km');
    print('Time: $time');

    DistanceStartToEnd = distance; // Correct if ArrivalDistance is String
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        if (_currentLocation != null)
          StreamBuilder<QuerySnapshot>(
            stream: _firestor.collection('usersRequest').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              // if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              //   return Center(child: Text('No data available'));
              // }

              final docs = snapshot.data!.docs;
              final data = docs.first.data() as Map<String, dynamic>;

              _status = data['status']?.toString() ?? 'Unknown';
              double? startLat = data['latitude'] != null
                  ? double.tryParse(data['latitude'].toString())
                  : null;
              double? startLng = data['longitude'] != null
                  ? double.tryParse(data['longitude'].toString())
                  : null;
              double? destLat = data['dest_latitude'] != null
                  ? double.tryParse(data['dest_latitude'].toString())
                  : null;
              double? destLng = data['dest_longitude'] != null
                  ? double.tryParse(data['dest_longitude'].toString())
                  : null;

              if (startLat != null && startLng != null) {
                _currentLocation = LatLng(startLat, startLng);
              }
              if (destLat != null && destLng != null) {
                _destination = LatLng(destLat, destLng);
              }
              if (_status == 'Founded' && !_isFoundedCoordinatesFetched) {
                _isFoundedCoordinatesFetched = true;

                getCoordinates(startLng!, startLat!, destLng!, destLat!);
              }
              if (_status == 'Arrived' && !_isArrivedCoordinatesFetched) {
                _isArrivedCoordinatesFetched = true;

                getCoordinates(startLng!, startLat!, destLng!, destLat!);
              }
              if (_status == 'Start_Ride' && !_isStartRideCoordinatesFetched) {
                _isStartRideCoordinatesFetched = true;

                getCoordinates(startLng!, startLat!, destLng!, destLat!);
              }

              return (_status == 'Founded' ||
                      _status == 'Arrived' ||
                      _status == 'Start_Ride' ||
                      _status == 'Review')
                  ? Expanded(
                      child: FlutterMap(
                        options: MapOptions(
                          center: _currentLocation,
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
                                point: _currentLocation!,
                                child: Container(
                                  height: 16,
                                  width: 16,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: Image.asset('assets/images/cab.png'),
                                ),
                                // builder: (ctx) => Icon(Icons.location_pin, color: Colors.red),
                              ),
                              Marker(
                                point: _destination!,
                                child: Container(
                                  height: 16,
                                  width: 16,
                                  decoration: BoxDecoration(
                                    color: Color(0xffB3FD14),
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                //  builder: (ctx) => Icon(Icons.flag, color: Colors.green),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : FlutterMap(
                      options: MapOptions(
                        center: _currentLocation,
                        zoom: 13,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://api.mapbox.com/styles/v1/mapbox/dark-v10/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1IjoibWFwYm94LW1hcC1kZXNpZ24iLCJhIjoiY2syeHpiaHlrMDJvODNidDR5azU5NWcwdiJ9.x0uSqSWGXdoFKuHZC5Eo_Q',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _currentLocation!,
                              child: Container(
                                height: 16,
                                width: 16,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: Image.asset('assets/images/cab.png'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
            },
          ),
        if (_currentLocation == null)
          Container(
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xffB3FD14),
              ),
            ),
          ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.08,
          left: 16,
          right: 16,
          child: _buildSwipeButton(
            label: _isOnline ? 'Swipe to go Offline' : 'Swipe to go Online',
            onSwipe: () {
              _isOnline ? print("Going Offline...") : print("Going Online...");
              // ScaffoldMessenger.of(context).showSnackBar(

              //   SnackBar(
              //     content: Text(
              //       _isOnline ? "Going Offline..." : "Going Online...",
              //       style: TextStyle(
              //         color: Color(0xff797979),
              //         fontSize: 20,
              //         fontFamily: 'Gelix',
              //       ),
              //     ),
              //     backgroundColor: const Color(0xff242426),
              //   ),
              // );
              _toggleStatus();
            },
          ),
        ),
        (_isOnline )
            ? Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.578,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    color: Color(0xff191A1A),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: firestore,
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: SizedBox(
                              height: 32,
                              width: 32,
                              child: CircularProgressIndicator(
                                color: Color(0xffB3FD14),
                              ),
                            ),
                          );
                        }

                        if (snapshot.hasError ||
                            !snapshot.hasData ||
                            snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Text(
                              "No data available",
                              style: TextStyle(
                                color: Color(0xff797979),
                                fontSize: 20,
                                fontFamily: 'Gelix',
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: 1,
                          itemBuilder: (context, index) {
                            final doc = snapshot.data!.docs[_index];
                            final number = doc['number'].toString();
                            final status = doc['status'].toString();

                            // Example coordinates (San Francisco to Oakland)
                            double startLat = doc['latitude'];
                            double startLng = doc['longitude'];
                            double endLat = doc['dest_latitude'];
                            double endLng = doc['dest_longitude'];

                            // Average speed (in km/h)
                            double averageSpeed = 30.0;

                            _calculateStarttoEnd(startLat, startLng, endLat,
                                endLng, averageSpeed);

                            // // If status is 'Founded', don't display the item
                            // if (status == 'Founded') {
                            //   return SizedBox.shrink();
                            // }

                            // If no number available, show this item with "No number available"
                            if (number.isEmpty) {
                              return Container(
                                height: MediaQuery.of(context).size.height * .2,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.transparent,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.only(left: 16, right: 16),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: 56,
                                        width: 56,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: Image.asset(
                                          'assets/images/banner.png',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            doc['name'].toString(),
                                            style: TextStyle(
                                              color: Color(0xff797979),
                                              fontSize: 16,
                                              fontFamily: 'Gelix',
                                            ),
                                          ),
                                          Text(
                                            "No number available",
                                            style: TextStyle(
                                              color: Color(0xff797979),
                                              fontSize: 12,
                                              fontFamily: 'Gelix',
                                            ),
                                          ),
                                        ],
                                      ),
                                      Spacer(),
                                      Icon(Icons.call),
                                      IconButton(
                                        onPressed: () {
                                          ref
                                              .doc(doc['email'].toString())
                                              .update({
                                            'status': 'Founded',
                                            'driver name': 'Driver',
                                            'driver_car_num': '1234',
                                          }).then((value) {
                                            print('updated');
                                          }).onError((error, stackTrace) {
                                            print('error');
                                          });
                                        },
                                        icon: Icon(Icons.arrow_circle_right),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            // Text(
                            //     'Current Location: ${_currentLocation?.latitude}, ${_currentLocation?.longitude}');
                            // print('Fire Location: ${la},${lo}');
                            // Text(
                            //     'Distance: ${Distance ?? 'Calculating...'} km');
                            // Text(
                            //     'Driver Status: ${_isOnline ? 'Online' : 'Offline'}');

                            return
                                // (status == 'Searching') ?
                                (status == 'Founded')
                                    ? Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: Colors.transparent,
                                        ),
                                        child: Column(
                                          children: [
                                            // ClipRRect(
                                            //   borderRadius:
                                            //       BorderRadius.circular(
                                            //           8.0),
                                            //   child:
                                            //       LinearProgressIndicator(
                                            //     value: 0.75,
                                            //     color: Color(0xffB3FD14),
                                            //     backgroundColor:
                                            //         Color(0xff383838),
                                            //   ),
                                            // ),
                                            //SizedBox(height: 16),
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
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 45,
                                                      backgroundImage: AssetImage(
                                                          'assets/images/user.jpg'),
                                                    ),
                                                    SizedBox(width: 16),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          doc['name']
                                                              .toString(),
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xffD0CCCC),
                                                            fontSize: 20,
                                                            fontFamily: 'Gelix',
                                                          ),
                                                        ),
                                                        Text(
                                                          number,
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xffD0CCCC),
                                                            fontSize: 16,
                                                            fontFamily: 'Gelix',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Spacer(),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          '₹ ' +
                                                              (DistanceStartToEnd! *
                                                                      50)
                                                                  .toStringAsFixed(
                                                                      2),
                                                          textAlign:
                                                              TextAlign.right,
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xffD0CCCC),
                                                            fontSize: 20,
                                                            fontFamily: 'Gelix',
                                                          ),
                                                        ),
                                                        Row(
                                                          children: [
                                                            Text(
                                                              DistanceStartToEnd!
                                                                      .toStringAsFixed(
                                                                          2) +
                                                                  ' Km .',
                                                              textAlign:
                                                                  TextAlign
                                                                      .right,
                                                              style: TextStyle(
                                                                color: Color(
                                                                    0xffD0CCCC),
                                                                fontSize: 16,
                                                                fontFamily:
                                                                    'Gelix',
                                                              ),
                                                            ),
                                                            Text(
                                                              ' ' +
                                                                  doc['time']
                                                                      .toString(),
                                                              textAlign:
                                                                  TextAlign
                                                                      .right,
                                                              style: TextStyle(
                                                                color: Color(
                                                                    0xffB3FD14),
                                                                fontSize: 16,
                                                                fontFamily:
                                                                    'Gelix',
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 24),
                                            Row(
                                              children: [
                                                Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      .06,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      .77,
                                                  decoration: BoxDecoration(
                                                    color: Color(0xff242426),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 16,
                                                            top: 14,
                                                            bottom: 14),
                                                    child: Text(
                                                      'Add Message',
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xffD0CCCC),
                                                        fontSize: 16,
                                                        fontFamily: 'Gelix',
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Spacer(),
                                                Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      .06,
                                                  decoration: BoxDecoration(
                                                      color: Color(0xff242426),
                                                      shape: BoxShape.circle),
                                                  child: Center(
                                                      child: IconButton(
                                                    onPressed: () {
                                                      final Uri url = Uri(
                                                        scheme: 'tel',
                                                        path: doc['number']
                                                            .toString(),
                                                      );
                                                    },
                                                    icon: Icon(
                                                      Icons.call,
                                                      color: Color(0xffD0CCCC),
                                                    ),
                                                  )),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 24),
                                            Row(
                                              children: [
                                                Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      Container(
                                                        height: 24,
                                                        width: 24,
                                                        decoration:
                                                            BoxDecoration(
                                                                color: Color(
                                                                    0xff383838),
                                                                shape: BoxShape
                                                                    .circle),
                                                      ),
                                                      Container(
                                                        height: 16,
                                                        width: 16,
                                                        decoration:
                                                            BoxDecoration(
                                                                color: Color(
                                                                    0xffB3FD14),
                                                                shape: BoxShape
                                                                    .circle),
                                                      ),
                                                    ]),
                                                SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    doc['pick_up'].toString(),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: Color(0xffD0CCCC),
                                                      fontSize: 20,
                                                      fontFamily: 'Gelix',
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 8),
                                            Divider(
                                              thickness: 1,
                                              color: Color(0xff383838),
                                            ),
                                            SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      Container(
                                                        height: 24,
                                                        width: 24,
                                                        decoration:
                                                            BoxDecoration(
                                                                color: Color(
                                                                    0xffE1E1E1),
                                                                shape: BoxShape
                                                                    .circle),
                                                      ),
                                                      Container(
                                                        height: 16,
                                                        width: 16,
                                                        decoration:
                                                            BoxDecoration(
                                                                color: Color(
                                                                    0xff383838),
                                                                shape: BoxShape
                                                                    .circle),
                                                      ),
                                                    ]),
                                                SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    doc['drop_loc'].toString(),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: Color(0xffD0CCCC),
                                                      fontSize: 20,
                                                      fontFamily: 'Gelix',
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 24,
                                            ),
                                            Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _index++;
                                                      print(_index);
                                                    });
                                                  },
                                                  child: Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.075,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.16,
                                                    decoration: BoxDecoration(
                                                      color: Color(0xff242426),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                    ),
                                                    child: Icon(
                                                      Icons.close_rounded,
                                                      color: Color(0xffF2613F),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 16,
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    ref
                                                        .doc(doc['email']
                                                            .toString())
                                                        .update({
                                                      'status': 'Arrived',
                                                    }).then((value) {
                                                      print('updated');
                                                    }).onError((error,
                                                            stackTrace) {
                                                      print('error');
                                                    });
                                                  },
                                                  child: Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.075,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.7,
                                                    decoration: BoxDecoration(
                                                      color: Color(0xff242426),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                    ),
                                                    child: Center(
                                                        child: Text(
                                                      'Arrived',
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xffB3FD14),
                                                        fontSize: 20,
                                                        fontFamily: 'Gelix',
                                                      ),
                                                    )),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    : (status == 'Arrived')
                                        ? Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: Colors.transparent,
                                            ),
                                            child: Column(
                                              children: [
                                                // ClipRRect(
                                                //   borderRadius:
                                                //       BorderRadius.circular(
                                                //           8.0),
                                                //   child:
                                                //       LinearProgressIndicator(
                                                //     value: 0.75,
                                                //     color: Color(0xffB3FD14),
                                                //     backgroundColor:
                                                //         Color(0xff383838),
                                                //   ),
                                                // ),
                                                //SizedBox(height: 16),
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
                                                              .center,
                                                      children: [
                                                        CircleAvatar(
                                                          radius: 45,
                                                          backgroundImage:
                                                              AssetImage(
                                                                  'assets/images/user.jpg'),
                                                        ),
                                                        SizedBox(width: 16),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                              doc['name']
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
                                                              number,
                                                              style: TextStyle(
                                                                color: Color(
                                                                    0xffD0CCCC),
                                                                fontSize: 16,
                                                                fontFamily:
                                                                    'Gelix',
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Spacer(),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                              '₹ ' +
                                                                  (DistanceStartToEnd! *
                                                                          50)
                                                                      .toStringAsFixed(
                                                                          2),
                                                              textAlign:
                                                                  TextAlign
                                                                      .right,
                                                              style: TextStyle(
                                                                color: Color(
                                                                    0xffD0CCCC),
                                                                fontSize: 20,
                                                                fontFamily:
                                                                    'Gelix',
                                                              ),
                                                            ),
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  DistanceStartToEnd!
                                                                          .toStringAsFixed(
                                                                              2) +
                                                                      ' Km .',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .right,
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
                                                                Text(
                                                                  ' ' +
                                                                      doc['time']
                                                                          .toString(),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .right,
                                                                  style:
                                                                      TextStyle(
                                                                    color: Color(
                                                                        0xffB3FD14),
                                                                    fontSize:
                                                                        16,
                                                                    fontFamily:
                                                                        'Gelix',
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 24),
                                                Row(
                                                  children: [
                                                    Container(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              .06,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .77,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Color(0xff242426),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 16,
                                                                top: 14,
                                                                bottom: 14),
                                                        child: Text(
                                                          'Add Message',
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xffD0CCCC),
                                                            fontSize: 16,
                                                            fontFamily: 'Gelix',
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Spacer(),
                                                    Container(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              .06,
                                                      decoration: BoxDecoration(
                                                          color:
                                                              Color(0xff242426),
                                                          shape:
                                                              BoxShape.circle),
                                                      child: Center(
                                                          child: IconButton(
                                                        onPressed: () {
                                                          final Uri url = Uri(
                                                            scheme: 'tel',
                                                            path: doc['number']
                                                                .toString(),
                                                          );
                                                        },
                                                        icon: Icon(
                                                          Icons.call,
                                                          color:
                                                              Color(0xffD0CCCC),
                                                        ),
                                                      )),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 24),
                                                Row(
                                                  children: [
                                                    Stack(
                                                        alignment:
                                                            Alignment.center,
                                                        children: [
                                                          Container(
                                                            height: 24,
                                                            width: 24,
                                                            decoration: BoxDecoration(
                                                                color: Color(
                                                                    0xff383838),
                                                                shape: BoxShape
                                                                    .circle),
                                                          ),
                                                          Container(
                                                            height: 16,
                                                            width: 16,
                                                            decoration: BoxDecoration(
                                                                color: Color(
                                                                    0xffB3FD14),
                                                                shape: BoxShape
                                                                    .circle),
                                                          ),
                                                        ]),
                                                    SizedBox(width: 12),
                                                    Expanded(
                                                      child: Text(
                                                        doc['pick_up']
                                                            .toString(),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          color:
                                                              Color(0xffD0CCCC),
                                                          fontSize: 20,
                                                          fontFamily: 'Gelix',
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 8),
                                                Divider(
                                                  thickness: 1,
                                                  color: Color(0xff383838),
                                                ),
                                                SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    Stack(
                                                        alignment:
                                                            Alignment.center,
                                                        children: [
                                                          Container(
                                                            height: 24,
                                                            width: 24,
                                                            decoration: BoxDecoration(
                                                                color: Color(
                                                                    0xffE1E1E1),
                                                                shape: BoxShape
                                                                    .circle),
                                                          ),
                                                          Container(
                                                            height: 16,
                                                            width: 16,
                                                            decoration: BoxDecoration(
                                                                color: Color(
                                                                    0xff383838),
                                                                shape: BoxShape
                                                                    .circle),
                                                          ),
                                                        ]),
                                                    SizedBox(width: 12),
                                                    Expanded(
                                                      child: Text(
                                                        doc['drop_loc']
                                                            .toString(),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          color:
                                                              Color(0xffD0CCCC),
                                                          fontSize: 20,
                                                          fontFamily: 'Gelix',
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 24,
                                                ),
                                                Row(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          _index++;
                                                          print(_index);
                                                        });
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
                                                            0.16,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Color(0xff242426),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(16),
                                                        ),
                                                        child: Icon(
                                                          Icons.close_rounded,
                                                          color:
                                                              Color(0xffF2613F),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 16,
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        ref
                                                            .doc(doc['email']
                                                                .toString())
                                                            .update({
                                                          'status':
                                                              'Start_Ride',
                                                        }).then((value) {
                                                          print('updated');
                                                        }).onError((error,
                                                                stackTrace) {
                                                          print('error');
                                                        });
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
                                                            0.7,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Color(0xff242426),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(16),
                                                        ),
                                                        child: Center(
                                                            child: Text(
                                                          'Start Ride',
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xffB3FD14),
                                                            fontSize: 20,
                                                            fontFamily: 'Gelix',
                                                          ),
                                                        )),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          )
                                        : (status == 'Start_Ride')
                                            ? Center(
                                                child: Column(
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
                                                                        'assets/images/user.jpg'),
                                                              ),
                                                              SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
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
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                              doc['name']
                                                                  .toString(),
                                                                            style:
                                                                                TextStyle(
                                                                              color: Color(0xffD0CCCC),
                                                                              fontSize: 20,
                                                                              fontFamily: 'Gelix',
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                            doc['number']
                                                                                .toString(),
                                                                            style:
                                                                                TextStyle(
                                                                              color: Color(0xffD0CCCC),
                                                                              fontSize: 20,
                                                                              fontFamily: 'Gelix',
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      // SizedBox(
                                                                      //   width: MediaQuery.of(context).size.width *
                                                                      //       .4,
                                                                      // ),
                                                                      // Text(
                                                                      //   doc['car_type']
                                                                      //       .toString(),
                                                                      //   style:
                                                                      //       TextStyle(
                                                                      //     color:
                                                                      //         Color(0xffD0CCCC),
                                                                      //     fontSize:
                                                                      //         20,
                                                                      //     fontFamily:
                                                                      //         'Gelix',
                                                                      //   ),
                                                                      // ),
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
                                                    SizedBox(
                                                      height: 32,
                                                    ),
                                                    Text(
                                                      'How would you rate your driver?',
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xffD0CCCC),
                                                        fontSize: 20,
                                                        fontFamily: 'Gelix',
                                                      ),
                                                    ),
                                                    SizedBox(height: 16),
                                                    StarRating(
                                                      size: 40.0,
                                                      rating: rating,
                                                      color: Color(0xffFBBC05),
                                                      borderColor:
                                                          Color(0xffE1E1E1)
                                                              .withOpacity(.4),
                                                      allowHalfRating: false,
                                                      starCount: starCount,
                                                      onRatingChanged:
                                                          (rating) =>
                                                              setState(() {
                                                        this.rating = rating;
                                                        print(rating);
                                                      }),
                                                    ),
                                                    SizedBox(height: 96),
                                                    GestureDetector(
                                                      onTap: () {
                                                        ref.doc(doc['email'])
                                                            .delete();
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        DriverHomeScreen()));
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
                                                          color:
                                                              Color(0xff242426),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(16),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            'Submit',
                                                            style: TextStyle(
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
                                            : Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  color: Colors.transparent,
                                                ),
                                                child: Column(
                                                  children: [
                                                    // ClipRRect(
                                                    //   borderRadius:
                                                    //       BorderRadius.circular(
                                                    //           8.0),
                                                    //   child:
                                                    //       LinearProgressIndicator(
                                                    //     value: 0.75,
                                                    //     color: Color(0xffB3FD14),
                                                    //     backgroundColor:
                                                    //         Color(0xff383838),
                                                    //   ),
                                                    // ),
                                                    //SizedBox(height: 16),
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
                                                                  .center,
                                                          children: [
                                                            CircleAvatar(
                                                              radius: 45,
                                                              backgroundImage:
                                                                  AssetImage(
                                                                      'assets/images/user.jpg'),
                                                            ),
                                                            SizedBox(width: 16),
                                                            Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Text(
                                                                  doc['name']
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
                                                                  number,
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
                                                              ],
                                                            ),
                                                            Spacer(),
                                                            Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .end,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Text(
                                                                  '₹ ' +
                                                                      (DistanceStartToEnd! *
                                                                              50)
                                                                          .toStringAsFixed(
                                                                              2),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .right,
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
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                      DistanceStartToEnd!
                                                                              .toStringAsFixed(2) +
                                                                          ' Km .',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .right,
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
                                                                    Text(
                                                                      ' ' +
                                                                          doc['time']
                                                                              .toString(),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .right,
                                                                      style:
                                                                          TextStyle(
                                                                        color: Color(
                                                                            0xffB3FD14),
                                                                        fontSize:
                                                                            16,
                                                                        fontFamily:
                                                                            'Gelix',
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 24),
                                                    Row(
                                                      children: [
                                                        Container(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              .06,
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              .77,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Color(
                                                                0xff242426),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 16,
                                                                    top: 14,
                                                                    bottom: 14),
                                                            child: Text(
                                                              'Add Message',
                                                              style: TextStyle(
                                                                color: Color(
                                                                    0xffD0CCCC),
                                                                fontSize: 16,
                                                                fontFamily:
                                                                    'Gelix',
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Spacer(),
                                                        Container(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              .06,
                                                          decoration: BoxDecoration(
                                                              color: Color(
                                                                  0xff242426),
                                                              shape: BoxShape
                                                                  .circle),
                                                          child: Center(
                                                              child: IconButton(
                                                            onPressed: () {
                                                              final Uri url =
                                                                  Uri(
                                                                scheme: 'tel',
                                                                path: doc[
                                                                        'number']
                                                                    .toString(),
                                                              );
                                                            },
                                                            icon: Icon(
                                                              Icons.call,
                                                              color: Color(
                                                                  0xffD0CCCC),
                                                            ),
                                                          )),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 24),
                                                    Row(
                                                      children: [
                                                        Stack(
                                                            alignment: Alignment
                                                                .center,
                                                            children: [
                                                              Container(
                                                                height: 24,
                                                                width: 24,
                                                                decoration: BoxDecoration(
                                                                    color: Color(
                                                                        0xff383838),
                                                                    shape: BoxShape
                                                                        .circle),
                                                              ),
                                                              Container(
                                                                height: 16,
                                                                width: 16,
                                                                decoration: BoxDecoration(
                                                                    color: Color(
                                                                        0xffB3FD14),
                                                                    shape: BoxShape
                                                                        .circle),
                                                              ),
                                                            ]),
                                                        SizedBox(width: 12),
                                                        Expanded(
                                                          child: Text(
                                                            doc['pick_up']
                                                                .toString(),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              color: Color(
                                                                  0xffD0CCCC),
                                                              fontSize: 20,
                                                              fontFamily:
                                                                  'Gelix',
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 8),
                                                    Divider(
                                                      thickness: 1,
                                                      color: Color(0xff383838),
                                                    ),
                                                    SizedBox(height: 8),
                                                    Row(
                                                      children: [
                                                        Stack(
                                                            alignment: Alignment
                                                                .center,
                                                            children: [
                                                              Container(
                                                                height: 24,
                                                                width: 24,
                                                                decoration: BoxDecoration(
                                                                    color: Color(
                                                                        0xffE1E1E1),
                                                                    shape: BoxShape
                                                                        .circle),
                                                              ),
                                                              Container(
                                                                height: 16,
                                                                width: 16,
                                                                decoration: BoxDecoration(
                                                                    color: Color(
                                                                        0xff383838),
                                                                    shape: BoxShape
                                                                        .circle),
                                                              ),
                                                            ]),
                                                        SizedBox(width: 12),
                                                        Expanded(
                                                          child: Text(
                                                            doc['drop_loc']
                                                                .toString(),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              color: Color(
                                                                  0xffD0CCCC),
                                                              fontSize: 20,
                                                              fontFamily:
                                                                  'Gelix',
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 24,
                                                    ),
                                                    Row(
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              _index++;
                                                              print(_index);
                                                            });
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
                                                            child: Icon(
                                                              Icons
                                                                  .close_rounded,
                                                              color: Color(
                                                                  0xffF2613F),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 16,
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            ref
                                                                .doc(doc[
                                                                        'email']
                                                                    .toString())
                                                                .update({
                                                              'status':
                                                                  'Founded',
                                                              'driver name':
                                                                  'Driver',
                                                              'driver_car_num':
                                                                  '1234',
                                                              'driver_lat':
                                                                  _currentLocation!
                                                                      .latitude,
                                                              'driver_long':
                                                                  _currentLocation!
                                                                      .longitude,
                                                            }).then((value) {
                                                              print('updated');
                                                            }).onError((error,
                                                                    stackTrace) {
                                                              print('error');
                                                            });
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
                                                                0.7,
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
                                                              'Accept',
                                                              style: TextStyle(
                                                                color: Color(
                                                                    0xffB3FD14),
                                                                fontSize: 20,
                                                                fontFamily:
                                                                    'Gelix',
                                                              ),
                                                            )),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              );
                            //   }

                            //  return SizedBox.shrink();
                          },
                        );
                      },
                    ),
                  ),
                ))
            : SizedBox.shrink()
      ]),
    );
  }

  Widget _buildSwipeButton(
      {required String label, required VoidCallback onSwipe}) {
    return SwipeButton(
      height: MediaQuery.of(context).size.height * 0.08,
      thumbPadding: const EdgeInsets.all(8),
      thumb: const Icon(
        Icons.chevron_right,
        color: Color(0xff242426),
      ),
      elevationThumb: 2,
      elevationTrack: 2,
      child: Text(
        label,
        style: TextStyle(
          color: Color(0xff797979),
          fontSize: 20,
          fontFamily: 'Gelix',
        ),
      ),
      activeTrackColor: const Color(0xff242426),
      activeThumbColor: const Color(0xffB3FD14),
      inactiveTrackColor: const Color(0xff242426),
      onSwipe: onSwipe,
    );
  }
}

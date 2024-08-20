import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:latlong2/latlong.dart' as latlong;
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:vahan/driver/services/services.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {

  final firestore = FirebaseFirestore.instance.collection('usersRequest').snapshots();
  final ref = FirebaseFirestore.instance.collection('usersRequest');

  latlong.LatLng? _currentLocation;
  bool _isOnline = false; // Track current online/offline status

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
    _checkDriverStatus(); // Check status on initialization
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      gmap.LatLng location = await LocationServices.getCurrentLocation();
      setState(() {
        _currentLocation = latlong.LatLng(location.latitude, location.longitude);
      });
    } catch (e) {
      print('Error fetching location: $e');
    }
  }

  Future<void> _checkDriverStatus() async {
    try {
      DocumentSnapshot snapshot = await GeoFireServices.getDriverStatusDocument();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          _isOnline = data['status'] == 'ONLINE';
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
        GeoFireServices.updateLocationRealTime(context); // Update location only when going online
      }
      setState(() {
        _isOnline = !_isOnline; // Correctly toggle the state
      });
    } catch (e) {
      print('Error toggling status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_currentLocation != null)
            FlutterMap(
              options: MapOptions(
                center: _currentLocation,
                zoom: 17,
                maxZoom: 18.0, // Example: Set a max zoom level
                minZoom: 13.0, // Example: Set a min zoom level
              ),
              children: [
                TileLayer(
                  urlTemplate:
                  'https://api.mapbox.com/styles/v1/mapbox/dark-v10/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1IjoibWFwYm94LW1hcC1kZXNpZ24iLCJhIjoiY2syeHpiaHlrMDJvODNidDR5azU5NWcwdiJ9.x0uSqSWGXdoFKuHZC5Eo_Q',
                ),
              ],
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _isOnline ? "Going Offline..." : "Going Online...",
                      style: TextStyle(
                        color: Color(0xff797979),
                        fontSize: 20,
                        fontFamily: 'Gelix',
                      ),),
                    backgroundColor: const Color(0xff242426),
                  ),
                );
                _toggleStatus();
              },
            ),
          ),
          Positioned(
            bottom: 32,
            left: 16,
            right: 16,
            child: Container(
              height: MediaQuery.of(context).size.height * .5,

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Color(0xff191A1A),
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: firestore,
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
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

                  if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
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
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final doc = snapshot.data!.docs[index];
                      final number = doc['number'].toString();
                      final status = doc['status'].toString();

                      if (status == 'Founded') {
                        return SizedBox.shrink(); // Don't display this item
                      }

                      if (number.isEmpty) {
                        return Container(
                          height: MediaQuery.of(context).size.height * .2,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Color(0xff383838),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(top: 24, left: 16, right: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 64,
                                  width: 64,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Image.asset(
                                    'assets/images/banner.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(width: 16,),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                    ref.doc(doc['email'].toString()).update({
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

                      return Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        child: Container(
                          height: MediaQuery.of(context).size.height * .2,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Color(0xff383838),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(top: 24, left: 16, right: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 64,
                                  width: 64,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Image.asset(
                                    'assets/images/banner.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(width: 16,),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                      number,
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
                                    ref.doc(doc['email'].toString()).update({
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
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeButton({required String label, required VoidCallback onSwipe}) {
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

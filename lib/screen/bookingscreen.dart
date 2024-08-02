import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:maptiler_flutter/maptiler_flutter.dart';

import '../services/APIsNKeys/Apis.dart';

class BookingScreen extends StatefulWidget {
  final LatLng startLocation;
  final LatLng nextLocation;


  const BookingScreen({Key? key, required this.startLocation, required this.nextLocation}) : super(key: key);

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {


  @override
  void initState() {
    getCoordinates();
    super.initState();
  }

  List listofpoint = [];
  List<LatLng> points = [];

  // Function to consume the Mapbox API
  getCoordinates() async {
    var response = await http.get(
      getRouteUrl(
        '${widget.startLocation.longitude}',
        '${widget.startLocation.latitude}',
        '${widget.nextLocation.longitude}',
        '${widget.nextLocation.latitude}',
      ),
    );

    setState(() {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        listofpoint = data['routes'][0]['geometry']['coordinates'];
        points = listofpoint
            .map<LatLng>((e) => LatLng(e[1].toDouble(), e[0].toDouble()))
            .toList();
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
              center: LatLng(widget.startLocation.latitude, widget.startLocation.longitude),
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
                    point: LatLng(widget.startLocation.latitude, widget.startLocation.longitude),
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
                    point: LatLng(widget.nextLocation.latitude, widget.nextLocation.longitude),
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
                          'Mani Casadona IT Building, New...',
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
                          'Howrah Railway Station, Kolkata...',
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
                      ),
                      RideOption(
                        image: 'assets/images/car.png',
                        type: 'Mini',
                        price: '₹80.00',
                        seats: 4,
                      ),
                      RideOption(
                        image: 'assets/images/car.png',
                        type: 'Sedan',
                        price: '₹120.00',
                        seats: 4,
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: getCoordinates,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.085,
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

  RideOption({
    required this.type,
    required this.price,
    required this.seats,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}

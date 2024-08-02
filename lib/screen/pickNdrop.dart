import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:vahan/screen/bookingscreen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Map<String, dynamic>> parsedResponses = [];
  TextEditingController startController = TextEditingController();
  TextEditingController nextController = TextEditingController();
  LatLng? startLocation;
  LatLng? nextLocation;
  bool isEditingStart = true; // Track which text field is active

  final String mapboxApiKey = 'pk.eyJ1IjoicmFqZ2siLCJhIjoiY2x6NThlNDJlNDZ4ODJxczYzMnNpdGhxayJ9.NBTbcDPIefKRWhsHP8LrMA';

  Future<void> fetchLocations(String query) async {
    if (query.isEmpty) {
      setState(() {
        parsedResponses = [];
      });
      return;
    }

    final url = Uri.parse(
        'https://api.mapbox.com/geocoding/v5/mapbox.places/$query.json?access_token=$mapboxApiKey');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List features = data['features'];
        setState(() {
          parsedResponses = features.map<Map<String, dynamic>>((feature) {
            return {
              'name': feature['text'],
              'address': feature['place_name'],
              'location': LatLng(feature['center'][1], feature['center'][0]),
            };
          }).toList();
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }
  void handleSelection(Map<String, dynamic> location) {
    setState(() {
      if (isEditingStart) {
        startController.text = location['address'];
        startLocation = location['location'];
      } else {
        nextController.text = location['address'];
        nextLocation = location['location'];
      }

      parsedResponses = []; // Clear suggestions after selection
    });

    // Check if both locations are set, then navigate
    if (startController.text.isNotEmpty && nextController.text.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookingScreen(
            startLocation: startLocation!,
            nextLocation: nextLocation!,
          ),
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.only(left: 16, right: 14, top: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  child: TextField(
                    controller: startController,
                    cursorColor: Color(0xffB3FD14),
                    style: TextStyle(
                      color: Color(0xff797979),
                      fontSize: 20,
                      fontFamily: 'Gelix',
                    ),
                    decoration: InputDecoration(
                      hintText: 'Where from?',
                      hintStyle: TextStyle(
                        color: Color(0xff797979),
                        fontSize: 20,
                        fontFamily: 'Gelix',
                      ),
                      filled: true,
                      fillColor: Color(0xff242426),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      isEditingStart = true;
                      fetchLocations(value);
                    },
                    onTap: () {
                      setState(() {
                        isEditingStart = true;
                        parsedResponses = [];
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Container(
                  height: 24,
                  width: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Color(0xffB3FD14),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: nextController,
                    cursorColor: Color(0xffB3FD14),
                    style: TextStyle(
                      color: Color(0xff797979),
                      fontSize: 20,
                      fontFamily: 'Gelix',
                    ),
                    decoration: InputDecoration(
                      hintText: 'Where next?',
                      hintStyle: TextStyle(
                        color: Color(0xff797979),
                        fontSize: 20,
                        fontFamily: 'Gelix',
                      ),
                      filled: true,
                      fillColor: Color(0xff242426),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      isEditingStart = false;
                      fetchLocations(value);
                    },
                    onTap: () {
                      setState(() {
                        isEditingStart = false;
                        parsedResponses = [];
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: parsedResponses.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      ListTile(
                        onTap: () {
                          handleSelection(parsedResponses[index]);
                        },
                        leading: const SizedBox(
                          height: double.infinity,
                          child: CircleAvatar(
                            backgroundColor: Color(0xffB3FD14),
                            child: Icon(Icons.location_on, color: Colors.white),
                          ),
                        ),
                        title: Text(
                          parsedResponses[index]['name'],
                          style: TextStyle(
                            color: Color(0xffE1E1E1),
                            fontSize: 20,
                            fontFamily: 'Gelix',
                          ),
                        ),
                        subtitle: Text(
                          parsedResponses[index]['address'],
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xff797979),
                            fontSize: 18,
                            fontFamily: 'Gelix',
                          ),
                        ),
                      ),
                      const Divider(color: Color(0xff242426)),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

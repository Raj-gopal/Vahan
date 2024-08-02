import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';// This import is not used in the current code
import 'package:latlong2/latlong.dart';
import 'package:vahan/screen/pickNdrop.dart';
import 'package:flutter_map/flutter_map.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * .25,
              child: Image.asset('assets/images/Vahan.png'),
            ),
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.yellow,
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(left: 16, right: 14, top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * .075,
                decoration: BoxDecoration(
                  color: Color(0xff242426),
                  borderRadius: BorderRadius.circular(64),
                ),
                child: Padding(
                  padding: EdgeInsets.only(left: 24),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        size: 24,
                        color: Color(0xff797979),
                      ),
                      SizedBox(width: 16),
                      Text(
                        'Where to?',
                        style: TextStyle(
                          color: Color(0xff797979),
                          fontSize: 20,
                          fontFamily: 'Gelix',
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * .16,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 4, bottom: 5),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SearchScreen()),
                            );
                          },
                          child: Container(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width * .37,
                            decoration: BoxDecoration(
                              color: Color(0xffB3FD14),
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Search',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontFamily: 'Gelix',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * .02),
              Text(
                'Current Location',
                style: TextStyle(
                  color: Color(0xffE1E1E1),
                  fontSize: 20,
                  fontFamily: 'Gelix',
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * .015,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  height: MediaQuery.of(context).size.height * .4,
                  width: MediaQuery.of(context).size.width,
                  child: FlutterMap(
                    options: MapOptions(
                      center: LatLng(37.9757, 23.7126),
                      zoom: 12,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://api.mapbox.com/styles/v1/mapbox/dark-v10/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1IjoibWFwYm94LW1hcC1kZXNpZ24iLCJhIjoiY2syeHpiaHlrMDJvODNidDR5azU5NWcwdiJ9.x0uSqSWGXdoFKuHZC5Eo_Q',
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * .02),
              Text(
                'More ways to use Vahan',
                style: TextStyle(
                  color: Color(0xffE1E1E1),
                  fontSize: 20,
                  fontFamily: 'Gelix',
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * .02),
              Container(
                height: 200.0,
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width * .7,
                      decoration: BoxDecoration(
                        color: Color(0xff242426),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Image.asset('assets/images/banner.png', fit: BoxFit.fitWidth,),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * .08),
                    Container(
                      width: MediaQuery.of(context).size.width * .8,
                      decoration: BoxDecoration(
                        color: Color(0xff242426),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * .08),
                    Container(
                      width: MediaQuery.of(context).size.width * .7,
                      decoration: BoxDecoration(
                        color: Color(0xff242426),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * .08),
                    Container(
                      width: MediaQuery.of(context).size.width * .7,
                      decoration: BoxDecoration(
                        color: Color(0xff242426),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * .08),
                    Container(
                      width: MediaQuery.of(context).size.width * .7,
                      decoration: BoxDecoration(
                        color: Color(0xff242426),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        height: MediaQuery.of(context).size.height * .1,
        width: MediaQuery.of(context).size.width * .2,
        decoration: BoxDecoration(
          color: Color(0xff242426),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 0),
              blurRadius: 5,
              color: Colors.black.withOpacity(0.3),
            ),
          ],
        ),
        child: Image(
          width: 40,
          height: 40,
          image: Svg('assets/svg/Chat.svg'),
        ),
      ),
    );
  }
}

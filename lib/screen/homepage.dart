import 'package:flutter/material.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

class homepage extends StatefulWidget {
  const homepage({super.key});

  @override
  State<homepage> createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: false,
        title: Container(
          width: MediaQuery.of(context).size.width*.25,
          child:Image.asset('assets/images/Vahan.png'),),
      ),
      body: SingleChildScrollView(
    child:
    Padding(padding: EdgeInsets.only(left: 16,right: 15,top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         Container(
           height: MediaQuery.of(context).size.height*.075,
           decoration: BoxDecoration(
             color: Color(0xff242426),
             borderRadius: BorderRadius.circular(64)
           ),
           child: Padding(
               padding: EdgeInsets.only(left: 24),
           child:Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
              Icon(Icons.search,size: 24,color: Color(0xff797979),),
               SizedBox(width: 16,),
               Text('Where to?',
                 style: TextStyle(
                   color: Color(0xff797979),
                 fontSize: 20,
                 fontFamily: 'Gelix-Medium',
                 //fontWeight: FontWeight.w400,
               ),),
            SizedBox(
              width: MediaQuery.of(context).size.width*.16,
            ),
               Padding(
                 padding: EdgeInsets.only(top: 4,bottom: 5),
                 child: Container(
                   height:  MediaQuery.of(context).size.height,
                   width: MediaQuery.of(context).size.width*.38,
                   decoration: BoxDecoration(
                     color: Color(0xffB3FD14),
                     borderRadius: BorderRadius.circular(32)
                   ),
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Icon(Icons.access_time_filled_rounded,size: 24,color: Colors.black,),
                       SizedBox(width: 8,),
                       Text('Now',
                         style: TextStyle(
                         color: Colors.black,
                         fontSize: 20,
                           fontFamily: 'Gelix-Medium',

                       ),),
                       Icon(Icons.keyboard_arrow_down_rounded,size: 24,color: Colors.black)
                     ],
                   ),
                 ),
               ),
             ],
           ), 
             ),
         ),
          SizedBox(height: MediaQuery.of(context).size.height*.02,),
          Text('Current Location',
            style: TextStyle(
              color: Color(0xffE1E1E1),
              fontSize: 20,
              fontFamily: 'Gelix-Medium',
              //fontWeight: FontWeight.w400,
            ),),
          SizedBox(
            height: MediaQuery.of(context).size.height*.015,
          ),
          Container(
            height: MediaQuery.of(context).size.height*.4,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Color(0xff242426),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height*.02,),
          Text('More ways to use Vahan',
            style: TextStyle(
              color: Color(0xffE1E1E1),
              fontSize: 20,
              fontFamily: 'Gelix-Medium',
              //fontWeight: FontWeight.w400,
            ),),
          SizedBox(height: MediaQuery.of(context).size.height*.02,),
      Container(
        //margin: const EdgeInsets.symmetric(vertical: 20.0),
        height: 200.0,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width*.7,
              decoration: BoxDecoration(
                color: Color(0xff242426),
                borderRadius: BorderRadius.circular(16),
              ),
             
            ),
            SizedBox(width: MediaQuery.of(context).size.width*.08,),
            Container(
              width: MediaQuery.of(context).size.width*.8,
              decoration: BoxDecoration(
                color: Color(0xff242426),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            SizedBox(width: MediaQuery.of(context).size.width*.08,),
            Container(
              width: MediaQuery.of(context).size.width*.7,
              decoration: BoxDecoration(
                color: Color(0xff242426),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            SizedBox(width: MediaQuery.of(context).size.width*.08,),
            Container(
              width: MediaQuery.of(context).size.width*.7,
              decoration: BoxDecoration(
                color: Color(0xff242426),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            SizedBox(width: MediaQuery.of(context).size.width*.08,),
            Container(
              width: MediaQuery.of(context).size.width*.7,
              decoration: BoxDecoration(
                color: Color(0xff242426),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ],
        ),
      ),
        ],
      ),),
      ),
      floatingActionButton: Container(
        height: MediaQuery.of(context).size.height*.1,
        width: MediaQuery.of(context).size.width*.2,
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

        child:

        Image(
        width: 40,
        height: 40,
        image: Svg('assets/svg/Chat.svg'),
      ),

      ),

    );
  }
}

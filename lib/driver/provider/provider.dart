import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';

class LocationProviderDriver extends ChangeNotifier{

  Position? position;

  updateDriverPosition(Position newPosition){

    position = newPosition;
    notifyListeners();

  }

}


class Pickupanddroploctaion {
  String? name;
  String? description;
  String? placeID;
  String? latitude;
  String? longitude;

  Pickupanddroploctaion({
  this.name,
  this.description,
  this.placeID,
  this.latitude,
  this.longitude,
});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
    'name': name,
    'description': description,
    'placeID': placeID,
    'latitude': latitude,
    'longitude':longitude
    };
}
}

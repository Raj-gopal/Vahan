const String
baseUrl ='https://api.mapbox.com/directions/v5/mapbox/driving';

const String
apiKey = 'pk.eyJ1IjoicmFqZ2siLCJhIjoiY2x6NThlNDJlNDZ4ODJxczYzMnNpdGhxayJ9.NBTbcDPIefKRWhsHP8LrMA';

getRouteUrl(String startPointlng ,String startPointlat , String endPointlng, String endPointlat){
  return Uri.parse('$baseUrl/$startPointlng%2C$startPointlat%3B$endPointlng%2C$endPointlat?alternatives=true&annotations=distance%2Cduration%2Cspeed&geometries=geojson&language=en&overview=full&steps=true&access_token=$apiKey');
}
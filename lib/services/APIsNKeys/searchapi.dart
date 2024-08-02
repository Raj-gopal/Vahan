const String
baseUrl ='https://api.mapbox.com/directions/v5/mapbox/driving';

const String
apiKey = 'pk.eyJ1IjoicmFqZ2siLCJhIjoiY2x6NThlNDJlNDZ4ODJxczYzMnNpdGhxayJ9.NBTbcDPIefKRWhsHP8LrMA';

getfullAddress(String address){
  return Uri.parse('https://api.mapbox.com/search/searchbox/v1/suggest?q=$address&language=en&proximity=-73.990593,40.740121&session_token=06b06ff6-c520-4208-8191-0cba4e8b0207&access_token=$apiKey');
}
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:plantask/Model/Weather.dart';
import 'dart:convert';

Future<Position> getCurrentPosition() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error('Location permissions are permanently denied.');
  }

  return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
}


Future<Weather> fetchWeather(Position position) async {
  final apiKey = '90febfb0c5aab274b6fe21de9ddfa82c';
  final url = 'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric&lang=fr';

  print("URL de l'API: $url");

  final response = await http.get(Uri.parse(url));

  print("Status code: ${response.statusCode}");
  print("Response body: ${response.body}");

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    return Weather.fromJson(jsonData);
  } else {

    final errorData = json.decode(response.body);
    throw Exception('Erreur API météo: ${errorData['message'] ?? 'Erreur inconnue'}');
  }
}

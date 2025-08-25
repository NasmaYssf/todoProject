import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../Model/Weather.dart';
import '../services/WeatherService.dart';

class WeatherProvider with ChangeNotifier {
  String location = "--";
  double temperature = 0;
  String description = "";
  int humidity = 0;
  double windSpeed = 0;
  int cloudiness = 0;
  String icon = "";
  bool loading = false;

  Future<void> loadWeather() async {
    try {
      loading = true;
      notifyListeners();

      Position pos = await getCurrentPosition();
      Weather weather = await fetchWeather(pos);
      Placemark placemark = (await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      )).first;

      location = placemark.subLocality!;
      temperature = weather.temperature;
      description = weather.description;
      humidity = weather.humidity;
      windSpeed = weather.windSpeed;
      cloudiness = weather.cloudiness;
      icon = weather.icon;
    } catch (e) {
      print("Erreur provider météo: $e");
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}

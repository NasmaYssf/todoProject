import 'package:flutter/material.dart';
import 'package:plantask/providers/WeatherProvider.dart';
import 'package:provider/provider.dart';
import 'package:plantask/Home.dart';




class MeteoPage extends StatefulWidget {
  const MeteoPage({super.key});
  @override
  State<MeteoPage> createState() => _MeteoPageState();
}

class _MeteoPageState extends State<MeteoPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<WeatherProvider>(context, listen: false).loadWeather());
  }

  @override
  Widget build(BuildContext context) {
    final weatherProv = Provider.of<WeatherProvider>(context);
    final mediaQuery = MediaQuery.of(context);
    final height = mediaQuery.size.height;
    final width = mediaQuery.size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        child: weatherProv.loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: width * 0.06, vertical: height * 0.03),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Material(
                  shape: const CircleBorder(),
                  elevation: 4,
                  color: Colors.white,
                  child: IconButton(
                    icon: Icon(Icons.chevron_left,
                        size: 32, color: Colors.teal[700]),
                    onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const Home())),
                  ),
                ),
                SizedBox(height: height * 0.035),
                Center(
                  child: Text(
                    "Météo du jour",
                    style: TextStyle(
                      fontSize: width * 0.09,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[800],
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                SizedBox(height: height * 0.02),
                Center(
                  child: Text(
                    weatherProv.location,
                    style: TextStyle(
                      fontSize: width * 0.055,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                SizedBox(height: height * 0.05),
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: width * 0.35,
                        height: width * 0.35,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          // color: Colors.teal,
                            color: Colors.orange.shade200,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.shade100,
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                          ],
                          // boxShadow: [
                          //   BoxShadow(
                          //     color: Colors.white,
                          //     blurRadius: 15,
                          //     offset: const Offset(0, 8),
                          //   ),
                          // ],
                        ),
                        child: weatherProv.icon.isEmpty
                            ? Icon(Icons.sunny_snowing,
                            size: width * 0.20,
                            color: Colors.white)
                            : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.network(
                            'https://openweathermap.org/img/wn/${weatherProv.icon}@4x.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.015),
                      Text(
                        "${weatherProv.temperature.toStringAsFixed(1)}°C",
                        style: TextStyle(
                          fontSize: width * 0.13,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: height * 0.008),
                      Text(
                        "${weatherProv.description.isNotEmpty ? weatherProv.description : "temps"} à ${weatherProv.location}",
                        style: TextStyle(
                          fontSize: width * 0.055,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: height * 0.07),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _weatherDetail(Icons.air, "Vent",
                        "${weatherProv.windSpeed.toStringAsFixed(1)} km/h",
                        width),
                    _weatherDetail(Icons.opacity, "Humidité",
                        "${weatherProv.humidity}%", width),
                    _weatherDetail(Icons.cloud, "Nuages",
                        "${weatherProv.cloudiness}%", width),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _weatherDetail(
      IconData icon, String label, String value, double width) {
    return Container(
      width: width * 0.25,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 10,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: width * 0.11, color: Colors.teal[600]),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: width * 0.045,
              fontWeight: FontWeight.w600,
              color: Colors.teal[700],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: width * 0.04,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

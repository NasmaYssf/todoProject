class Weather {
  final String city;
  final double temperature;
  final String description;
  final double windSpeed;
  final int humidity;
  final int cloudiness;
  final String icon;

  Weather({
    required this.city,
    required this.temperature,
    required this.description,
    required this.windSpeed,
    required this.humidity,
    required this.cloudiness,
    required this.icon
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      city: json['name'] ?? '',
      temperature: (json['main']['temp'] as num).toDouble(),
      description: json['weather'][0]['description'] ?? '',
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      humidity: json['main']['humidity'] ?? 0,
      cloudiness: json['clouds']['all'] ?? 0,
      icon: json['weather'][0]['icon'] ?? '',
    );
  }
}


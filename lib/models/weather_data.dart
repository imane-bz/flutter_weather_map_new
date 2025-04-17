class WeatherData {
  final double temperature;
  final String description;
  final String icon;
  final double humidity;
  final double windSpeed;
  final String cityName;

  WeatherData({
    required this.temperature,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.cityName,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: json['main']['temp'].toDouble(),
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      humidity: json['main']['humidity'].toDouble(),
      windSpeed: json['wind']['speed'].toDouble(),
      cityName: json['name'],
    );
  }
}
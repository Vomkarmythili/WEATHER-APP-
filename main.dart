import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

void main() => runApp(const WeatherApp());

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Simple Weather",
      home: const WeatherHome(),
    );
  }
}

class WeatherHome extends StatefulWidget {
  const WeatherHome({super.key});

  @override
  State<WeatherHome> createState() => _WeatherHomeState();
}

class _WeatherHomeState extends State<WeatherHome> {
  String apiKey = "aeeab456c79cc12355970f189ede5e08"; // Replace with your API Key
  String city = "Loading...";
  String country = "";
  String temp = "";
  String desc = "";
  String icon = "";
  Color bgColor = Colors.blue;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getWeatherByLocation();
  }

  /// 🌍 Fetch weather using GPS location
  Future<void> _getWeatherByLocation() async {
    try {
      Position pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final url = Uri.parse(
          "https://api.openweathermap.org/data/2.5/weather?lat=${pos.latitude}&lon=${pos.longitude}&appid=$apiKey&units=metric");

      await _fetchWeather(url);
    } catch (e) {
      setState(() {
        city = "Error getting location";
        country = "";
      });
    }
  }

  /// 🏙️ Fetch weather by city or country name
  Future<void> _getWeatherByCity(String name) async {
    final url = Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?q=$name&appid=$apiKey&units=metric");

    await _fetchWeather(url);
  }

  /// 🌤️ Common function to fetch weather data
  Future<void> _fetchWeather(Uri url) async {
    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          city = data["name"];
          country = data["sys"]["country"];
          temp = data["main"]["temp"].toString();
          desc = data["weather"][0]["main"];
          icon = data["weather"][0]["icon"];
          bgColor = _getBgColor(desc);
        });
      } else {
        setState(() {
          city = "City/Country not found";
          country = "";
          temp = "";
          desc = "";
          icon = "";
        });
      }
    } catch (e) {
      setState(() {
        city = "Error fetching weather";
        country = "";
      });
    }
  }

  /// 🎨 Background color based on weather
  Color _getBgColor(String condition) {
    if (condition.contains("Cloud")) return Colors.grey.shade400;
    if (condition.contains("Rain")) return Colors.blueGrey.shade700;
    if (condition.contains("Clear")) return Colors.orange.shade300;
    if (condition.contains("Snow")) return Colors.lightBlue.shade200;
    return Colors.blue.shade300;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(title: const Text("Weather App")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon.isNotEmpty)
              Image.network(
                "https://openweathermap.org/img/wn/$icon@2x.png",
                width: 100,
                height: 100,
              ),
            Text(
              country.isNotEmpty ? "$city, $country" : city,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            if (temp.isNotEmpty)
              Text(
                "$temp °C",
                style: const TextStyle(fontSize: 24),
              ),
            if (desc.isNotEmpty)
              Text(
                desc,
                style: const TextStyle(fontSize: 20),
              ),
            const SizedBox(height: 30),

            // 🔍 Search bar for city/country
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Enter city or country",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      _getWeatherByCity(_controller.text);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _getWeatherByLocation,
              icon: const Icon(Icons.my_location),
              label: const Text("Use My Location"),
            ),
          ],
        ),
      ),
    );
  }
}

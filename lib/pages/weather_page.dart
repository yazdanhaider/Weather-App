import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/services/weather_service.dart';


class WeatherPage extends StatefulWidget {
  const WeatherPage({Key? key}) : super(key: key);

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _weatherService = WeatherService('006bc59c7446498ff846f5cb7151a1fb');
  Weather? _weather;
  late String _currentTime = '';

  late StreamController<DateTime> _timeStreamController;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
    _updateTime();
    Timer.periodic(Duration(minutes: 1), (Timer timer) {
      _fetchWeather(); // Fetch weather data every minute for live updates
      _updateTime();
    });

    _timeStreamController = StreamController<DateTime>.broadcast();
    Timer.periodic(Duration(seconds: 10), (Timer timer) {
      _timeStreamController.add(DateTime.now());
    });
  }

  @override
  void dispose() {
    _timeStreamController.close();
    super.dispose();
  }

  _fetchWeather() async {
    String cityName = await _weatherService.getCurrentCity();
    try {
      final weather = await _weatherService.getWeather(cityName);
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      print(e);
    }
  }

  String getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return 'assets/sunny.json'; //default weather

    switch (mainCondition.toLowerCase()) {
      case 'clouds':
        return 'assets/cloud.json';
      case 'mist':
        return 'assets/mist.json';
      case 'smoke':
        return 'assets/smoke.json';
      case 'haze':
        return 'assets/haze.json';
      case 'dust':
        return 'assets/dust.json';
      case 'fog':
        return 'assets/fog.json';
      case 'dense fog':
        return 'assets/fog.json';
      case 'rain':
        return 'assets/rainy.json';
      case 'drizzle':
      case 'shower rain':
        return 'assets/rainy.json';
      case 'thunderstorm':
        return 'assets/thunder.json';
      case 'clear':
        return 'assets/clear.json';
      default:
        return 'assets/sunny.json';
    }
  }

  LinearGradient _getBackgroundGradient(String? mainCondition, DateTime currentTime) {
    if (mainCondition == null) return LinearGradient(colors: [Colors.blue,
      Colors.blue]);

    Color startColor = Colors.blue;
    Color endColor = Colors.black;

    // Adjust gradient based on current time
    if (currentTime.hour >= 6 && currentTime.hour < 14) {
      // Daytime gradient
      startColor = Colors.yellow;
      endColor = Colors.blue;
    } else if (currentTime.hour >= 14 && currentTime.hour < 18) {
      // Evening gradient
      startColor = Colors.blue;
      endColor = Colors.orange;
    } else {
      // Night gradient (after 21:00)
      startColor = Colors.black;
      endColor = Colors.black87;

    }

    return LinearGradient(
      colors: [startColor, endColor],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  Future<void> _onRefresh() async {
    await _fetchWeather();
  }

  void _updateTime() {
    setState(() {
      _currentTime = DateFormat.jm().format(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: StreamBuilder<DateTime>(
          stream: _timeStreamController.stream,
          builder: (context, snapshot) {
            final currentTime = snapshot.data ?? DateTime.now();

            return Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: _getBackgroundGradient(_weather?.mainCondition, currentTime),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "My Location",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Helvetica Neue',
                        fontSize: 26.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      _weather?.cityName ?? "loading city..",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'Helvetica Neue',
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Lottie.asset(getWeatherAnimation(_weather?.mainCondition)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${_weather?.temperature.round()}°',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Helvetica Neue',
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (currentTime.hour >= 6 && currentTime.hour < 17)
                          Icon(
                            Icons.wb_sunny,
                            color: Colors.white,
                            size: 32.0,
                          ),
                        if (currentTime.hour >= 17 || currentTime.hour < 6)
                          Icon(
                            Icons.nightlight_round,
                            color: Colors.white,
                            size: 32.0,
                          ),
                      ],
                    ),

                    Text(
                      _weather?.mainCondition ?? "",
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      _currentTime,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontFamily: 'Helvetica Neue',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

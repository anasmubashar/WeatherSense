// ignore_for_file: prefer_const_constructors

import 'dart:developer';

import 'package:my_weather_app/daily_forecast.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:my_weather_app/secrets.dart';
import 'package:my_weather_app/widgets/Custom_text.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

import 'package:my_weather_app/widgets/forecast_dart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //latitude and longitude variables
  double latitude = 48.8566;
  double longitude = 2.3522;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _getCurrentLocation().then((value) {
      setState(() {
        latitude = value.latitude;
        longitude = value.longitude;
      });
    });
    getWeather();
  }

  Future<Map<String, dynamic>> getWeather() async {
    final res = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?lat=${latitude}&lon=${longitude}&appid=${api_key}'));
    log('Latitude: ' +
        latitude.toString() +
        'Longitude: ' +
        longitude.toString());
    final data = jsonDecode(res.body);
    if (res.statusCode == 200) {
      return data;
    } else {
      throw Exception('Unexpected error occured!');
    }
  }

  double Kelvin_to_celsius(final temp) {
    return temp - 273.15;
  }

  String dateFormater(final date) {
    if (date != null) {
      DateTime dateTime = DateTime.parse(date);
      String formattedDate = DateFormat('EEEE, d MMMM').format(dateTime);
      return formattedDate;
    } else {
      print(date);
      return 'No date available';
    }
  }

  String dateFormater2(final date) {
    if (date != null) {
      DateTime dateTime = DateTime.parse(date);
      String formattedDate = DateFormat('d MMM').format(dateTime);
      return formattedDate;
    } else {
      print(date);
      return 'No date available';
    }
  }

  String dateFormater3(final date) {
    if (date != null) {
      DateTime dateTime = DateTime.parse(date);
      String formattedDate = DateFormat('d').format(dateTime);
      return formattedDate;
    } else {
      print(date);
      return 'No date available';
    }
  }

  int dateFormater4(final date) {
    if (date != null) {
      DateTime dateTime = DateTime.parse(date);
      int formattedDate = int.parse(DateFormat('d').format(dateTime));
      return formattedDate;
    } else {
      print(date);
      return 0; // Return 0 or any other default value if date is null
    }
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
  }

  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color(0xFFFFE142),
      body: FutureBuilder(
        future: getWeather(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Custom_text(
                text: 'Error: ${snapshot.error}',
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            );
          }
          final data = snapshot.data;
          final temp = data?['list'][0]['main']['temp'];
          final max_temp = data?['list'][0]['main']['temp_max'];
          final min_temp = data?['list'][0]['main']['temp_min'];
          final visibility = data?['list'][0]['visibility'] / 1000;
          final humidity = data?['list'][0]['main']['humidity'];
          final wind = data?['list'][0]['wind']['speed'];
          final date = data?['list'][0]['dt_txt'];
          final weather = data?['list'][0]['weather'][0]['description'];
          final city_name = data?['city']['name'];

          List<dynamic> forecast = data?['list'];
          List<dynamic> daily_forecast = [];

          DateTime currentDate = DateTime.parse(forecast[0]['dt_txt']);
          int dayCount = 0;

          for (var i = 1; i < forecast.length; i++) {
            DateTime forecastDate = DateTime.parse(forecast[i]['dt_txt']);

            if (forecastDate.hour == 12 &&
                forecastDate.day != currentDate.day) {
              dayCount++;
              currentDate = forecastDate;
              daily_forecast.add(forecast[i]);
            }

            if (dayCount > 4) {
              break;
            }
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: _height * 0.06,
              ),
              Custom_text(
                text: city_name,
                fontSize: 30,
                fontWeight: FontWeight.w800,
              ),
              SizedBox(
                height: _height * 0.03,
              ),
              Container(
                height: _height * 0.03,
                width: _width * 0.35,
                // padding: EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Custom_text(
                    text: dateFormater(date),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFFE142),
                  ),
                ),
              ),
              SizedBox(
                height: _height * 0.013,
              ),
              Custom_text(
                  text: weather, fontSize: 20, fontWeight: FontWeight.w600),
              Custom_text(
                  text: Kelvin_to_celsius(temp).toStringAsFixed(0) + '°',
                  fontSize: 140,
                  fontWeight: FontWeight.w700),
              SizedBox(
                height: _height * 0.01,
              ),
              Align(
                alignment: Alignment(-0.72, 0),
                child: Custom_text(
                    text: 'Daily Summary',
                    fontSize: 20,
                    fontWeight: FontWeight.w900),
              ),
              SizedBox(
                height: _height * 0.007,
              ),
              Padding(
                padding: EdgeInsets.only(left: 35.0, right: 10),
                child: Custom_text(
                    text:
                        '''Now it feels hot because of the direct sun. Today the temperature is felt in the range from ${Kelvin_to_celsius(min_temp).toStringAsFixed(2)}° to ${Kelvin_to_celsius(max_temp).toStringAsFixed(2)}°''',
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: _height * 0.013,
              ),
              Align(
                alignment: Alignment(0, 0),
                child: Container(
                  height: _height * 0.18,
                  width: _width * 0.83,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.black),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          //Icon(icons),
                          FaIcon(
                            FontAwesomeIcons.wind,
                            color: Color(0xFFFFE142),
                            size: 30,
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Custom_text(
                            text: wind.toString() + 'km/h',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFFE142),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Custom_text(
                            text: 'Wind',
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFFFFE142),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize
                            .min, // This makes the Column only as tall as its children
                        children: [
                          FaIcon(
                            FontAwesomeIcons.droplet,
                            color: Color(0xFFFFE142),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Custom_text(
                            text: humidity.toString() + '%',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFFE142),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Custom_text(
                            text: 'Humidity',
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFFFFE142),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize
                            .min, // This makes the Column only as tall as its children
                        children: [
                          FaIcon(
                            FontAwesomeIcons.eye,
                            color: Color(0xFFFFE142),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Custom_text(
                            text: visibility.toStringAsFixed(0) + 'km',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFFE142),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Custom_text(
                            text: 'Visibility',
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFFFFE142),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: _height * 0.02,
              ),
              Align(
                alignment: Alignment(-0.72, 0),
                child: Custom_text(
                  text: 'Daily forecast',
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(
                height: _height * 0.02,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ForecastContainer(
                    icon: (daily_forecast[0]['weather'][0]['main'] == 'Clear' ||
                            daily_forecast[0]['weather'][0]['main'] == 'Suuny')
                        ? FontAwesomeIcons.sun
                        : (daily_forecast[0]['weather'][0]['main'] == 'Clouds')
                            ? FontAwesomeIcons.cloudSun
                            : FontAwesomeIcons.cloudRain,
                    date: dateFormater2(daily_forecast[0]['dt_txt']),
                    temp: Kelvin_to_celsius(daily_forecast[0]['main']['temp'])
                            .toStringAsFixed(0) +
                        '°',
                    height: _height * 0.14,
                    width: _width * 0.2,
                  ),
                  ForecastContainer(
                    icon: (daily_forecast[1]['weather'][0]['main'] == 'Clear' ||
                            daily_forecast[1]['weather'][0]['main'] == 'Suuny')
                        ? FontAwesomeIcons.sun
                        : (daily_forecast[1]['weather'][0]['main'] == 'Clouds')
                            ? FontAwesomeIcons.cloudSun
                            : FontAwesomeIcons.cloudRain,
                    date: dateFormater2(daily_forecast[1]['dt_txt']),
                    temp: Kelvin_to_celsius(daily_forecast[1]['main']['temp'])
                            .toStringAsFixed(0) +
                        '°',
                    height: _height * 0.14,
                    width: _width * 0.2,
                  ),
                  ForecastContainer(
                    icon: (daily_forecast[2]['weather'][0]['main'] == 'Clear' ||
                            daily_forecast[2]['weather'][0]['main'] == 'Suuny')
                        ? FontAwesomeIcons.sun
                        : (daily_forecast[2]['weather'][0]['main'] == 'Clouds')
                            ? FontAwesomeIcons.cloudSun
                            : FontAwesomeIcons.cloudRain,
                    date: dateFormater2(daily_forecast[2]['dt_txt']),
                    temp: Kelvin_to_celsius(daily_forecast[2]['main']['temp'])
                            .toStringAsFixed(0) +
                        '°',
                    height: _height * 0.14,
                    width: _width * 0.2,
                  ),
                  ForecastContainer(
                    icon: (daily_forecast[3]['weather'][0]['main'] == 'Clear' ||
                            daily_forecast[3]['weather'][0]['main'] == 'Suuny')
                        ? FontAwesomeIcons.sun
                        : (daily_forecast[3]['weather'][0]['main'] == 'Clouds')
                            ? FontAwesomeIcons.cloudSun
                            : FontAwesomeIcons.cloudRain,
                    date: dateFormater2(daily_forecast[3]['dt_txt']),
                    temp: Kelvin_to_celsius(daily_forecast[3]['main']['temp'])
                            .toStringAsFixed(0) +
                        '°',
                    height: _height * 0.14,
                    width: _width * 0.2,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

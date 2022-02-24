import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // buat var untuk temp dan locationnya
   int? temperature;

  int woeid = 2427032;
  String location = 'Indonesia';

  String weather = 'clear';

  // buat variable untuk icon dan kota yng tidak ada kotanya
  String abbreviation = '';
  String errorMessage = '';

  //buat var untuk list temperature nya
  var  minTemperatureForecast = List.filled(7,0 );
  var maxTemperatureForecast =List.filled(7, 0 );
  var  abbreviationForecast = List.filled(7, ' ');



  String searchApiUrl =
      "https://www.metaweather.com/api/location/search/?query=";
  String locationAPiUrl = 'https://www.metaweather.com/api/location/';

  @override
  void initState() {
    super.initState();
    fetchLocation();
    fetchLocationDay();
  }

  Future<void> fetchSearch(String input) async {
    try {
      var searchResult = await http.get(Uri.parse(searchApiUrl + input));
      var result = jsonDecode(searchResult.body)[0];

      setState(() {
        location = result["title"];
        woeid = result["woeid"];
        errorMessage = '';
      });
    } catch (error) {
      setState(() {
        errorMessage =
            "Maaf kita tidak ada data untuk kota itu, coba kota lain aja ya";
      });
    }
  }

 Future<void> fetchLocation() async {
    var locationResult =
        await http.get(Uri.parse(locationAPiUrl + woeid.toString()));
    var result = jsonDecode(locationResult.body);
    var consolidated_weather = result["consolidated_weather"];
    var data = consolidated_weather[0];

    setState(() {
      temperature = data["the_temp"].round();
      weather = data['weather_state_name'].replaceAll(' ', '').toLowerCase();
      abbreviation = data["weather_state_abbr"];
    });
  }

  Future<void> fetchLocationDay() async {
    var today = DateTime.now();
    for (var i = 0; i < 7; i++) {
      var locationDayResult = await http.get(Uri.parse(locationAPiUrl + woeid.toString() + '/' + DateFormat('y/M/d').format(today.add(Duration(days: i + 1))).toString()));
      var result = jsonDecode(locationDayResult.body);
      var data = result[0];

      setState(() {
        minTemperatureForecast[i] = data["min_temp"].round();
        maxTemperatureForecast[i] = data["max_temp"].round();
        abbreviationForecast[i] = data["weather_state_abbr"];
      });
    }
  }

  void onTextFieldSubmitted(String input) async {
    await  fetchSearch(input);
    await fetchLocation();
    await fetchLocationDay();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('images/$weather.png'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.6), BlendMode.dstATop))),
      child: temperature == null
          ? const Center(child: CircularProgressIndicator())
          : Scaffold(
              backgroundColor: Colors.transparent,
              body: SingleChildScrollView(
                padding: EdgeInsets.only(top: 100),
                child: Column(
                  children: [
                    Column(
                      children: [
                        Center(
                          child: Image.network(
                            'https://www.metaweather.com/static/img/weather/png/' +
                                abbreviation +
                                '.png',
                            width: 100,
                          ),
                        ),
                        Center(
                          child: Text(
                            temperature.toString() + ' °C',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 60),
                          ),
                        ),
                        Center(
                          child: Text(
                            location,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 40),
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (var i = 0; i < 7; i++)
                              forecastElement(
                                i + 1,
                                abbreviationForecast[i],
                                maxTemperatureForecast[i],
                                minTemperatureForecast[i],
                              ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Column(
                        children: [
                          SizedBox(
                            width: 300,
                            child: TextField(
                              onSubmitted: (String input) {
                                onTextFieldSubmitted(input);
                              },
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 25),
                              decoration: const InputDecoration(
                                  hintText: 'Search Another location..',
                                  hintStyle: TextStyle(
                                      color: Colors.white, fontSize: 18.0),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: Colors.white,
                                  )),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              errorMessage,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: Platform.isAndroid ? 15.0 : 20.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}

Widget forecastElement(
    daysFromNow, abbreviation, maxTemperature, minTemperature) {
  var now = DateTime.now();
  var oneDayFromNow = now.add(Duration(days: daysFromNow));
  return Padding(
    padding: const EdgeInsets.only(left: 16),
    child: Container(
      decoration: BoxDecoration(
          color: const Color.fromRGBO(205, 212, 228, 0.2),
          borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              DateFormat.E().format(oneDayFromNow),
              style: const TextStyle(color: Colors.white, fontSize: 25),
            ),
            Text(
              DateFormat.MMMd().format(oneDayFromNow),
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Image.network(
                'https://www.metaweather.com/static/img/weather/png/' +
                    abbreviation +
                    '.png',
                width: 50,
              ),
            ),
            Text(
              'High ' + maxTemperature.toString() + ' °C',
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            Text(
              'Low ' + minTemperature.toString() + ' °C',
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
          ],
        ),
      ),
    ),
  );
}

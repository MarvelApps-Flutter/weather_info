import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:weather_app/Model/responseClass.dart';
import 'package:weather_app/Model/fiveDaysWeatherForecastResponseModel.dart'
    as fiveDaysWeather;

class ApiServices {
  Future getData(String city) async {
    final params = {
      'q': city,
      'appid': '666debcab45f763590f1a66d93cb227a',
      'units': 'metric'
    };
    final uri =
        Uri.https('api.openweathermap.org', '/data/2.5/weather', params);
    var response = await http.get(uri);

    final json = jsonDecode(response.body);
    log(response.body);
    log(response.statusCode.toString());
    return Response.fromJson(json);
  }

  Future get5DaysData(String city) async {
    final String fiveDaysApiUrl =
        "https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=666debcab45f763590f1a66d93cb227a";

    var fiveDaysRes = await http.get(Uri.parse(fiveDaysApiUrl));

    final fiveDaysJson = jsonDecode(fiveDaysRes.body);
    return fiveDaysWeather.FiveDaysWeatherResponseModel.fromJson(fiveDaysJson);
  }
}

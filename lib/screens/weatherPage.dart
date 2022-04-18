import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:weather_app/Constants/asset_constants.dart';
import 'package:weather_app/Constants/string_constants.dart';
import 'package:weather_app/Model/fiveDaysWeatherForecastResponseModel.dart'
    as fiveDaysWeather;
import 'package:weather_app/Model/responseClass.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/Services/api_services.dart';

class WeatherPage extends StatefulWidget {
  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  Response _response;
  ApiServices _apiServices;
  fiveDaysWeather.FiveDaysWeatherResponseModel _fiveDaysWeatherResponseModel;
  TextEditingController cityController;
  String cityName;

  @override
  void initState() {
    initilaize();
    super.initState();
  }

  void initilaize() {
    _apiServices = ApiServices();
    cityController = TextEditingController();
    cityName = StringConstants.defaultCityName;
  }

  Future<bool> getWeatherInfo(String city) async {
    final response = await _apiServices.getData(city);
    final fiveDaysRes = await _apiServices.get5DaysData(city);

    _response = response;
    _fiveDaysWeatherResponseModel = fiveDaysRes;

    if (_response.cod == 200 && _fiveDaysWeatherResponseModel.cod == "200") {
      return true;
    } else {
      return false;
    }

    //return "true";
  }

  @override
  Widget build(BuildContext context) {
    return bodySection();
  }

  Widget bodySection() {
    return FutureBuilder(
      future: getWeatherInfo(cityName),
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          return _response.cod == 200 &&
                  _fiveDaysWeatherResponseModel.cod == "200"
              ? weatherAvailableSection(context)
              : weatherOrCityNotFoundBodySection(context);
        }

        return weatherPageLoader();
      },
    );
  }

  Widget weatherPageLoader() {
    return Scaffold(
        body: Container(
            alignment: Alignment.center, child: CircularProgressIndicator()));
  }

  Widget weatherOrCityNotFoundBodySection(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 100,
              color: Colors.red,
            ),
            Text(
              StringConstants.cityNotFound,
              style: TextStyle(color: Colors.black, fontSize: 25),
            ),
            SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: () {
                Navigator.of(context)
                    .pushReplacement(MaterialPageRoute(builder: (context) {
                  return WeatherPage();
                }));
              },
              child: Container(
                alignment: Alignment.center,
                height: MediaQuery.of(context).size.height * 0.05,
                width: MediaQuery.of(context).size.width * 0.4,
                decoration: BoxDecoration(
                    color: Colors.blue.shade400,
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                child: Text(
                  StringConstants.goBack,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget weatherAvailableSection(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
            padding: EdgeInsets.only(left: 20, right: 20, top: 30),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage(AssetConstants.backgroundImage),
                  colorFilter: ColorFilter.mode(Colors.blue, BlendMode.color)),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  cityTextFieldSection(context),
                  weatherPageHeaderSection(),
                  SizedBox(height: 30),
                  weatherAppCurrentTempSection(),
                  countryDetailsSection(),
                  fiveDaysWeatherSection(),
                ],
              ),
            )),
      ),
    );
  }

  Widget cityTextFieldSection(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Colors.grey.shade400,
                spreadRadius: 0.8,
                blurRadius: 0.5),
            BoxShadow(color: Colors.white, spreadRadius: 0.8, blurRadius: 0.5)
          ],
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(30))),
      child: TextFormField(
        onEditingComplete: () {
          setState(() {
            if (cityController.text.contains("  ")) {
              cityName = cityController.text.replaceAll("  ", "%20");
            } else {
              cityName = cityController.text;
            }
          });
        },
        decoration: InputDecoration(
            border: InputBorder.none,
            hintText: StringConstants.cityTextFieldHintText,
            prefixIcon: Icon(Icons.search),
            hintStyle: TextStyle(color: Colors.grey, fontSize: 18),
            contentPadding: EdgeInsets.all(15),
            suffixIcon: Icon(
              Icons.menu,
              color: Colors.grey,
            )),
        controller: cityController,
      ),
    );
  }

  Widget weatherAppCurrentTempSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _response.main.temp.round().toString(),
          style: TextStyle(
            fontSize: 130,
            color: Colors.white,
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              StringConstants.degreeWithoutSpace,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 40,
                color: Colors.white,
              ),
            ),
            Row(
              children: [
                SvgPicture.asset(AssetConstants.highTemp,
                    color: Colors.white, height: 30, width: 20),
                Text(
                  _response.main.tempMax.round().toString() +
                      StringConstants.degreeWithoutSpace,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                SvgPicture.asset(AssetConstants.lowTemp,
                    color: Colors.white, height: 30, width: 20),
                Text(
                  _response.main.tempMin.round().toString() +
                      StringConstants.degreeWithoutSpace,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ],
            )
          ],
        )
      ],
    );
  }

  Widget weatherPageHeaderSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SvgPicture.asset(AssetConstants.cloudIcon,
            color: Colors.white, height: 50, width: 50),
        Text(_response.clouds.all.toString() + StringConstants.percent,
            style: TextStyle(color: Colors.white, fontSize: 20)),
        Spacer(),
        SvgPicture.asset(AssetConstants.windIcon,
            color: Colors.white, height: 50, width: 50),
        Text(_response.wind.speed.toString() + StringConstants.meterPerSecond,
            style: TextStyle(color: Colors.white, fontSize: 20)),
        Spacer(),
        SvgPicture.asset(AssetConstants.humidityIcon,
            color: Colors.white, height: 50, width: 50),
        Text(
            _response.main.humidity.round().toString() +
                StringConstants.percent,
            style: TextStyle(color: Colors.white, fontSize: 20)),
      ],
    );
  }

  Widget countryDetailsSection() {
    return Column(
      children: [
        Text(
          _response.name + ", " + _response.sys.country,
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
          ),
        ),
        Text(
          _response.weather[0].description,
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        SvgPicture.asset(
          AssetConstants.cloudyWeatherIcon,
          color: Colors.white,
          height: 200,
          width: 200,
        )
      ],
    );
  }

  Widget fiveDaysWeatherSection() {
    return Container(
      padding: EdgeInsets.only(top: 30),
      alignment: Alignment.bottomCenter,
      child: FutureBuilder(
          future: _apiServices.get5DaysData(cityName),
          builder: (context, snapshot) {
            return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _fiveDaysWeatherResponseModel.list.length,
                itemBuilder: (context, itemIndex) {
                  return ((itemIndex + 1) % 8) == 0
                      ? Container(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 12),
                          height: MediaQuery.of(context).size.height * 0.15,
                          width: MediaQuery.of(context).size.width * 0.5,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage(
                                    AssetConstants
                                        .fiveDaysWeatherBackgroundImage,
                                  ),
                                  fit: BoxFit.fill),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              color: Colors.blueAccent,
                              //5
                              boxShadow: [
                                BoxShadow(
                                    offset: Offset(3, 3),
                                    spreadRadius: 0.5,
                                    blurRadius: 0.5,
                                    color: Colors.white)
                              ]),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.arrow_circle_up,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    StringConstants.dateLabel,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Spacer(flex: 1),
                                  Text(
                                    DateFormat(StringConstants.dateFormatText)
                                        .format(_fiveDaysWeatherResponseModel
                                            .list[itemIndex].dtTxt)
                                        .toString(),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.arrow_circle_up,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    StringConstants.maximumTemperature,
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    itemIndex == 0
                                        ? (_fiveDaysWeatherResponseModel
                                                        .list[itemIndex]
                                                        .main
                                                        .tempMax -
                                                    273.15)
                                                .toStringAsFixed(3) +
                                            StringConstants.degree
                                        : (_fiveDaysWeatherResponseModel
                                                        .list[itemIndex]
                                                        .main
                                                        .tempMax -
                                                    273.15)
                                                .toStringAsFixed(3) +
                                            StringConstants.degree,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.arrow_circle_down,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    StringConstants.minimumTemperature,
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    itemIndex == 0
                                        ? (_fiveDaysWeatherResponseModel
                                                        .list[itemIndex]
                                                        .main
                                                        .tempMin -
                                                    273.15)
                                                .toStringAsFixed(3) +
                                            StringConstants.degree
                                        : (_fiveDaysWeatherResponseModel
                                                        .list[itemIndex]
                                                        .main
                                                        .tempMin -
                                                    273.15)
                                                .toStringAsFixed(3) +
                                            StringConstants.degree,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.waves,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    StringConstants.feelsLike,
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    itemIndex == 0
                                        ? (_fiveDaysWeatherResponseModel
                                                        .list[itemIndex]
                                                        .main
                                                        .feelsLike -
                                                    273.15)
                                                .toStringAsFixed(2) +
                                            StringConstants.degree
                                        : (_fiveDaysWeatherResponseModel
                                                        .list[itemIndex]
                                                        .main
                                                        .feelsLike -
                                                    273.15)
                                                .toStringAsFixed(2) +
                                            StringConstants.degree,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  )
                                ],
                              ),
                            ],
                          ),
                        )
                      : Container();
                });
          }),
    );
  }
}

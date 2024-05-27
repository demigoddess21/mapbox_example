import 'dart:convert';

import 'package:astra/model/AllStates.dart';
import 'package:http/http.dart' as http;

import 'package:mapbox_gl/mapbox_gl.dart';

class APIServiceClass {
  Future<List<AllStates>> getAllStatesBounds(LatLng sw, LatLng ne) async {
    http.Response response;
    String url =
        'https://opensky-network.org/api/states/all?lamin=${sw.latitude}&lomin=${sw.longitude}&lamax=${ne.latitude}&lomax=${ne.longitude}';
    List<AllStates> dataModel = <AllStates>[];
    try {
      response = await http.post(
        Uri.parse("${url}"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      final jsonData = jsonDecode(response.body);
      final statesData = jsonData['states'];
      jsonDecode(statesData).forEach((v) {
        dataModel.add(AllStates.fromJson(v));
      });

      if (dataModel.length > 350) {
        return dataModel.sublist(0, 350);
      }
      return dataModel;
    } catch (e) {
      return List.empty();
    }
    return dataModel;
  }
}

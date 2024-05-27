import 'package:astra/model/AllStates.dart';
import 'package:flutter/cupertino.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

import '../sevice/service.dart';

class DataClass extends ChangeNotifier {
  APIServiceClass apiServiceClass = APIServiceClass();
  List<AllStates> allStates = <AllStates>[];
  getAllStatesData(LatLng sw, LatLng ne) async {
    allStates = await apiServiceClass.getAllStatesBounds(sw, ne);

    debugPrint("Data class response $allStates");
    notifyListeners();
  }
}

import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'data/data.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait(<Future<void>>[dotenv.load(fileName: 'env/.env')]);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DataClass()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  static const String ACCESS_TOKEN = String.fromEnvironment("ACCESS_TOKEN");

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static final LatLng center = const LatLng(-33.86711, 151.1947171);

  late MapboxMapController controller;
  Timer? bikeTimer;
  Timer? filterTimer;

  int filteredId = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      MapboxMap(
        accessToken: dotenv.env['ACCESS_TOKEN'].toString(),
        dragEnabled: true,
        myLocationEnabled: true,
        onMapCreated: _onMapCreated,
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
          Factory<PanGestureRecognizer>(
            () => PanGestureRecognizer(),
          ),
        },
        onMapClick: (point, latLng) {
          onMapClick(latLng);
        },
        onCameraIdle: _onCameraIdleCallback,
        onStyleLoadedCallback: _onStyleLoadedCallback,
        trackCameraPosition: true,
        initialCameraPosition: CameraPosition(
          target: center,
          zoom: 11.0,
        ),
        annotationOrder: const [],
      ),
      Positioned(
        left: 50.0,
        top: 50.0,
        bottom: 50.0,
        right: 50.0,
        child: DraggablePolygon(),
      )
    ]);

    // This trailing comma makes auto-formatting nicer for build methods.
  }

  void onMapClick(LatLng latLng) {
    if (controller != null) {
      // controller.setGeoJsonSource("fills", {"type": "geojson", "data": _fills});
    }
  }

  void updatePolygonSource() {
    if (controller != null) {
      // controller.setGeoJsonSource("fills", {"type": "geojson", "data": _fills});
    }
  }

  // void updateClosestCoordinate(LatLng tappedCoordinates) {
  //   double minDistance = double.infinity;
  //   Map<String, dynamic>? closestFeature;
  //   List<dynamic>? closestRing;
  //   int closestVertexIndex = -1;
  //   print("tapped coordinates: ${tappedCoordinates}");
  //   // Cast the features list explicitly to List<dynamic>
  //   List<dynamic> features = _fills['features'] as List<dynamic>;

  //   features.forEach((dynamic feature) {
  //     List<List<dynamic>> coordinates =
  //         (feature['geometry']['coordinates'] as List<dynamic>)
  //             .map((e) => e as List<dynamic>)
  //             .toList();
  //     coordinates.forEach((List<dynamic> ring) {
  //       for (int i = 0; i < ring.length; i++) {
  //         List<double> vertex = ring[i] as List<double>;
  //         double distance = _calculateDistance(
  //             tappedCoordinates, LatLng(vertex[1], vertex[0]));
  //         if (distance < minDistance) {
  //           minDistance = distance;
  //           closestFeature = feature as Map<String, dynamic>;
  //           closestRing = ring;
  //           closestVertexIndex = i;
  //         }
  //       }
  //     });
  //   });

  //   if (closestVertexIndex != null && closestRing != null) {
  //     closestRing![closestVertexIndex] = [
  //       tappedCoordinates.longitude,
  //       tappedCoordinates.latitude
  //     ];

  //     updatePolygonSource();
  //   }

  //   // // Optionally update the map here if needed
  //   // // mapController.updatePolygon(....)
  // }

  // double _calculateDistance(LatLng point1, LatLng point2) {
  //   var p = 0.017453292519943295; // Math.PI / 180
  //   var c = cos;
  //   var a = 0.5 -
  //       c((point2.latitude - point1.latitude) * p) / 2 +
  //       c(point1.latitude * p) *
  //           c(point2.latitude * p) *
  //           (1 - c((point2.longitude - point1.longitude) * p)) /
  //           2;
  //   return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  // }

  Future<void> _onMapCreated(MapboxMapController controller) async {
    this.controller = controller;

    final postModel = Provider.of<DataClass>(context, listen: false);
    await postModel.getAllStatesData(
        LatLng(24.9493, -125.0011), LatLng(49.5904, -66.9326));
    controller.onFeatureTapped.add(onFeatureTap);
  }

  void _onCameraIdleCallback() {
    var pos = controller.cameraPosition!.target;
    print("drag pos end: ${pos.latitude} ${pos.longitude}");
  }

  void onFeatureTap(dynamic featureId, Point<double> point, LatLng latLng) {
    final snackBar = SnackBar(
      content: Text(
        'Tapped co-ordinates $latLng ',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Theme.of(context).primaryColor,
    );
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _onStyleLoadedCallback() async {
    await controller.addGeoJsonSource("points", _points);
    await controller.addGeoJsonSource("moving", _movingFeature(0));
    await controller.addSource("fills", GeojsonSourceProperties(data: _fills));
    await controller.addFillLayer(
      "fills",
      "fills",
      FillLayerProperties(fillColor: [
        Expressions.interpolate,
        ['exponential', 0.5],
        [Expressions.zoom],
        11,
        'red',
        18,
        'green'
      ], fillOpacity: 0.4),
      belowLayerId: "water",
      filter: ['==', 'id', filteredId],
    );

    await controller.addLineLayer(
      "fills",
      "lines",
      LineLayerProperties(
          lineColor: Colors.lightBlue.toHexStringRGB(),
          lineWidth: [
            Expressions.interpolate,
            ["linear"],
            [Expressions.zoom],
            11.0,
            2.0,
            20.0,
            10.0
          ]),
    );

    await controller.addCircleLayer(
      "fills",
      "circles",
      CircleLayerProperties(
        circleRadius: 4,
        circleColor: Colors.blue.toHexStringRGB(),
      ),
    );

    await controller.addSymbolLayer(
      "points",
      "symbols",
      SymbolLayerProperties(
        iconImage: "{type}-15",
        iconSize: 2,
        iconAllowOverlap: true,
      ),
    );

    await controller.addSymbolLayer(
      "moving",
      "moving",
      SymbolLayerProperties(
        textField: [Expressions.get, "name"],
        textHaloWidth: 1,
        textSize: 10,
        textHaloColor: Colors.white.toHexStringRGB(),
        textOffset: [
          Expressions.literal,
          [0, 2]
        ],
        iconImage: "assets/plane.png",
        iconSize: 0.2,
        iconAllowOverlap: true,
        textAllowOverlap: true,
      ),
      minzoom: 11,
    );

    bikeTimer = Timer.periodic(Duration(milliseconds: 10), (t) {
      controller.setGeoJsonSource("moving", _movingFeature(t.tick / 2000));
    });

    filterTimer = Timer.periodic(Duration(seconds: 5), (t) {
      filteredId = filteredId == 0 ? 1 : 0;
      controller.setFilter('fills', ['==', 'id', filteredId]);
    });

    //new style of adding sources
  }

  @override
  void dispose() {
    bikeTimer?.cancel();
    filterTimer?.cancel();

    super.dispose();
  }
}

Map<String, dynamic> _movingFeature(double t) {
  List<double> makeLatLong(double t) {
    final angle = t * 2 * pi;
    const r = 0.025;
    const center_x = 151.1849;
    const center_y = -33.8748;
    return [
      center_x + r * sin(angle),
      center_y + r * cos(angle),
    ];
  }

  return {
    "type": "FeatureCollection",
    "features": [
      {
        "type": "Feature",
        "properties": {"name": "POGAČAR Tadej"},
        "id": 10,
        "geometry": {"type": "Point", "coordinates": makeLatLong(t)}
      },
      {
        "type": "Feature",
        "properties": {"name": "VAN AERT Wout"},
        "id": 11,
        "geometry": {"type": "Point", "coordinates": makeLatLong(t + 0.15)}
      },
    ]
  };
}

final _fills = {
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "id": 0,
      "properties": <String, dynamic>{'id': 0},
      "geometry": {
        "type": "Polygon",
        "coordinates": [
          [
            [151.178099204457737, -33.901517742631846],
            [151.179025547977773, -33.872845324482071],
            [151.147000529140399, -33.868230472039514],
            [151.150838238009328, -33.883172899638311],
            [151.14223647675135, -33.894158309528244],
            [151.155999294764086, -33.904812805307806],
            [151.178099204457737, -33.901517742631846]
          ],
          [
            [151.162657925954278, -33.879168932438581],
            [151.155323416087612, -33.890737666431583],
            [151.173659690754278, -33.897637567778119],
            [151.162657925954278, -33.879168932438581]
          ]
        ]
      }
    },
    {
      "type": "Feature",
      "id": 1,
      "properties": <String, dynamic>{'id': 1},
      "geometry": {
        "type": "Polygon",
        "coordinates": [
          [
            [151.18735077583878, -33.891143558434102],
            [151.197374605989864, -33.878357032551868],
            [151.213021560372084, -33.886475683791488],
            [151.204953599518745, -33.899463918807818],
            [151.18735077583878, -33.891143558434102]
          ]
        ]
      }
    }
  ]
};

const _points = {
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "id": 2,
      "properties": {
        "type": "restaurant",
      },
      "geometry": {
        "type": "Point",
        "coordinates": [151.184913929732943, -33.874874486427181]
      }
    },
    {
      "type": "Feature",
      "id": 3,
      "properties": {
        "type": "airport",
      },
      "geometry": {
        "type": "Point",
        "coordinates": [151.215730044667879, -33.874616048776858]
      }
    },
    {
      "type": "Feature",
      "id": 4,
      "properties": {
        "type": "bakery",
      },
      "geometry": {
        "type": "Point",
        "coordinates": [151.228803547973598, -33.892188026142584]
      }
    },
    {
      "type": "Feature",
      "id": 5,
      "properties": {
        "type": "college",
      },
      "geometry": {
        "type": "Point",
        "coordinates": [151.186470299174118, -33.902781145804774]
      }
    }
  ]
};

class DraggablePolygon extends StatefulWidget {
  @override
  _DraggablePolygonState createState() => _DraggablePolygonState();
}

class _DraggablePolygonState extends State<DraggablePolygon> {
  List<Offset> points = [
    Offset(100, 100),
    Offset(200, 100),
    Offset(250, 200),
    Offset(150, 300),
    Offset(50, 200),
  ];

  Offset? _dragStart;
  int? _draggedPointIndex;
  bool _draggingPolygon = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: CustomPaint(
        painter: PolygonPainter(points),
        child: Container(),
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    final localPosition = details.localPosition;
    bool pointSelected = false;

    for (int i = 0; i < points.length; i++) {
      if ((points[i] - localPosition).distance < 20.0) {
        _dragStart = localPosition;
        _draggedPointIndex = i;
        pointSelected = true;
        break;
      }
    }

    if (!pointSelected) {
      _dragStart = localPosition;
      _draggingPolygon = true;
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_dragStart != null) {
      final delta = details.localPosition - _dragStart!;

      setState(() {
        if (_draggingPolygon) {
          for (int i = 0; i < points.length; i++) {
            points[i] = points[i] + delta;
          }
        } else if (_draggedPointIndex != null) {
          points[_draggedPointIndex!] = details.localPosition;
        }
      });

      _dragStart = details.localPosition;
    }
  }

  void _onPanEnd(DragEndDetails details) {
    _dragStart = null;
    _draggedPointIndex = null;
    _draggingPolygon = false;
  }
}

class PolygonPainter extends CustomPainter {
  final List<Offset> points;
  PolygonPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    if (points.isNotEmpty) {
      path.moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      path.close();
    }

    canvas.drawPath(path, paint);

    for (final point in points) {
      canvas.drawCircle(point, 8.0, paint..color = Colors.red);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

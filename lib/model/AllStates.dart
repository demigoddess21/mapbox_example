class AllStates {
  String? icas24;
  String? callsign;
  String? origin_country;
  int? time_position;
  int? last_contact;
  double? longitude;
  double? latitude;
  double? baro_altitude;
  bool? on_ground;
  double? velocity;
  double? true_track;
  double? vertical_rate;
  List<int>? sensors;
  double? geo_altitude;
  String? squawk;
  bool? spi;
  int? position_source;
  int? category;

  AllStates({
    this.icas24,
    this.callsign,
    this.origin_country,
    this.time_position,
    this.last_contact,
    this.longitude,
    this.latitude,
    this.baro_altitude,
    this.on_ground,
    this.velocity,
    this.true_track,
    this.vertical_rate,
    this.sensors,
    this.geo_altitude,
    this.squawk,
    this.spi,
    this.position_source,
    this.category,
  });

  AllStates.fromJson(Map<String, dynamic> json) {
    icas24 = json[0];
    callsign = json[1];
    origin_country = json[2];
    time_position = json[3];
    last_contact = json[4];
    longitude = json[5];
    latitude = json[6];
    baro_altitude = json[7];
    on_ground = json[8];
    velocity = json[9];
    true_track = json[10];
    vertical_rate = json[11];
    sensors = json[12];
    geo_altitude = json[13];
    squawk = json[14];
    spi = json[15];
    position_source = json[16];
    category = json[18];
  }
}

class RouteCity {
  final int? id;
  final String cityId;
  final String cityName;
  final String cityEmoji;
  final int order;
  final DateTime addedAt;

  const RouteCity({
    this.id,
    required this.cityId,
    required this.cityName,
    required this.cityEmoji,
    required this.order,
    required this.addedAt,
  });

  RouteCity copyWith({int? id, int? order}) => RouteCity(
    id: id ?? this.id,
    cityId: cityId,
    cityName: cityName,
    cityEmoji: cityEmoji,
    order: order ?? this.order,
    addedAt: addedAt,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'city_id': cityId,
    'city_name': cityName,
    'city_emoji': cityEmoji,
    'order_route': order,
    'added_at': addedAt.toIso8601String(),
  };

  factory RouteCity.fromMap(Map<String, dynamic> map) => RouteCity(
    id: map['id'] as int?,
    cityId: map['city_id'] as String,
    cityName: map['city_name'] as String,
    cityEmoji: map['city_emoji'] as String,
    order: map['order_route'] as int,
    addedAt: DateTime.parse(map['added_at'] as String),
  );
}

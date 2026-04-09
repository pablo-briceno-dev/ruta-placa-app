class PlatesResult {
  final List<int> plates;
  final bool appliesToAll; // festivo especial Bogotá

  const PlatesResult({required this.plates, this.appliesToAll = false});

  factory PlatesResult.empty() => const PlatesResult(plates: []);

  factory PlatesResult.all() => const PlatesResult(
    plates: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
    appliesToAll: true,
  );

  bool get hasRestriction => plates.isNotEmpty;
}

import 'package:flutter/foundation.dart';

int findIndexList(List<List<int>> list, List<int> target) {
  return list.indexWhere((item) => listEquals(item, target));
}

List<int> findIndexesByTarget(List<List<int>> list, List<int> target) {
  final targetSet = target.toSet();

  List<int> indexes = [];

  for (int i = 0; i < list.length; i++) {
    final itemSet = list[i].toSet();

    // 👇 verificar si tienen algún elemento en común
    final hasIntersection = itemSet.intersection(targetSet).isNotEmpty;

    if (hasIntersection) {
      indexes.add(i);
    }
  }

  return indexes;
}

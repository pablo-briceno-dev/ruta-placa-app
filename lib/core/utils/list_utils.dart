import 'package:flutter/foundation.dart';

int findIndexList(List<List<int>> list, List<int> target) {
  return list.indexWhere((item) => listEquals(item, target));
}

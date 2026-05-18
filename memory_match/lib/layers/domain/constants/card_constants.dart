import 'package:flutter/material.dart';

class CardConstants {
  static const List<IconData> icons = [
    Icons.star,
    Icons.heart_broken,
    Icons.favorite,
    Icons.pets,
    Icons.beach_access,
    Icons.wb_sunny,
    Icons.cloud,
    Icons.water_drop,
    Icons.flight,
    Icons.train,
    Icons.directions_bike,
    Icons.local_pizza,
  ];

  static IconData getIconForValue(int value) {
    return icons[value % icons.length];
  }
}

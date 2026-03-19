import 'package:flutter/material.dart';

class CategoryConfig {
  static const Map<String, IconData> icons = {
    "Food": Icons.restaurant,
    "Shopping": Icons.shopping_cart,
    "Travel": Icons.directions_car,
    "Bills": Icons.receipt_long,
    "Health": Icons.local_hospital,
    "Other": Icons.category,
  };

  static const Map<String, Color> colors = {
    "Food": Colors.orange,
    "Shopping": Colors.purple,
    "Travel": Colors.blue,
    "Bills": Colors.red,
    "Health": Colors.green,
    "Other": Colors.grey,
  };

  static IconData getIcon(String category) {
    return icons[category] ?? Icons.category;
  }

  static Color getColor(String category) {
    return colors[category] ?? Colors.grey;
  }
}

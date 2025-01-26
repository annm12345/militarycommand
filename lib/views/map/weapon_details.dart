// Define the Weapon class
import 'dart:convert';
import 'package:http/http.dart' as http;

class Weapon {
  final String name;
  final double range;
  final double mil;
  final double flightTime;
  final int gunPower;
  final int id;

  Weapon({
    required this.name,
    required this.range,
    required this.mil,
    required this.flightTime,
    required this.gunPower,
    required this.id,
  });

  // Factory constructor to parse data from JSON
  factory Weapon.fromJson(Map<String, dynamic> json) {
    // Helper function to parse values into double or int
    double parseToDouble(dynamic value) {
      if (value is String) {
        return double.tryParse(value) ??
            0.0; // Convert to double, default to 0.0 if it fails
      }
      return value?.toDouble() ??
          0.0; // Handle null or non-String values, safely converting to double
    }

    int parseToInt(dynamic value) {
      if (value is String) {
        return int.tryParse(value) ??
            0; // Convert to int, default to 0 if it fails
      }
      return value?.toInt() ??
          0; // Handle null or non-String values, safely converting to int
    }

    // Parsing the fields from the JSON
    return Weapon(
      name: json['name'] ?? '', // Ensure name is a non-null String
      range: parseToDouble(json['range']), // Parse range to double
      mil: parseToDouble(json['mil']), // Parse mil to double
      flightTime:
          parseToDouble(json['flightTime']), // Parse flightTime to double
      gunPower: parseToInt(json['gunPower']), // Parse gunPower to int
      id: parseToInt(json['id']), // Parse id to int
    );
  }
}

Future<List<Weapon>> generateWeapons() async {
  try {
    final response = await http.get(
        Uri.parse('http://militarycommand.atwebpages.com/fetch_weapon.php'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      // Parse the list of weapons from the response data
      return data.map((weaponData) => Weapon.fromJson(weaponData)).toList();
    } else {
      throw Exception('Failed to load weapons');
    }
  } catch (e) {
    throw Exception('Error fetching weapons: $e');
  }
}

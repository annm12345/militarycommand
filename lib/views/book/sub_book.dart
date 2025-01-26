import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(
    home: Booklist(),
  ));
}

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

  factory Weapon.fromJson(Map<String, dynamic> json) {
    double parseToDouble(dynamic value) {
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return value?.toDouble() ?? 0.0;
    }

    int parseToInt(dynamic value) {
      if (value is String) {
        return int.tryParse(value) ?? 0;
      }
      return value?.toInt() ?? 0;
    }

    return Weapon(
      name: json['name'] ?? '',
      range: parseToDouble(json['range']),
      mil: parseToDouble(json['mil']),
      flightTime: parseToDouble(json['flightTime']),
      gunPower: parseToInt(json['gunPower']),
      id: parseToInt(json['id']),
    );
  }
}

class Booklist extends StatefulWidget {
  @override
  _BooklistState createState() => _BooklistState();
}

class _BooklistState extends State<Booklist> {
  List<Weapon> weapons = [];
  List<Weapon> filteredWeapons = [];
  String selectedWeaponType = '';
  double enteredRange = 0.0;
  int enteredGunPower = 0;

  @override
  void initState() {
    super.initState();
    fetchWeapons();
  }

  Future<void> fetchWeapons() async {
    try {
      final response = await http.get(
          Uri.parse('http://militarycommand.atwebpages.com/fetch_weapon.php'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        weapons =
            data.map((weaponData) => Weapon.fromJson(weaponData)).toList();
        setState(() {
          filteredWeapons = weapons; // Initially show all weapons
        });
      } else {
        throw Exception('Failed to load weapons');
      }
    } catch (e) {
      print('Error fetching weapons: $e');
    }
  }

  void performSearch() {
    setState(() {
      try {
        // Find the first weapon matching all criteria
        filteredWeapons = [
          weapons.firstWhere((weapon) {
            final matchesType =
                selectedWeaponType.isEmpty || weapon.name == selectedWeaponType;
            final matchesRange =
                enteredRange == 0.0 || weapon.range == enteredRange;
            final matchesGunPower =
                enteredGunPower == 0 || weapon.gunPower == enteredGunPower;

            return matchesType && matchesRange && matchesGunPower;
          })
        ];
      } catch (e) {
        // If no match is found, clear the filteredWeapons list
        filteredWeapons = [];
      }
    });
  }

  void _createNewWeapon() {
    final _formKey = GlobalKey<FormState>();
    String selectedWeaponType = '';
    double enteredRange = 0.0;
    double enteredMil = 0.0;
    int enteredGunPower = 0;
    double enteredFlightTime = 0.0;

    void saveWeapon() async {
      if (_formKey.currentState?.validate() ?? false) {
        try {
          final response = await http.post(
            Uri.parse('http://militarycommand.atwebpages.com/add_weapon.php'),
            body: {
              'name': selectedWeaponType,
              'range': enteredRange.toString(),
              'mil': enteredMil.toString(),
              'flightTime': enteredFlightTime.toString(),
              'gunPower': enteredGunPower.toString(),
            },
          );

          if (response.statusCode == 200) {
            Navigator.pop(context); // Close the modal
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Weapon added successfully!')),
            );
            fetchWeapons();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to add weapon. Try again!')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          maxChildSize: 0.9,
          minChildSize: 0.6,
          builder: (_, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.0),
                  topRight: Radius.circular(24.0),
                ),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      Text(
                        'Create New Weapon',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Weapon Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.category),
                        ),
                        items:
                            ['MA7', 'MA8', '120MM', '122MM', '105MM', '155MM']
                                .map((type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(type),
                                    ))
                                .toList(),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please select a weapon type'
                            : null,
                        onChanged: (value) {
                          selectedWeaponType = value ?? '';
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Range (meters)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.timeline),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter a range'
                            : null,
                        onChanged: (value) {
                          enteredRange = double.tryParse(value) ?? 0.0;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Mil',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.linear_scale),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter a mil value'
                            : null,
                        onChanged: (value) {
                          enteredMil = double.tryParse(value) ?? 0.0;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Gunpower',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.bolt),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter gunpower'
                            : null,
                        onChanged: (value) {
                          enteredGunPower = int.tryParse(value) ?? 0;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Flight Time (seconds)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.timer),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter flight time'
                            : null,
                        onChanged: (value) {
                          enteredFlightTime = double.tryParse(value) ?? 0.0;
                        },
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: saveWeapon,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Save Weapon',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> deleteWeapon(int id) async {
    try {
      final response = await http.post(
        Uri.parse('http://militarycommand.atwebpages.com/delete_weapon.php'),
        body: {'id': id.toString()},
      );

      if (response.statusCode == 200) {
        setState(() {
          weapons.removeWhere((weapon) => weapon.id == id);
          filteredWeapons.removeWhere((weapon) => weapon.id == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Weapon deleted successfully!')),
        );
        fetchWeapons();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete weapon. Try again!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void updateWeapon(Weapon weapon) {
    final _formKey = GlobalKey<FormState>();
    String updatedWeaponType = weapon.name;
    double updatedRange = weapon.range;
    double updatedMil = weapon.mil;
    int updatedGunPower = weapon.gunPower;
    double updatedFlightTime = weapon.flightTime;

    void saveUpdatedWeapon() async {
      if (_formKey.currentState?.validate() ?? false) {
        try {
          final response = await http.post(
            Uri.parse(
                'http://militarycommand.atwebpages.com/update_weapon.php'),
            body: {
              'id': weapon.id.toString(),
              'name': updatedWeaponType,
              'range': updatedRange.toString(),
              'mil': updatedMil.toString(),
              'flightTime': updatedFlightTime.toString(),
              'gunPower': updatedGunPower.toString(),
            },
          );

          if (response.statusCode == 200) {
            Navigator.pop(context); // Close the modal
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Weapon updated successfully!')),
            );
            fetchWeapons();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to update weapon. Try again!')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          maxChildSize: 0.9,
          minChildSize: 0.6,
          builder: (_, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.0),
                  topRight: Radius.circular(24.0),
                ),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      Text(
                        'Update Weapon',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: updatedWeaponType,
                        decoration: InputDecoration(
                          labelText: 'Weapon Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.category),
                        ),
                        items:
                            ['MA7', 'MA8', '120MM', '122MM', '105MM', '155MM']
                                .map((type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(type),
                                    ))
                                .toList(),
                        onChanged: (value) {
                          updatedWeaponType = value ?? '';
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        initialValue: updatedRange.toString(),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Range (meters)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.timeline),
                        ),
                        onChanged: (value) {
                          updatedRange = double.tryParse(value) ?? 0.0;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        initialValue: updatedMil.toString(),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Mil',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.linear_scale),
                        ),
                        onChanged: (value) {
                          updatedMil = double.tryParse(value) ?? 0.0;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        initialValue: updatedGunPower.toString(),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Gunpower',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.bolt),
                        ),
                        onChanged: (value) {
                          updatedGunPower = int.tryParse(value) ?? 0;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        initialValue: updatedFlightTime.toString(),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Flight Time (seconds)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.timer),
                        ),
                        onChanged: (value) {
                          updatedFlightTime = double.tryParse(value) ?? 0.0;
                        },
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: saveUpdatedWeapon,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Save Changes',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewWeapon,
        backgroundColor: const Color.fromARGB(255, 45, 5, 190),
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Search Weapons',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Select Weapon Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: ['MA7', 'MA8', '120MM', '122MM', '105MM', '155MM']
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    onChanged: (value) {
                      selectedWeaponType = value ?? '';
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Enter Range (km)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: Icon(Icons.timeline),
                    ),
                    onChanged: (value) {
                      enteredRange = double.tryParse(value) ?? 0.0;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Enter Gunpower',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: Icon(Icons.bolt),
                    ),
                    onChanged: (value) {
                      enteredGunPower = int.tryParse(value) ?? 0;
                    },
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: performSearch,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Search',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Results',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: filteredWeapons.length,
                itemBuilder: (context, index) {
                  final weapon = filteredWeapons[index];
                  return ListTile(
                    title: Text(weapon.name),
                    subtitle: Text(
                        'Range: ${weapon.range} km, Gunpower: ${weapon.gunPower}, Gunpower: ${weapon.mil}, Gunpower: ${weapon.flightTime}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => updateWeapon(weapon),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteWeapon(weapon.id),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

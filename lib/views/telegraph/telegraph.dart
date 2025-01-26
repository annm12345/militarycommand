import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:military_admin/views/map/sqlite.dart';

class TelegraphView extends StatelessWidget {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _ammoController = TextEditingController();
  String selectedWeaponType = 'MA7';

  // Show the create weapon form
  void _showCreateWeaponForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: selectedWeaponType,
                items: ['MA7', 'MA8', '120MM']
                    .map((weapon) => DropdownMenuItem(
                          value: weapon,
                          child: Text(weapon),
                        ))
                    .toList(),
                onChanged: (value) {
                  selectedWeaponType = value!;
                },
                decoration: const InputDecoration(
                  labelText: 'Weapon Type',
                  border: OutlineInputBorder(),
                ),
              ),
              TextField(
                controller: _amountController,
                decoration: InputDecoration(labelText: "Weapon Amount"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _ammoController,
                decoration: InputDecoration(labelText: "Ammo Amount"),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final String type =
                      selectedWeaponType; // Use the selected value
                  final int amount = int.tryParse(_amountController.text) ?? 0;
                  final int ammoAmount =
                      int.tryParse(_ammoController.text) ?? 0;

                  if (type.isNotEmpty && amount > 0 && ammoAmount > 0) {
                    final newWeapon = MyWeapon(
                        type: type, amount: amount, ammoAmount: ammoAmount);
                    await DatabaseHelper().addmyWeapon(newWeapon);
                    Navigator.of(context).pop(); // Close the modal after saving
                  } else {
                    // Show error if fields are invalid
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text("Please enter valid data for all fields")),
                    );
                  }
                },
                child: Text("Create Weapon"),
              ),
            ],
          ),
        );
      },
    );
  }

  // Show the edit weapon form
  void _showEditWeaponForm(BuildContext context, int index, MyWeapon weapon) {
    _amountController.text = weapon.amount.toString();
    _ammoController.text = weapon.ammoAmount.toString();
    selectedWeaponType = weapon.type;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: selectedWeaponType,
                items: ['MA7', 'MA8', '120MM']
                    .map((weapon) => DropdownMenuItem(
                          value: weapon,
                          child: Text(weapon),
                        ))
                    .toList(),
                onChanged: (value) {
                  selectedWeaponType = value!;
                },
                decoration: const InputDecoration(
                  labelText: 'Weapon Type',
                  border: OutlineInputBorder(),
                ),
              ),
              TextField(
                controller: _amountController,
                decoration: InputDecoration(labelText: "Weapon Amount"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _ammoController,
                decoration: InputDecoration(labelText: "Ammo Amount"),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final String type =
                      selectedWeaponType; // Use the selected value
                  final int amount = int.tryParse(_amountController.text) ?? 0;
                  final int ammoAmount =
                      int.tryParse(_ammoController.text) ?? 0;

                  if (type.isNotEmpty && amount > 0 && ammoAmount > 0) {
                    final updatedWeapon = MyWeapon(
                        type: type, amount: amount, ammoAmount: ammoAmount);
                    await DatabaseHelper().updatemyWeapon(index, updatedWeapon);
                    Navigator.of(context)
                        .pop(); // Close the modal after updating
                  } else {
                    // Show error if fields are invalid
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text("Please enter valid data for all fields")),
                    );
                  }
                },
                child: Text("Update Weapon"),
              ),
            ],
          ),
        );
      },
    );
  }

  // Delete a weapon
  void _deleteWeapon(int index) async {
    await DatabaseHelper().deletemyWeapon(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weapon List'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showCreateWeaponForm(context),
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future:
            DatabaseHelper().initHive(), // Initialize Hive before loading data
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ValueListenableBuilder(
              valueListenable: Hive.box<MyWeapon>('myweapons').listenable(),
              builder: (context, Box<MyWeapon> box, _) {
                final weapons = box.values.toList();
                return ListView.builder(
                  itemCount: weapons.length,
                  itemBuilder: (context, index) {
                    final weapon = weapons[index];
                    return ListTile(
                      title: Text(weapon.type),
                      subtitle: Text(
                          'Amount: ${weapon.amount}, Ammo: ${weapon.ammoAmount}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () =>
                                _showEditWeaponForm(context, index, weapon),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteWeapon(index),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

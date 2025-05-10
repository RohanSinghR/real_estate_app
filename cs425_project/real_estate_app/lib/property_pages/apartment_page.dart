import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'booking_page.dart';

class ApartmentPage extends StatefulWidget {
  const ApartmentPage({super.key});

  @override
  State<ApartmentPage> createState() => _ApartmentPageState();
}

class _ApartmentPageState extends State<ApartmentPage> {
  final TextEditingController locationController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController squareFootageController = TextEditingController();
  final TextEditingController roomsController = TextEditingController();
  final TextEditingController buildingTypeController = TextEditingController();
  DateTime? selectedAvailability;

  final List<Map<String, dynamic>> allApartments = [
    {
      'name': 'Skyline Heights',
      'location': 'New York',
      'state': 'NY',
      'price': 320000,
      'availability': '2025-06-10',
      'neighborhood': 'Downtown',
      'agentEmail': 'agent1@example.com',
      'numRooms': 2,
      'squareFootage': 1000,
      'building_type': 'High-Rise',
      'description': 'Modern apartment with skyline view.',
    },
    {
      'name': 'Palm Court Apartments',
      'location': 'Florida',
      'state': 'FL',
      'price': 210000,
      'availability': '2025-08-01',
      'neighborhood': 'Palm Beach',
      'agentEmail': 'agent2@example.com',
      'numRooms': 3,
      'squareFootage': 1250,
      'building_type': 'Mid-Rise',
      'description': 'Comfortable apartment close to the beach.',
    },
  ];
  Future<void> bookApartment(Map<String, dynamic> property) async {
    final url = Uri.parse('http://localhost:3000/api/book');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': 'renter@example.com',
        'property_id': property['property_id'],
        'card_number': '1234-5678-9012-3456',
        'payment_method': 'Credit Card',
        'date': DateTime.now().toIso8601String().split('T').first,
      }),
    );

    if (response.statusCode == 200) {
      print("Booking successful");
    } else {
      print("Booking failed: ${response.body}");
    }
  }

  List<Map<String, dynamic>> get filteredApartments {
    return allApartments.where((apt) {
      final matchesLocation =
          locationController.text.isEmpty ||
          apt['location'].toLowerCase().contains(
            locationController.text.toLowerCase(),
          );
      final matchesState =
          stateController.text.isEmpty ||
          apt['state'].toLowerCase().contains(
            stateController.text.toLowerCase(),
          );
      final matchesPrice =
          priceController.text.isEmpty ||
          apt['price'] <= (int.tryParse(priceController.text) ?? 9999999);
      final matchesAvailability =
          selectedAvailability == null ||
          DateTime.parse(
            apt['availability'],
          ).isAfter(selectedAvailability!.subtract(const Duration(days: 1)));
      final matchesSqft =
          squareFootageController.text.isEmpty ||
          apt['squareFootage'] >=
              (int.tryParse(squareFootageController.text) ?? 0);
      final matchesRooms =
          roomsController.text.isEmpty ||
          apt['numRooms'] == int.tryParse(roomsController.text);
      final matchesType =
          buildingTypeController.text.isEmpty ||
          apt['building_type'].toLowerCase().contains(
            buildingTypeController.text.toLowerCase(),
          );

      return matchesLocation &&
          matchesState &&
          matchesPrice &&
          matchesAvailability &&
          matchesSqft &&
          matchesRooms &&
          matchesType;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Apartments"),
        actions: [
          IconButton(
            icon: const Icon(Icons.book_online),
            tooltip: 'Open Booking',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => BookingScreen(
                        property: {
                          'name': 'Sample Apartment',
                          'location': 'Demo City',
                          'state': 'NA',
                          'price': 0,
                          'availability':
                              DateTime.now().toString().split(' ')[0],
                          'neighborhood': 'Sample Block',
                          'agentEmail': 'sample@agent.com',
                          'numRooms': 0,
                          'squareFootage': 0,
                          'description': 'This is a placeholder booking view.',
                          'image': 'images/2.jpeg',
                        },
                      ),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 10, 7, 6),
              Color.fromARGB(255, 88, 21, 1),
              Color.fromARGB(255, 133, 37, 2),
              Color.fromARGB(255, 10, 7, 6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            _buildSearchFilters(),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredApartments.length,
                itemBuilder: (context, index) {
                  final apt = filteredApartments[index];
                  return buildImageTile({...apt, 'image': 'images/2.jpeg'}, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => BookingScreen(
                              property: {...apt, 'image': 'images/2.jpeg'},
                            ),
                      ),
                    );
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchFilters() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildTextField("City", locationController)),
              const SizedBox(width: 10),
              Expanded(child: _buildTextField("State", stateController)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  "Max Price",
                  priceController,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTextField(
                  "Min Sqft",
                  squareFootageController,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  "Rooms",
                  roomsController,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTextField("Building Type", buildingTypeController),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(children: [Expanded(child: _buildDatePicker())]),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      onChanged: (_) => setState(() {}),
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: label,
        hintStyle: const TextStyle(color: Colors.black),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedAvailability ?? now,
          firstDate: now,
          lastDate: DateTime(now.year + 5),
        );
        if (picked != null) {
          setState(() => selectedAvailability = picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          hintText: 'Availability',
          hintStyle: const TextStyle(color: Colors.black),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          selectedAvailability != null
              ? selectedAvailability!.toLocal().toString().split(' ')[0]
              : 'Availability',
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}

Widget buildImageTile(Map<String, dynamic> data, VoidCallback onBook) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 30),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              data['image'] ?? 'images/2.jpeg',
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          flex: 6,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 6,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['name'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text("Location: ${data['location']}, ${data['state']}"),
                  if (data['neighborhood'] != null)
                    Text("Neighborhood: ${data['neighborhood']}"),
                  Text("Price: \$${data['price']}"),
                  Text("Availability: ${data['availability']}"),
                  if (data['agentEmail'] != null)
                    Text("Agent Email: ${data['agentEmail']}"),
                  if (data['numRooms'] != null)
                    Text("Rooms: ${data['numRooms']}"),
                  if (data['squareFootage'] != null)
                    Text("Sq. Ft: ${data['squareFootage']}"),
                  if (data['building_type'] != null)
                    Text("Building Type: ${data['building_type']}"),
                  if (data['description'] != null)
                    Text("Description: ${data['description']}"),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: onBook,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8C42),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text("Book"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

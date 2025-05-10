// ===================== booking_page.dart =====================
import 'package:flutter/material.dart';
import 'booking_page.dart';

class HousePage extends StatefulWidget {
  const HousePage({super.key});

  @override
  State<HousePage> createState() => _HousePageState();
}

class _HousePageState extends State<HousePage> {
  final TextEditingController locationController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController squareFootageController = TextEditingController();
  final TextEditingController roomsController = TextEditingController();
  final TextEditingController bathroomsController = TextEditingController();
  DateTime? selectedAvailability;

  final List<Map<String, dynamic>> allHouses = [
    {
      'name': 'Sunset Villa',
      'location': 'California',
      'state': 'CA',
      'price': 250000,
      'availability': '2025-06-01',
      'neighborhood': 'Golden Hills',
      'agentEmail': 'agent3@example.com',
      'numRooms': 4,
      'numBathrooms': 3,
      'squareFootage': 2100,
      'description': 'Elegant villa with garden and pool.',
    },
    {
      'name': 'Hillside Mansion',
      'location': 'Colorado',
      'state': 'CO',
      'price': 480000,
      'availability': '2025-08-15',
      'neighborhood': 'Aspen Rise',
      'agentEmail': 'agent4@example.com',
      'numRooms': 5,
      'numBathrooms': 4,
      'squareFootage': 3000,
      'description': 'Luxury mansion with mountain views.',
    },
  ];

  List<Map<String, dynamic>> get filteredHouses {
    return allHouses.where((house) {
      final matchesLocation = locationController.text.isEmpty ||
          house['location'].toLowerCase().contains(locationController.text.toLowerCase());
      final matchesState = stateController.text.isEmpty ||
          house['state'].toLowerCase().contains(stateController.text.toLowerCase());
      final matchesPrice = priceController.text.isEmpty ||
          house['price'] <= (int.tryParse(priceController.text) ?? 9999999);
      final matchesAvailability = selectedAvailability == null ||
          DateTime.parse(house['availability']).isAfter(selectedAvailability!.subtract(const Duration(days: 1)));
      final matchesSquareFootage = squareFootageController.text.isEmpty ||
          house['squareFootage'] >= (int.tryParse(squareFootageController.text) ?? 0);
      final matchesRooms = roomsController.text.isEmpty ||
          house['numRooms'] == int.tryParse(roomsController.text);
      final matchesBathrooms = bathroomsController.text.isEmpty ||
          house['numBathrooms'] == int.tryParse(bathroomsController.text);

      return matchesLocation && matchesState && matchesPrice && matchesAvailability &&
             matchesSquareFootage && matchesRooms && matchesBathrooms;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Houses"),
        actions: [
          IconButton(
            icon: const Icon(Icons.book_online),
            tooltip: 'Open Booking',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BookingScreen(property: {
                    'name': 'Sample House',
                    'location': 'Demo City',
                    'state': 'NA',
                    'price': 0,
                    'availability': DateTime.now().toString().split(' ')[0],
                    'neighborhood': 'Demo Neighborhood',
                    'agentEmail': 'demo@agent.com',
                    'numRooms': 0,
                    'squareFootage': 0,
                    'description': 'This is a placeholder booking view.',
                    'image': 'images/5.jpeg'
                  }),
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
                itemCount: filteredHouses.length,
                itemBuilder: (context, index) {
                  final house = filteredHouses[index];
                  return buildImageTile({...house, 'image': 'images/5.jpeg'}, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingScreen(property: {...house, 'image': 'images/5.jpeg'}),
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
              Expanded(child: _buildTextField("Max Price", priceController, keyboardType: TextInputType.number)),
              const SizedBox(width: 10),
              Expanded(child: _buildTextField("Min Sqft", squareFootageController, keyboardType: TextInputType.number)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildTextField("Rooms", roomsController, keyboardType: TextInputType.number)),
              const SizedBox(width: 10),
              Expanded(child: _buildTextField("Bathrooms", bathroomsController, keyboardType: TextInputType.number)),
            ],
          ),
          const SizedBox(height: 10),
          Row(children: [Expanded(child: _buildDatePicker())]),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
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

// ===================== image tile card =====================
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
              data['image'] ?? 'images/5.jpeg',
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
                  Text(data['name'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text("Location: ${data['location']}, ${data['state']}"),
                  if (data['neighborhood'] != null) Text("Neighborhood: ${data['neighborhood']}"),
                  Text("Price: \$${data['price']}"),
                  Text("Availability: ${data['availability']}"),
                  if (data['agentEmail'] != null) Text("Agent Email: ${data['agentEmail']}"),
                  if (data['numRooms'] != null) Text("Rooms: ${data['numRooms']}"),
                  if (data['bedrooms'] != null) Text("Bedrooms: ${data['bedrooms']}"),
                  if (data['squareFootage'] != null) Text("Sq. Ft: ${data['squareFootage']}"),
                  if (data['area'] != null) Text("Area: ${data['area']} sqft"),
                  if (data['type_of_business'] != null) Text("Business Type: ${data['type_of_business']}"),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: onBook,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8C42),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text("Book"),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    ),
  );
}
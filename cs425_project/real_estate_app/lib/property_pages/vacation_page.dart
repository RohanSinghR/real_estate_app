// ===================== vacation_home_page.dart =====================
import 'package:flutter/material.dart';
import 'booking_page.dart';

class VacationHomePage extends StatefulWidget {
  const VacationHomePage({super.key});

  @override
  State<VacationHomePage> createState() => _VacationHomePageState();
}

class _VacationHomePageState extends State<VacationHomePage> {
  final TextEditingController locationController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController squareFootageController = TextEditingController();
  final TextEditingController roomsController = TextEditingController();
  DateTime? selectedAvailability;

  final List<Map<String, dynamic>> allVacationHomes = [
    {
      'name': 'Beachside Escape',
      'location': 'Miami',
      'state': 'FL',
      'price': 450000,
      'availability': '2024-07-15',
      'description': 'A cozy home near the beach.',
      'neighborhood': 'Sunny Isles',
      'agentEmail': 'agent9@example.com',
      'numRooms': 3,
      'squareFootage': 1800,
    },
    {
      'name': 'Mountain Lodge',
      'location': 'Aspen',
      'state': 'CO',
      'price': 580000,
      'availability': '2024-09-10',
      'description': 'Cabin-style vacation home with fireplace.',
      'neighborhood': 'Snowy Pines',
      'agentEmail': 'agent10@example.com',
      'numRooms': 4,
      'squareFootage': 2200,
    },
  ];

  List<Map<String, dynamic>> get filteredVacationHomes {
    return allVacationHomes.where((home) {
      final matchesLocation = locationController.text.isEmpty ||
          home['location'].toLowerCase().contains(locationController.text.toLowerCase());
      final matchesState = stateController.text.isEmpty ||
          home['state'].toLowerCase().contains(stateController.text.toLowerCase());
      final matchesPrice = priceController.text.isEmpty ||
          home['price'] <= (int.tryParse(priceController.text) ?? 9999999);
      final matchesAvailability = selectedAvailability == null ||
          DateTime.parse(home['availability']).isAfter(selectedAvailability!.subtract(const Duration(days: 1)));
      final matchesSquareFootage = squareFootageController.text.isEmpty ||
          home['squareFootage'] >= (int.tryParse(squareFootageController.text) ?? 0);
      final matchesRooms = roomsController.text.isEmpty ||
          home['numRooms'] == int.tryParse(roomsController.text);

      return matchesLocation && matchesState && matchesPrice &&
          matchesAvailability && matchesSquareFootage && matchesRooms;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Vacation Homes"),
        actions: [
          IconButton(
            icon: const Icon(Icons.book_online),
            tooltip: 'Open Booking',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BookingScreen(property: {
                    'name': 'Sample Vacation Home',
                    'location': 'Demo City',
                    'state': 'NA',
                    'price': 0,
                    'availability': DateTime.now().toString().split(' ')[0],
                    'neighborhood': 'Demo Area',
                    'agentEmail': 'demo@agent.com',
                    'numRooms': 0,
                    'squareFootage': 0,
                    'description': 'This is a placeholder booking view.',
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
                itemCount: filteredVacationHomes.length,
                itemBuilder: (context, index) {
                  final home = filteredVacationHomes[index];
                  return buildImageTile(home, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingScreen(property: home),
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
              Expanded(child: _buildDatePicker()),
            ],
          ),
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
              'images/1.jpeg',
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
                  if (data['squareFootage'] != null) Text("Sq. Ft: ${data['squareFootage']}"),
                  if (data['description'] != null) Text("Description: ${data['description']}"),
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
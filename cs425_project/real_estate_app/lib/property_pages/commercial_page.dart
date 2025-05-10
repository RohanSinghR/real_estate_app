// ===================== commercial_building_page.dart =====================
import 'package:flutter/material.dart';
import 'booking_page.dart';

class CommercialBuildingPage extends StatefulWidget {
  const CommercialBuildingPage({super.key});

  @override
  State<CommercialBuildingPage> createState() => _CommercialBuildingPageState();
}

class _CommercialBuildingPageState extends State<CommercialBuildingPage> {
  final TextEditingController locationController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController sqftController = TextEditingController();
  final TextEditingController businessTypeController = TextEditingController();
  DateTime? selectedAvailability;

  final List<Map<String, dynamic>> allBuildings = [
    {
      'name': 'Tech Park Plaza',
      'location': 'San Jose',
      'state': 'CA',
      'price': 950000,
      'squareFootage': 8000,
      'availability': '2025-10-01',
      'type_of_business': 'IT Offices',
      'neighborhood': 'Innovation District',
      'agentEmail': 'agent5@example.com',
      'description': 'Modern tech building with smart facilities.'
    },
    {
      'name': 'Commerce Tower',
      'location': 'Seattle',
      'state': 'WA',
      'price': 1150000,
      'squareFootage': 10000,
      'availability': '2025-12-15',
      'type_of_business': 'Retail + Office',
      'neighborhood': 'Business Bay',
      'agentEmail': 'agent6@example.com',
      'description': 'High-rise office complex in prime location.'
    },
  ];

  List<Map<String, dynamic>> get filteredBuildings {
    return allBuildings.where((building) {
      final matchesLocation = locationController.text.isEmpty ||
          building['location'].toLowerCase().contains(locationController.text.toLowerCase());
      final matchesState = stateController.text.isEmpty ||
          building['state'].toLowerCase().contains(stateController.text.toLowerCase());
      final matchesPrice = priceController.text.isEmpty ||
          building['price'] <= (int.tryParse(priceController.text) ?? 9999999);
      final matchesSqft = sqftController.text.isEmpty ||
          building['squareFootage'] >= (int.tryParse(sqftController.text) ?? 0);
      final matchesBusinessType = businessTypeController.text.isEmpty ||
          building['type_of_business'].toLowerCase().contains(businessTypeController.text.toLowerCase());
      final matchesAvailability = selectedAvailability == null ||
          DateTime.parse(building['availability']).isAfter(selectedAvailability!.subtract(const Duration(days: 1)));

      return matchesLocation && matchesState && matchesPrice && matchesSqft && matchesBusinessType && matchesAvailability;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Commercial Buildings"),
        actions: [
          IconButton(
            icon: const Icon(Icons.book_online),
            tooltip: 'Open Booking',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BookingScreen(property: {
                    'name': 'Sample Commercial Building',
                    'location': 'Demo City',
                    'state': 'NA',
                    'price': 0,
                    'squareFootage': 0,
                    'availability': DateTime.now().toString().split(' ')[0],
                    'neighborhood': 'Demo Complex',
                    'type_of_business': 'Demo',
                    'agentEmail': 'sample@agent.com',
                    'description': 'This is a placeholder booking screen.',
                    'image': 'images/3.jpeg',
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
                itemCount: filteredBuildings.length,
                itemBuilder: (context, index) {
                  final b = {...filteredBuildings[index], 'image': 'images/3.jpeg'};
                  return buildImageTile(b, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingScreen(property: b),
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
              Expanded(child: _buildTextField("Min Sqft", sqftController, keyboardType: TextInputType.number)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildTextField("Type of Business", businessTypeController)),
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
              data['image'] ?? 'images/3.jpeg',
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
                  if (data['squareFootage'] != null) Text("Sq. Ft: ${data['squareFootage']}"),
                  if (data['type_of_business'] != null) Text("Business Type: ${data['type_of_business']}"),
                  if (data['agentEmail'] != null) Text("Agent Email: ${data['agentEmail']}"),
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
// ===================== land_page.dart =====================
import 'package:flutter/material.dart';
import 'booking_page.dart';

class LandPage extends StatefulWidget {
  const LandPage({super.key});

  @override
  State<LandPage> createState() => _LandPageState();
}

class _LandPageState extends State<LandPage> {
  final TextEditingController locationController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  DateTime? selectedAvailability;

  final List<Map<String, dynamic>> allLands = [
    {
      'name': 'Green Pastures',
      'location': 'Austin',
      'state': 'TX',
      'price': 300000,
      'area': 4000,
      'availability': '2025-07-01',
      'neighborhood': 'Countryside',
      'agentEmail': 'agent11@example.com',
      'description': 'Spacious farmland ideal for agriculture.'
    },
    {
      'name': 'Horizon Acres',
      'location': 'Denver',
      'state': 'CO',
      'price': 450000,
      'area': 6000,
      'availability': '2025-09-20',
      'neighborhood': 'Hillview',
      'agentEmail': 'agent12@example.com',
      'description': 'Elevated land with mountain views.'
    },
  ];

  List<Map<String, dynamic>> get filteredLands {
    return allLands.where((land) {
      final matchesLocation = locationController.text.isEmpty ||
          land['location'].toLowerCase().contains(locationController.text.toLowerCase());
      final matchesState = stateController.text.isEmpty ||
          land['state'].toLowerCase().contains(stateController.text.toLowerCase());
      final matchesPrice = priceController.text.isEmpty ||
          land['price'] <= (int.tryParse(priceController.text) ?? 9999999);
      final matchesArea = areaController.text.isEmpty ||
          land['area'] >= (int.tryParse(areaController.text) ?? 0);
      final matchesAvailability = selectedAvailability == null ||
          DateTime.parse(land['availability']).isAfter(selectedAvailability!.subtract(const Duration(days: 1)));
      return matchesLocation && matchesState && matchesPrice && matchesArea && matchesAvailability;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Lands"),
        actions: [
          IconButton(
            icon: const Icon(Icons.book_online),
            tooltip: 'Open Booking',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BookingScreen(property: {
                    'name': 'Sample Land',
                    'location': 'Demo City',
                    'state': 'NA',
                    'price': 0,
                    'availability': DateTime.now().toString().split(' ')[0],
                    'neighborhood': 'Demo Field',
                    'agentEmail': 'sample@agent.com',
                    'area': 0,
                    'description': 'This is a placeholder booking view.',
                    'image': 'images/6.jpeg',
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
                itemCount: filteredLands.length,
                itemBuilder: (context, index) {
                  final land = {...filteredLands[index], 'image': 'images/6.jpeg'};
                  return buildImageTile(land, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingScreen(property: land),
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
              Expanded(child: _buildTextField("Min Area", areaController, keyboardType: TextInputType.number)),
            ],
          ),
          const SizedBox(height: 10),
          Row(children: [Expanded(child: _buildDatePicker())]),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
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
          selectedAvailability != null ? selectedAvailability!.toLocal().toString().split(' ')[0] : 'Availability',
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
              data['image'] ?? 'images/6.jpeg',
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
                  if (data['area'] != null) Text("Area: ${data['area']} sqft"),
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

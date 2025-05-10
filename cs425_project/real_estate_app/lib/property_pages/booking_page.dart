// ===================== booking_page.dart =====================
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BookingScreen extends StatefulWidget {
  final Map<String, dynamic> property;
  const BookingScreen({super.key, required this.property});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  static final List<Map<String, dynamic>> bookings = [];

  @override
  void initState() {
    super.initState();
    final isSample =
        widget.property['name']?.toString().toLowerCase().contains('sample') ??
        false;
    if (!isSample && !(widget.property['__empty__'] == true)) {
      bookings.add(Map<String, dynamic>.from(widget.property));
    }
    fetchBookings('renter@example.com');
  }

  Future<void> fetchBookings(String email) async {
    final url = Uri.parse('http://localhost:3000/api/bookings?email=$email');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        bookings.clear();
        bookings.addAll(data.cast<Map<String, dynamic>>());
      });
    } else {
      print("Failed to fetch bookings: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Details')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final property = bookings[index];
          if (property.containsKey('__empty__') &&
              property['__empty__'] == true) {
            return const SizedBox.shrink();
          }
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(bottom: 20),
            elevation: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        bookings.removeAt(index);
                      });
                    },
                  ),
                ),
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Image.asset(
                    property['image'] ?? 'images/1.jpeg',
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property['name'] ?? 'No Name',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Location: \${property['location']}, \${property['state']}",
                      ),
                      if (property['neighborhood'] != null)
                        Text("Neighborhood: \${property['neighborhood']}"),
                      Text("Price: \$\${property['price']}"),
                      Text("Availability: \${property['availability']}"),
                      if (property.containsKey('agentEmail'))
                        Text("Agent Email: \${property['agentEmail']}"),
                      if (property.containsKey('numRooms'))
                        Text("Rooms: \${property['numRooms']}"),
                      if (property.containsKey('bedrooms'))
                        Text("Bedrooms: \${property['bedrooms']}"),
                      if (property.containsKey('squareFootage'))
                        Text("Sq. Ft: \${property['squareFootage']}"),
                      if (property.containsKey('area'))
                        Text("Area: \${property['area']} sqft"),
                      if (property.containsKey('type_of_business'))
                        Text("Business Type: \${property['type_of_business']}"),
                      if (property.containsKey('building_type'))
                        Text("Building Type: \${property['building_type']}"),
                      if (property.containsKey('description'))
                        Text("Description: \${property['description']}"),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

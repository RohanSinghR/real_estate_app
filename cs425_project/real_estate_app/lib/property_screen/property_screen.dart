import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:real_estate_app/property_pages/booking_page.dart';

class PropertiesScreen extends StatefulWidget {
  final String email;
  const PropertiesScreen({required this.email});

  @override
  State<PropertiesScreen> createState() => _PropertiesScreenState();
}

class _PropertiesScreenState extends State<PropertiesScreen> {
  String selectedType = 'All';
  final List<String> propertyTypes = [
    'All',
    'House',
    'Vacation Home',
    'Apartment',
    'Land',
    'Commercial',
  ];

  final TextEditingController priceController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController availabilityController = TextEditingController();
  final TextEditingController bedroomsController = TextEditingController();
  final TextEditingController bathroomsController = TextEditingController();
  final TextEditingController roomsController = TextEditingController();
  final TextEditingController squareFootageController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController businessTypeController = TextEditingController();
  final TextEditingController buildingTypeController = TextEditingController();

  DateTime? selectedAvailability;

  List<Map<String, dynamic>> properties = [];
  bool isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    fetchProperties();
  }

  Future<void> fetchProperties() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/properties'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          properties = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });

        print('Fetched ${properties.length} properties');
        if (properties.isNotEmpty) {
          print('Sample property: ${properties[0]}');
        }
      } else {
        setState(() {
          error = 'Failed to load properties: ${response.statusCode}';
          isLoading = false;
        });
        print(error);
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
      print(error);
    }
  }

  List<Map<String, dynamic>> get filteredProperties {
    if (properties.isEmpty) return [];

    return properties.where((property) {
      final matchesType =
          selectedType == 'All' || property['type'] == selectedType;
      // final matchesPrice =
      //     priceController.text.isEmpty ||
      //     (int.tryParse(priceController.text) != null &&
      //         property['price'] <= int.parse(priceController.text));
      final String input = priceController.text.trim();
      final int? maxPrice = int.tryParse(input.replaceAll(',', ''));

      final matchesPrice =
          maxPrice == null ||
          (() {
            final priceValue = property['price'];
            if (priceValue is int) {
              return priceValue <= maxPrice;
            } else if (priceValue is String &&
                int.tryParse(priceValue) != null) {
              return int.parse(priceValue) <= maxPrice;
            }
            return false;
          })();
      print(
        'Filtering by price <= $maxPrice | property price: ${property['price']}',
      );

      final matchesCity =
          cityController.text.isEmpty ||
          property['city'].toString().toLowerCase().contains(
            cityController.text.toLowerCase(),
          );
      final matchesState =
          stateController.text.isEmpty ||
          property['state'].toString().toLowerCase().contains(
            stateController.text.toLowerCase(),
          );
      final matchesDate =
          selectedAvailability == null ||
          (property['availability'] != null &&
              DateTime.parse(
                property['availability'],
              ).isAfter(selectedAvailability!));
      final matchesBedrooms =
          bedroomsController.text.isEmpty ||
          (selectedType == 'House' &&
              property['bedrooms']?.toString() == bedroomsController.text);
      final matchesBathrooms =
          bathroomsController.text.isEmpty ||
          (selectedType == 'House' &&
              property['bathrooms']?.toString() == bathroomsController.text);
      final matchesRooms =
          roomsController.text.isEmpty ||
          ((selectedType == 'Vacation Home' || selectedType == 'Apartment') &&
              property['rooms']?.toString() == roomsController.text);
      final matchesSquareFootage =
          squareFootageController.text.isEmpty ||
          (int.tryParse(squareFootageController.text) != null &&
              property['squareFootage'] >=
                  int.parse(squareFootageController.text));
      final matchesArea =
          areaController.text.isEmpty ||
          (selectedType == 'Land' &&
              property['area'].toString().toLowerCase().contains(
                areaController.text.toLowerCase(),
              ));
      final matchesBusinessType =
          businessTypeController.text.isEmpty ||
          (selectedType == 'Commercial' &&
              property['businessType'].toString().toLowerCase().contains(
                businessTypeController.text.toLowerCase(),
              ));
      final matchesBuildingType =
          buildingTypeController.text.isEmpty ||
          (selectedType == 'Apartment' &&
              property['buildingType'].toString().toLowerCase().contains(
                buildingTypeController.text.toLowerCase(),
              ));

      return matchesType &&
          matchesPrice &&
          matchesCity &&
          matchesState &&
          matchesDate &&
          matchesBedrooms &&
          matchesBathrooms &&
          matchesRooms &&
          matchesSquareFootage &&
          matchesArea &&
          matchesBusinessType &&
          matchesBuildingType;
    }).toList();
  }

  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.deepOrange,
              onPrimary: Colors.white,
              surface: Colors.black,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.black,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedAvailability) {
      setState(() {
        selectedAvailability = picked;
        availabilityController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void clearAllFilters() {
    setState(() {
      priceController.clear();
      cityController.clear();
      stateController.clear();
      availabilityController.clear();
      bedroomsController.clear();
      bathroomsController.clear();
      roomsController.clear();
      squareFootageController.clear();
      areaController.clear();
      businessTypeController.clear();
      buildingTypeController.clear();
      selectedAvailability = null;
      selectedType = 'All';
    });
  }

  Widget _buildFilterField(
    String label,
    TextEditingController controller,
    TextInputType inputType, {
    IconData? icon,
  }) {
    return SizedBox(
      width: 150,
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.black,
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.deepOrange),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.deepOrange),
          ),
          suffixIcon:
              icon != null ? Icon(icon, size: 20, color: Colors.white) : null,
        ),
      ),
    );
  }

  Widget _buildPropertyCard(Map<String, dynamic> property) {
    return Card(
      color: Colors.grey[900],
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => BookingScreen(
                    property: property,
                    userEmail: widget.email,
                  ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  property['image'] ?? 'images/1.jpeg',
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        height: 150,
                        width: 150,
                        color: Colors.grey[800],
                        child: const Icon(
                          Icons.home,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property['title'] ?? 'No Title',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${property['city'] ?? 'Unknown'}, ${property['state'] ?? 'Unknown'}',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    const SizedBox(height: 8),
                    if (property['type'] == 'House')
                      Text(
                        '${property['bedrooms'] ?? 0} Bed • ${property['bathrooms'] ?? 0} Bath • ${NumberFormat('#,###').format(property['squareFootage'] ?? 0)} sqft',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    if (property['type'] == 'Vacation Home')
                      Text(
                        '${property['rooms'] ?? 0} Rooms • ${NumberFormat('#,###').format(property['squareFootage'] ?? 0)} sqft',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    if (property['type'] == 'Apartment')
                      Text(
                        '${property['rooms'] ?? 0} Rooms • ${property['buildingType'] ?? 'N/A'} • ${NumberFormat('#,###').format(property['squareFootage'] ?? 0)} sqft',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    if (property['type'] == 'Land')
                      Text(
                        '${property['area'] ?? 'N/A'} • ${NumberFormat('#,###').format(property['squareFootage'] ?? 0)} sqft',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    if (property['type'] == 'Commercial')
                      Text(
                        '${property['businessType'] ?? 'Commercial'} • ${NumberFormat('#,###').format(property['squareFootage'] ?? 0)} sqft',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${NumberFormat('#,###').format(property['price'] ?? 0)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Available: ${property['availability'] ?? 'Unknown'}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => BookingScreen(
                                  property: property,
                                  userEmail: widget.email,
                                ),
                          ),
                        ).then((_) {
                          fetchProperties();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: const Text("Book Now"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Properties', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2C2C2C),
        foregroundColor: Colors.white,

        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              clearAllFilters();
              fetchProperties();
            },
            tooltip: 'Refresh',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(color: Colors.deepOrange, height: 4.0),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 73, 21, 0),
              Colors.black,
              const Color.fromARGB(255, 73, 21, 0),
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              color: Colors.black,
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterField(
                      'Price',
                      priceController,
                      TextInputType.number,
                    ),
                    const SizedBox(width: 10),
                    _buildFilterField(
                      'City',
                      cityController,
                      TextInputType.text,
                    ),
                    const SizedBox(width: 10),
                    _buildFilterField(
                      'State',
                      stateController,
                      TextInputType.text,
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => pickDate(context),
                      child: SizedBox(
                        width: 180,
                        child: AbsorbPointer(
                          child: _buildFilterField(
                            'Availability',
                            availabilityController,
                            TextInputType.text,
                            icon: Icons.calendar_today,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 150,
                      child: DropdownButtonFormField<String>(
                        value: selectedType,
                        onChanged:
                            (value) => setState(() => selectedType = value!),
                        items:
                            propertyTypes
                                .map(
                                  (type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(
                                      type,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                        dropdownColor: Colors.black,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.black,
                          labelText: 'Type',
                          labelStyle: const TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Colors.deepOrange,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Colors.deepOrange,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (selectedType == 'House') ...[
                      const SizedBox(width: 10),
                      _buildFilterField(
                        'Bedrooms',
                        bedroomsController,
                        TextInputType.number,
                      ),
                      const SizedBox(width: 10),
                      _buildFilterField(
                        'Bathrooms',
                        bathroomsController,
                        TextInputType.number,
                      ),
                    ],
                    if (selectedType == 'Vacation Home' ||
                        selectedType == 'Apartment') ...[
                      const SizedBox(width: 10),
                      _buildFilterField(
                        'Rooms',
                        roomsController,
                        TextInputType.number,
                      ),
                    ],
                    if (selectedType == 'House' ||
                        selectedType == 'Vacation Home' ||
                        selectedType == 'Apartment' ||
                        selectedType == 'Land' ||
                        selectedType == 'Commercial') ...[
                      const SizedBox(width: 10),
                      _buildFilterField(
                        'Sq. Ft.',
                        squareFootageController,
                        TextInputType.number,
                      ),
                    ],

                    if (selectedType == 'Apartment') ...[
                      const SizedBox(width: 10),
                      _buildFilterField(
                        'Building Type',
                        buildingTypeController,
                        TextInputType.text,
                      ),
                    ],

                    if (selectedType == 'Land') ...[
                      const SizedBox(width: 10),
                      _buildFilterField(
                        'Area',
                        areaController,
                        TextInputType.text,
                      ),
                    ],

                    if (selectedType == 'Commercial') ...[
                      const SizedBox(width: 10),
                      _buildFilterField(
                        'Business Type',
                        businessTypeController,
                        TextInputType.text,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            Expanded(
              child: Container(
                color: Colors.black,
                child:
                    isLoading
                        ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.deepOrange,
                          ),
                        )
                        : error.isNotEmpty
                        ? Center(
                          child: Text(
                            error,
                            style: const TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        )
                        : filteredProperties.isEmpty
                        ? const Center(
                          child: Text(
                            'No properties match your filters',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        )
                        : ListView.builder(
                          itemCount: filteredProperties.length,
                          itemBuilder: (context, index) {
                            final property = filteredProperties[index];
                            return _buildPropertyCard(property);
                          },
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class PropertyEditorScreen extends StatefulWidget {
  final String email;
  final Map<String, dynamic>? property;

  const PropertyEditorScreen({required this.email, this.property});

  @override
  State<PropertyEditorScreen> createState() => _PropertyEditorScreenState();
}

class _PropertyEditorScreenState extends State<PropertyEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String error = '';
  String successMessage = '';
  String selectedType = 'House';
  final List<String> propertyTypes = [
    'House',
    'Apartment',
    'Commercial',
    'Vacation Home',
    'Land',
  ];
  final TextEditingController propertyIdController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController availabilityController = TextEditingController();
  final TextEditingController roomsController = TextEditingController();
  final TextEditingController bathroomsController = TextEditingController();
  final TextEditingController squareFootageController = TextEditingController();
  final TextEditingController buildingTypeController = TextEditingController();
  final TextEditingController businessTypeController = TextEditingController();
  final TextEditingController areaController = TextEditingController();

  DateTime? selectedAvailability;

  @override
  void initState() {
    super.initState();
    if (widget.property != null) {
      selectedType = widget.property!['type'] ?? 'House';
      propertyIdController.text =
          widget.property!['property_id']?.toString() ?? '';
      titleController.text = widget.property!['title'] ?? '';
      priceController.text = widget.property!['price']?.toString() ?? '';
      cityController.text = widget.property!['city'] ?? '';
      stateController.text = widget.property!['state'] ?? '';
      descriptionController.text = widget.property!['details'] ?? '';

      if (widget.property!['availability'] != null) {
        availabilityController.text = widget.property!['availability'];
        try {
          selectedAvailability = DateTime.parse(
            widget.property!['availability'],
          );
        } catch (e) {
          print('Error parsing date: $e');
        }
      }
      if (selectedType == 'House') {
        roomsController.text = widget.property!['bedrooms']?.toString() ?? '';
        bathroomsController.text =
            widget.property!['bathrooms']?.toString() ?? '';
        squareFootageController.text =
            widget.property!['squareFootage']?.toString() ?? '';
      } else if (selectedType == 'Apartment') {
        roomsController.text = widget.property!['rooms']?.toString() ?? '';
        squareFootageController.text =
            widget.property!['squareFootage']?.toString() ?? '';
        buildingTypeController.text = widget.property!['buildingType'] ?? '';
      } else if (selectedType == 'Commercial') {
        squareFootageController.text =
            widget.property!['squareFootage']?.toString() ?? '';
        businessTypeController.text = widget.property!['businessType'] ?? '';
      } else if (selectedType == 'Vacation Home') {
        roomsController.text = widget.property!['rooms']?.toString() ?? '';
        squareFootageController.text =
            widget.property!['squareFootage']?.toString() ?? '';
      } else if (selectedType == 'Land') {
        areaController.text = widget.property!['area']?.toString() ?? '';
        squareFootageController.text =
            widget.property!['squareFootage']?.toString() ?? '';
      }
    } else {
      final defaultAvailability = DateTime.now().add(const Duration(days: 30));
      selectedAvailability = defaultAvailability;
      availabilityController.text = DateFormat(
        'yyyy-MM-dd',
      ).format(defaultAvailability);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedAvailability ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.deepOrange,
              onPrimary: Colors.white,
              surface: Colors.black,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.grey[900],
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

  Future<void> _saveProperty() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
      error = '';
      successMessage = '';
    });

    try {
      final propertyData = {
        'property_id': int.parse(propertyIdController.text),
        'email': widget.email,
        'type': selectedType,
        'price': int.parse(priceController.text),
        'city': cityController.text,
        'state': stateController.text,
        'description': descriptionController.text,
        'availability': availabilityController.text,
      };
      if (selectedType == 'House') {
        propertyData['num_rooms'] = int.tryParse(roomsController.text) ?? 3;
        propertyData['square_footage'] =
            int.tryParse(squareFootageController.text) ?? 1500;
      } else if (selectedType == 'Apartment') {
        propertyData['num_rooms'] = int.tryParse(roomsController.text) ?? 2;
        propertyData['square_footage'] =
            int.tryParse(squareFootageController.text) ?? 1000;
        propertyData['building_type'] = buildingTypeController.text;
      } else if (selectedType == 'Commercial') {
        propertyData['square_footage'] =
            int.tryParse(squareFootageController.text) ?? 5000;
        propertyData['type_of_business'] = businessTypeController.text;
      } else if (selectedType == 'Vacation Home') {
        propertyData['num_rooms'] = int.tryParse(roomsController.text) ?? 4;
        propertyData['square_footage'] =
            int.tryParse(squareFootageController.text) ?? 2000;
      } else if (selectedType == 'Land') {
        propertyData['area'] = int.tryParse(areaController.text) ?? 10000;
      }

      final http.Response response;

      if (widget.property == null) {
        print('Creating new property with data: $propertyData');
        response = await http.post(
          Uri.parse('http://localhost:3000/api/properties'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(propertyData),
        );
      } else {
        print(
          'Updating property ${widget.property!['property_id']} with data: $propertyData',
        );
        response = await http.put(
          Uri.parse(
            'http://localhost:3000/api/properties/${widget.property!['property_id']}',
          ),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(propertyData),
        );
      }

      print('Server response: ${response.statusCode}, ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          isLoading = false;
          successMessage =
              widget.property == null
                  ? 'Property created successfully'
                  : 'Property updated successfully';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: Colors.green,
          ),
        );
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pop(context, true);
        });
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        setState(() {
          isLoading = false;
          error = errorData['error'] ?? 'Failed to save property';
        });
      }
    } catch (e) {
      print('Error saving property: $e');
      setState(() {
        isLoading = false;
        error = 'Error: $e';
      });
    }
  }

  Future<bool> _checkIfAgent(String email) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/check-agent?email=$email'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['isAgent'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error checking agent status: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.property == null ? 'Add New Property' : 'Edit Property',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2C2C2C),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          FutureBuilder<bool>(
            future: _checkIfAgent(widget.email),
            builder: (context, snapshot) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.account_circle, color: Colors.white),
                color: Colors.grey[900],
                onSelected: (value) {
                  if (value == 'bookings') {
                    Navigator.pushNamed(
                      context,
                      '/bookings',
                      arguments: {'email': widget.email},
                    );
                  } else if (value == 'agent' && snapshot.data == true) {
                    Navigator.pushNamed(
                      context,
                      '/agent-properties',
                      arguments: {'email': widget.email},
                    );
                  } else if (value == 'logout') {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
                itemBuilder:
                    (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'bookings',
                        child: ListTile(
                          leading: Icon(Icons.book, color: Colors.white),
                          title: Text(
                            'My Bookings',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      if (snapshot.hasData && snapshot.data == true)
                        const PopupMenuItem<String>(
                          value: 'agent',
                          child: ListTile(
                            leading: Icon(Icons.business, color: Colors.white),
                            title: Text(
                              'Manage My Properties',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      const PopupMenuDivider(),
                      const PopupMenuItem<String>(
                        value: 'logout',
                        child: ListTile(
                          leading: Icon(Icons.logout, color: Colors.red),
                          title: Text(
                            'Logout',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.black,
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
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: propertyIdController,
                  decoration: _inputDecoration('Property ID'),
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a property ID';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: _inputDecoration('Property Type'),
                  dropdownColor: Colors.grey[900],
                  style: const TextStyle(color: Colors.white),
                  items:
                      propertyTypes.map((type) {
                        return DropdownMenuItem(value: type, child: Text(type));
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedType = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a property type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: titleController,
                  decoration: _inputDecoration('Title/Short Description'),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: priceController,
                  decoration: _inputDecoration('Price (USD)'),
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: cityController,
                        decoration: _inputDecoration('City'),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a city';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: stateController,
                        decoration: _inputDecoration('State'),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a state';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: availabilityController,
                      decoration: _inputDecoration(
                        'Availability Date',
                      ).copyWith(
                        suffixIcon: const Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select an availability date';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ..._buildTypeSpecificFields(),
                TextFormField(
                  controller: descriptionController,
                  decoration: _inputDecoration('Full Description'),
                  style: const TextStyle(color: Colors.white),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                if (error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      error,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (successMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      successMessage,
                      style: const TextStyle(color: Colors.green),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ElevatedButton(
                  onPressed: isLoading ? null : _saveProperty,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child:
                      isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : Text(
                            widget.property == null
                                ? 'Add Property'
                                : 'Update Property',
                            style: const TextStyle(fontSize: 16),
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTypeSpecificFields() {
    final List<Widget> fields = [];

    if (selectedType == 'House') {
      fields.addAll([
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: roomsController,
                decoration: _inputDecoration('Bedrooms'),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: bathroomsController,
                decoration: _inputDecoration('Bathrooms'),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: squareFootageController,
          decoration: _inputDecoration('Square Footage'),
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.number,
        ),
      ]);
    } else if (selectedType == 'Apartment') {
      fields.addAll([
        TextFormField(
          controller: roomsController,
          decoration: _inputDecoration('Rooms'),
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: squareFootageController,
          decoration: _inputDecoration('Square Footage'),
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: buildingTypeController,
          decoration: _inputDecoration(
            'Building Type (e.g., High-rise, Low-rise)',
          ),
          style: const TextStyle(color: Colors.white),
        ),
      ]);
    } else if (selectedType == 'Commercial') {
      fields.addAll([
        TextFormField(
          controller: squareFootageController,
          decoration: _inputDecoration('Square Footage'),
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: businessTypeController,
          decoration: _inputDecoration('Business Type (e.g., Office, Retail)'),
          style: const TextStyle(color: Colors.white),
        ),
      ]);
    } else if (selectedType == 'Vacation Home') {
      fields.addAll([
        TextFormField(
          controller: roomsController,
          decoration: _inputDecoration('Rooms'),
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: squareFootageController,
          decoration: _inputDecoration('Square Footage'),
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.number,
        ),
      ]);
    } else if (selectedType == 'Land') {
      fields.addAll([
        TextFormField(
          controller: areaController,
          decoration: _inputDecoration('Area (in square feet)'),
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.number,
        ),
      ]);
    }

    return fields;
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.grey[900],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.deepOrange, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.deepOrange, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }
}

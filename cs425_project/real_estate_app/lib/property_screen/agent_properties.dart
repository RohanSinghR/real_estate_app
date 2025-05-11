// agent_properties_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:real_estate_app/property_screen/propertyEditor.dart';

class AgentPropertiesScreen extends StatefulWidget {
  final String email;
  const AgentPropertiesScreen({required this.email});

  @override
  State<AgentPropertiesScreen> createState() => _AgentPropertiesScreenState();
}

class _AgentPropertiesScreenState extends State<AgentPropertiesScreen> {
  List<Map<String, dynamic>> properties = [];
  bool isLoading = true;
  bool isAgent = false;
  String error = '';

  @override
  void initState() {
    super.initState();
    checkAgentStatus();
  }

  Future<void> checkAgentStatus() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/users/type?email=${widget.email}'),
      );

      print(
        'Agent status check response: ${response.statusCode}, ${response.body}',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final userType = data['user_type'] ?? '';

        setState(() {
          isAgent = userType.toLowerCase() == 'agent';
        });

        if (isAgent) {
          fetchAgentProperties();
        } else {
          setState(() {
            error = 'You must be an agent to manage properties';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          error = 'Failed to verify agent status: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error checking agent status: $e');
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> fetchAgentProperties() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      final response = await http.get(
        Uri.parse(
          'http://localhost:3000/api/agent-properties?email=${widget.email}',
        ),
      );

      print(
        'Agent properties response: ${response.statusCode}, ${response.body}',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          properties = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });

        print('Fetched ${properties.length} agent properties');
      } else {
        setState(() {
          error =
              'Failed to load properties: ${response.statusCode}, ${response.body}';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching properties: $e');
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> deleteProperty(int propertyId) async {
    try {
      final response = await http.delete(
        Uri.parse(
          'http://localhost:3000/api/properties/$propertyId?email=${widget.email}',
        ),
      );

      print(
        'Delete property response: ${response.statusCode}, ${response.body}',
      );

      if (response.statusCode == 200) {
        fetchAgentProperties();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Property deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final errorData = json.decode(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorData['error'] ?? 'Failed to delete property'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error deleting property: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2C2C),
        foregroundColor: Colors.white,
        title: const Text(
          'My Properties',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: fetchAgentProperties,
            tooltip: 'Refresh',
          ),
        ],
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
        child:
            isLoading
                ? const Center(
                  child: CircularProgressIndicator(color: Colors.deepOrange),
                )
                : !isAgent
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        error,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Back to Properties'),
                      ),
                    ],
                  ),
                )
                : error.isNotEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        error,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: fetchAgentProperties,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
                : properties.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'You have no properties listed',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) =>
                                      PropertyEditorScreen(email: widget.email),
                            ),
                          ).then((_) => fetchAgentProperties());
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add New Property'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
                : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) =>
                                      PropertyEditorScreen(email: widget.email),
                            ),
                          ).then((_) => fetchAgentProperties());
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add New Property'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(50),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: properties.length,
                        itemBuilder: (context, index) {
                          final property = properties[index];
                          return _buildPropertyCard(property);
                        },
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildPropertyCard(Map<String, dynamic> property) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    property['image'] ?? 'images/1.jpeg',
                    height: 120,
                    width: 120,
                    fit: BoxFit.cover,
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
                      Text(
                        '\$${property['price'] ?? '0'}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                      Text(
                        'Type: ${property['type'] ?? 'Unknown'}',
                        style: TextStyle(color: Colors.grey[300]),
                      ),
                      Text(
                        'Available: ${property['availability'] ?? 'Unknown'}',
                        style: TextStyle(color: Colors.grey[300]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => PropertyEditorScreen(
                              email: widget.email,
                              property: property,
                            ),
                      ),
                    ).then((_) => fetchAgentProperties());
                  },
                  icon: const Icon(Icons.edit, size: 20),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(foregroundColor: Colors.blue),
                ),
                const SizedBox(width: 12),
                TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            backgroundColor: Colors.grey[900],
                            title: const Text(
                              'Confirm Deletion',
                              style: TextStyle(color: Colors.white),
                            ),
                            content: const Text(
                              'Are you sure you want to delete this property? This action cannot be undone.',
                              style: TextStyle(color: Colors.white),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  deleteProperty(property['property_id']);
                                },
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                    );
                  },
                  icon: const Icon(Icons.delete, size: 20),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

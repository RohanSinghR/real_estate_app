import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:confetti/confetti.dart';

class BookingScreen extends StatefulWidget {
  final Map<String, dynamic>? property;
  final String userEmail;
  const BookingScreen({required this.property, required this.userEmail});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  List<Map<String, dynamic>> bookings = [];
  bool isLoading = true;
  String error = '';
  int totalRewards = 0;
  late ConfettiController _confettiController;
  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    fetchBookings(widget.userEmail);
    if (widget.property != null) {
      bookProperty(widget.property!, widget.userEmail);
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _calculateRewards() {
    int total = 0;
    for (var booking in bookings) {
      if (booking.containsKey('price') && booking['price'] != null) {
        if (booking['price'] is String) {
          total += int.tryParse(booking['price']) ?? 0;
        } else {
          total += booking['price'] as int;
        }
      }
    }
    setState(() {
      totalRewards = total;
    });
    saveRenterData(
      email: widget.userEmail,
      preferredLocation: 'Miami',
      rewardPoints: total,
    );
  }

  Future<void> saveRenterData({
    required String email,
    required String preferredLocation,
    required int rewardPoints,
  }) async {
    try {
      final url = Uri.parse('http://localhost:3000/api/renter');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'preferred_location': preferredLocation,
          'reward_points': rewardPoints,
        }),
      );

      if (response.statusCode == 200) {
        print('Renter data saved successfully.');
      } else {
        print('Failed to save renter data: ${response.body}');
      }
    } catch (e) {
      print('Exception while saving renter data: $e');
    }
  }

  Future<bool> bookProperty(Map<String, dynamic> property, String email) async {
    try {
      setState(() {
        isLoading = true;
        error = '';
      });
      final cardNumber = await fetchUserCardNumber(email);
      final bookingData = {
        'email': email,
        'property_id': property['property_id'],
        'card_number': cardNumber,
        'payment_method': 'Credit Card',
        'date':
            property['availability'] ??
            DateTime.now().toIso8601String().split('T')[0],
      };

      print('Booking data: $bookingData');
      final url = Uri.parse('http://localhost:3000/api/book');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(bookingData),
      );

      print('Booking response: ${response.statusCode}, ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking successful!'),
            backgroundColor: Colors.green,
          ),
        );
        fetchBookings(email);
        return true;
      } else {
        String errorMessage = 'Booking failed';

        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['error'] ?? 'Unknown error';
          if (errorMessage.contains('foreign key constraint fails')) {
            errorMessage =
                'There was a problem with your account details. Please try again.';
          }
        } catch (e) {
          errorMessage = 'Booking failed: ${response.body}';
        }

        setState(() {
          error = errorMessage;
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
        return false;
      }
    } catch (e) {
      final errorMessage = 'Error: $e';
      setState(() {
        error = errorMessage;
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
      return false;
    }
  }

  Future<String> fetchUserCardNumber(String email) async {
    try {
      final url = Uri.parse('http://localhost:3000/api/user/card?email=$email');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['card_number'] ?? '1234-5678-9012-3456';
      }
      return '1234-5678-9012-3456';
    } catch (e) {
      print('Error fetching card: $e');
      return '1234-5678-9012-3456';
    }
  }

  Future<void> fetchBookings(String email) async {
    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      final url = Uri.parse('http://localhost:3000/api/bookings?email=$email');
      final response = await http.get(url);

      print('Bookings response: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('Bookings data: ${response.body}');
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          bookings = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });

        print('Fetched ${bookings.length} bookings');
        _calculateRewards();
      } else {
        setState(() {
          error =
              'Failed to load bookings: ${response.statusCode}, ${response.body}';
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

  Future<void> deleteBooking(int bookingId) async {
    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse('http://localhost:3000/api/bookings/$bookingId');
      final response = await http.delete(url);

      print('Delete response: ${response.statusCode}, ${response.body}');

      if (response.statusCode == 200) {
        fetchBookings(widget.userEmail);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          isLoading = false;
          error = 'Failed to delete booking: ${response.body}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete booking: ${response.body}'),
            backgroundColor: const Color.fromARGB(255, 231, 86, 75),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        error = 'Error: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showRewardDialog() {
    _confettiController.play();

    showDialog(
      context: context,
      builder: (context) {
        return Stack(
          children: [
            AlertDialog(
              backgroundColor: const Color.fromARGB(221, 129, 40, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              contentPadding: const EdgeInsets.all(24),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "🎉 Woo-hoo!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.orangeAccent,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "You've earned \$${totalRewards.toString()} in rewards!",
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  const Icon(
                    Icons.celebration,
                    size: 48,
                    color: Colors.deepOrangeAccent,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    "Awesome!",
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              ],
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: 3.14 / 2,
                  emissionFrequency: 0.05,
                  numberOfParticles: 20,
                  maxBlastForce: 20,
                  minBlastForce: 8,
                  gravity: 0.2,
                  shouldLoop: false,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Bookings'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GestureDetector(
              onTap: _showRewardDialog,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 241, 241, 241),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star,
                        color: Color.fromARGB(255, 223, 64, 16),
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Rewards: \$${totalRewards.toString()}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh bookings',
            onPressed: () => fetchBookings(widget.userEmail),
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
        child:
            isLoading
                ? const Center(
                  child: CircularProgressIndicator(color: Colors.orange),
                )
                : error.isNotEmpty
                ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      error,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
                : bookings.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'You have no bookings',
                        style: TextStyle(fontSize: 18, color: Colors.white),
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
                        child: const Text('Browse Properties'),
                      ),
                    ],
                  ),
                )
                : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    return _buildBookingCard(booking);
                  },
                ),
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 4,
      color: Colors.black.withOpacity(0.7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.asset(
                  booking['image'] ?? 'images/1.jpeg',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.8),
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      if (booking['booking_id'] != null) {
                        deleteBooking(booking['booking_id']);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cannot delete: No booking ID found'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 209, 207, 201),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.deepOrange,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '\$${booking['price']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        const Color.fromARGB(255, 19, 12, 12).withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Text(
                    booking['name']?.toString() ?? 'No Name',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                _buildInfoRow(
                  Icons.location_on,
                  "Location:",
                  "${booking['location'] ?? 'Unknown'}, ${booking['state'] ?? 'Unknown'}",
                ),
                _buildInfoRow(
                  Icons.confirmation_number,
                  "Booking ID:",
                  booking['booking_id']?.toString() ?? 'Unknown',
                ),
                if (booking['neighborhood'] != null)
                  _buildInfoRow(
                    Icons.home_work,
                    "Neighborhood:",
                    booking['neighborhood']?.toString() ?? '',
                  ),
                _buildInfoRow(
                  Icons.attach_money,
                  "Price:",
                  "\$${booking['price']?.toString() ?? '0'}",
                ),
                _buildInfoRow(
                  Icons.calendar_today,
                  "Booking Date:",
                  booking['availability']?.toString() ?? 'Unknown',
                ),
                if (booking['agentEmail'] != null)
                  _buildInfoRow(
                    Icons.email,
                    "Agent:",
                    booking['agentEmail']?.toString() ?? '',
                  ),
                if (booking['numRooms'] != null)
                  _buildInfoRow(
                    Icons.door_front_door,
                    "Rooms:",
                    booking['numRooms']?.toString() ?? '',
                  ),
                if (booking['squareFootage'] != null)
                  _buildInfoRow(
                    Icons.square_foot,
                    "Sq. Ft:",
                    booking['squareFootage']?.toString() ?? '',
                  ),
                if (booking['area'] != null)
                  _buildInfoRow(
                    Icons.landscape,
                    "Area:",
                    booking['area']?.toString() ?? '',
                  ),
                if (booking['building_type'] != null)
                  _buildInfoRow(
                    Icons.business,
                    "Building Type:",
                    booking['building_type']?.toString() ?? '',
                  ),
                if (booking['type_of_business'] != null)
                  _buildInfoRow(
                    Icons.store,
                    "Business Type:",
                    booking['type_of_business']?.toString() ?? '',
                  ),
                if (booking['description'] != null) ...[
                  const SizedBox(height: 10),
                  const Text(
                    "Description:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    booking['description']?.toString() ?? '',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, dynamic value) {
    final String displayValue = value?.toString() ?? 'N/A';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.deepOrange),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              displayValue,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}

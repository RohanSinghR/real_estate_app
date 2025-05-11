import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentsPage extends StatefulWidget {
  final String userType;
  final String email;

  const PaymentsPage({super.key, required this.userType, required this.email});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  List<Map<String, String>> paymentCards = [];
  bool isLoading = true;
  String? errorMessage;
  bool isEditing = false;
  int? editingCardIndex;

  @override
  void initState() {
    super.initState();
    fetchPaymentCards();
  }

  Future<void> fetchPaymentCards() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      print('Fetching cards for email: ${widget.email}');

      final response = await http
          .get(
            Uri.parse(
              'http://localhost:3000/api/cards?email=${Uri.encodeComponent(widget.email)}',
            ),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Connection timed out'),
          );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        print('Decoded ${data.length} cards from response');

        if (data.isEmpty) {
          setState(() {
            paymentCards = [];
            isLoading = false;
          });
        } else {
          setState(() {
            paymentCards =
                data.map<Map<String, String>>((card) {
                  final cardNumber = card['card_number']?.toString() ?? '';
                  final last4 =
                      cardNumber.length >= 4
                          ? cardNumber.substring(cardNumber.length - 4)
                          : cardNumber;
                  String expiryDate = card['expiry_date']?.toString() ?? '';
                  if (expiryDate.isNotEmpty && expiryDate.contains('-')) {
                    final parts = expiryDate.split('-');
                    if (parts.length >= 2) {
                      expiryDate = '${parts[1]}/${parts[0].substring(2)}';
                    }
                  }
                  final billingAddress =
                      card['billing_address']?.toString() ??
                      'No address provided';
                  final cvv = card['cvv'] != null ? '***' : '';

                  return {
                    'last4': last4,
                    'expiry': expiryDate,
                    'card_number': cardNumber,
                    'billing_address': billingAddress,
                    'cvv': cvv,
                  };
                }).toList();
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage =
              'Failed to load payment methods. Server returned ${response.statusCode}: ${response.body}';
          isLoading = false;
        });
        print('Error loading cards: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load payment methods: ${e.toString()}';
        isLoading = false;
      });
      print('Error fetching payment cards: $e');
    }
  }

  Future<void> deleteCard(String cardNumber) async {
    try {
      print('Deleting card: $cardNumber');

      final response = await http.delete(
        Uri.parse('http://localhost:3000/api/cards'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'card_number': cardNumber}),
      );

      print('Delete response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Payment method deleted successfully'),
            backgroundColor: const Color.fromARGB(255, 255, 161, 126),
            behavior: SnackBarBehavior.floating,
          ),
        );
        fetchPaymentCards();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete payment method: ${response.body}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('Exception deleting card: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete payment method: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> updateCard(String cardNumber, String billingAddress) async {
    try {
      final body = {
        'card_number': cardNumber,
        'billing_address': billingAddress,
      };

      print('Updating card with data: $body');

      final response = await http.put(
        Uri.parse('http://localhost:3000/api/cards'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print('Update response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Payment method updated successfully'),
            backgroundColor: const Color.fromARGB(255, 255, 161, 126),
            behavior: SnackBarBehavior.floating,
          ),
        );
        fetchPaymentCards();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update payment method: ${response.body}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('Exception updating card: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update payment method: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void showEditCardDialog(Map<String, String> card) {
    final billingController = TextEditingController(
      text: card['billing_address'] ?? '',
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF2C2C2C),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                const Icon(
                  Icons.edit,
                  color: Color.fromARGB(255, 255, 161, 126),
                  size: 24,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Update Payment Method',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Card Number',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white24, width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.credit_card,
                          color: Colors.white54,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '**** **** **** ${card['last4']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Billing Address',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: billingController,
                    decoration: InputDecoration(
                      hintText: 'Enter billing address',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                      ),
                      filled: true,
                      fillColor: Colors.black12,
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white24),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 255, 161, 126),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(
                        Icons.location_on,
                        color: Colors.white54,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (billingController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Billing address cannot be empty'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }

                  Navigator.pop(context);
                  updateCard(card['card_number']!, billingController.text);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB27E),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Update',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
    );
  }

  void showAddCardDialog() {
    final numberController = TextEditingController();
    final cvvController = TextEditingController();
    final billingController = TextEditingController();
    String month = '01';
    String year = DateTime.now().year.toString();

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  backgroundColor: const Color(0xFF2C2C2C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Row(
                    children: [
                      const Icon(
                        Icons.add_card,
                        color: Color.fromARGB(255, 255, 161, 126),
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Add Payment Method',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: numberController,
                          decoration: InputDecoration(
                            labelText: 'Card Number',
                            labelStyle: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.3),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 255, 161, 126),
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                            prefixIcon: const Icon(
                              Icons.credit_card,
                              color: Colors.white54,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: cvvController,
                          decoration: InputDecoration(
                            labelText: 'CVV',
                            labelStyle: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.3),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 255, 161, 126),
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                            counterStyle: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                            ),
                            prefixIcon: const Icon(
                              Icons.security,
                              color: Colors.white54,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          style: const TextStyle(color: Colors.white),
                          obscureText: true,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: billingController,
                          decoration: InputDecoration(
                            labelText: 'Billing Address',
                            labelStyle: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.3),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 255, 161, 126),
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                            prefixIcon: const Icon(
                              Icons.location_on,
                              color: Colors.white54,
                            ),
                          ),
                          maxLines: 3,
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white24, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Expiration Date',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: month,
                                      isExpanded: true,
                                      dropdownColor: const Color(0xFF2C2C2C),
                                      decoration: InputDecoration(
                                        labelText: 'Month',
                                        labelStyle: TextStyle(
                                          color: Colors.white.withOpacity(0.6),
                                          fontSize: 12,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.white.withOpacity(
                                              0.3,
                                            ),
                                          ),
                                        ),
                                      ),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      items:
                                          List.generate(
                                                12,
                                                (i) => (i + 1)
                                                    .toString()
                                                    .padLeft(2, '0'),
                                              )
                                              .map(
                                                (m) => DropdownMenuItem(
                                                  value: m,
                                                  child: Text(m),
                                                ),
                                              )
                                              .toList(),
                                      onChanged:
                                          (val) => setDialogState(
                                            () => month = val!,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: year,
                                      isExpanded: true,
                                      dropdownColor: const Color(0xFF2C2C2C),
                                      decoration: InputDecoration(
                                        labelText: 'Year',
                                        labelStyle: TextStyle(
                                          color: Colors.white.withOpacity(0.6),
                                          fontSize: 12,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.white.withOpacity(
                                              0.3,
                                            ),
                                          ),
                                        ),
                                      ),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      items:
                                          List.generate(
                                                10,
                                                (i) =>
                                                    (DateTime.now().year + i)
                                                        .toString(),
                                              )
                                              .map(
                                                (y) => DropdownMenuItem(
                                                  value: y,
                                                  child: Text(y),
                                                ),
                                              )
                                              .toList(),
                                      onChanged:
                                          (val) =>
                                              setDialogState(() => year = val!),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (numberController.text.isEmpty ||
                            cvvController.text.isEmpty ||
                            billingController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill all fields'),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        final expiry = '$year-$month-01';
                        final body = {
                          'card_number': numberController.text,
                          'cvv': cvvController.text,
                          'billing_address': billingController.text,
                          'expiry_date': expiry,
                          'email': widget.email,
                        };

                        print('Sending add card request: $body');

                        try {
                          final res = await http.post(
                            Uri.parse('http://localhost:3000/api/cards'),
                            headers: {'Content-Type': 'application/json'},
                            body: jsonEncode(body),
                          );

                          print(
                            'Add card response: ${res.statusCode} - ${res.body}',
                          );

                          if (res.statusCode == 200) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Payment method added successfully',
                                ),
                                backgroundColor: Color.fromARGB(
                                  255,
                                  255,
                                  161,
                                  126,
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            fetchPaymentCards();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Failed to add payment method: ${res.body}',
                                ),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        } catch (e) {
                          print('Exception adding card: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Failed to add payment method: ${e.toString()}',
                              ),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFB27E),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userType.toLowerCase() == "agent") {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Payments'),
          elevation: 0,
          backgroundColor: const Color(0xFF2C2C2C),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 64, color: Colors.white.withOpacity(0.5)),
              const SizedBox(height: 16),
              const Text(
                'Only renters can access this page',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('${widget.userType}'),
          elevation: 0,
          backgroundColor: const Color(0xFF2C2C2C),
          foregroundColor: Colors.white,
        ),
        backgroundColor: const Color(0xFF0D0D0D),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: showAddCardDialog,
          icon: const Icon(Icons.add),
          label: const Text('Add Card'),
          backgroundColor: const Color.fromARGB(255, 255, 161, 126),
          foregroundColor: Colors.black,
          elevation: 4,
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
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: const Color.fromARGB(255, 255, 161, 126),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Loading payment methods...',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  )
                  : errorMessage != null
                  ? Center(
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      margin: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2C),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.red.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.error_outline,
                              size: 56,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 28),
                          const Text(
                            'Connection Error',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 28),
                          ElevatedButton.icon(
                            onPressed: fetchPaymentCards,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Try Again'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFB27E),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              elevation: 4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  : paymentCards.isEmpty
                  ? Center(
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      margin: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2C),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(
                          color: const Color.fromARGB(
                            255,
                            255,
                            161,
                            126,
                          ).withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(
                                255,
                                255,
                                161,
                                126,
                              ).withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.credit_card_off,
                              size: 56,
                              color: Color.fromARGB(255, 255, 161, 126),
                            ),
                          ),
                          const SizedBox(height: 28),
                          const Text(
                            'No payment methods found',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Add a credit card to make payments',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 28),
                          ElevatedButton.icon(
                            onPressed: showAddCardDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Payment Method'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFB27E),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              elevation: 4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  : Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 16,
                            bottom: 12,
                            left: 4,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 4,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(
                                    255,
                                    255,
                                    161,
                                    126,
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Saved Cards',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: paymentCards.length,
                            itemBuilder: (context, index) {
                              final card = paymentCards[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(0xFF2C2C2C),
                                            const Color(0xFF232323),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.3,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          10,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          const Color.fromARGB(
                                                            255,
                                                            255,
                                                            161,
                                                            126,
                                                          ).withOpacity(0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    child: const Icon(
                                                      Icons.credit_card,
                                                      color: Color.fromARGB(
                                                        255,
                                                        255,
                                                        161,
                                                        126,
                                                      ),
                                                      size: 24,
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFFFFC36B,
                                                      ).withOpacity(0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: const Icon(
                                                      Icons.memory,
                                                      color: Color(0xFFFFC36B),
                                                      size: 20,
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              const SizedBox(height: 16),
                                              Text(
                                                '**** **** **** ${card['last4']}',
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  letterSpacing: 1.5,
                                                ),
                                              ),

                                              const SizedBox(height: 20),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                        'EXPIRES',
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          color: Colors.white70,
                                                          letterSpacing: 1.0,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        card['expiry'] ?? '',
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                        'CVV',
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          color: Colors.white70,
                                                          letterSpacing: 1.0,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      const Text(
                                                        '***',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Material(
                                                        color:
                                                            Colors.transparent,
                                                        child: InkWell(
                                                          onTap: () {
                                                            showEditCardDialog(
                                                              card,
                                                            );
                                                          },
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  8,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  const Color.fromARGB(
                                                                    255,
                                                                    255,
                                                                    161,
                                                                    126,
                                                                  ).withOpacity(
                                                                    0.2,
                                                                  ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    12,
                                                                  ),
                                                            ),
                                                            child: const Icon(
                                                              Icons.edit,
                                                              color:
                                                                  Color.fromARGB(
                                                                    255,
                                                                    255,
                                                                    161,
                                                                    126,
                                                                  ),
                                                              size: 20,
                                                            ),
                                                          ),
                                                        ),
                                                      ),

                                                      const SizedBox(width: 8),
                                                      Material(
                                                        color:
                                                            Colors.transparent,
                                                        child: InkWell(
                                                          onTap: () {
                                                            showDialog(
                                                              context: context,
                                                              builder:
                                                                  (
                                                                    _,
                                                                  ) => AlertDialog(
                                                                    backgroundColor:
                                                                        const Color(
                                                                          0xFF2C2C2C,
                                                                        ),
                                                                    shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            16,
                                                                          ),
                                                                    ),
                                                                    title: const Text(
                                                                      'Delete Payment Method',
                                                                      style: TextStyle(
                                                                        color:
                                                                            Colors.white,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                    content: const Text(
                                                                      'Are you sure you want to delete this payment method?',
                                                                      style: TextStyle(
                                                                        color:
                                                                            Colors.white70,
                                                                      ),
                                                                    ),
                                                                    actions: [
                                                                      TextButton(
                                                                        onPressed:
                                                                            () => Navigator.pop(
                                                                              context,
                                                                            ),
                                                                        child: const Text(
                                                                          'Cancel',
                                                                          style: TextStyle(
                                                                            color:
                                                                                Colors.white70,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      ElevatedButton(
                                                                        onPressed: () {
                                                                          Navigator.pop(
                                                                            context,
                                                                          );
                                                                          deleteCard(
                                                                            card['card_number']!,
                                                                          );
                                                                        },
                                                                        style: ElevatedButton.styleFrom(
                                                                          backgroundColor:
                                                                              Colors.red,
                                                                          foregroundColor:
                                                                              Colors.white,
                                                                          shape: RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.circular(
                                                                              8,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        child: const Text(
                                                                          'Delete',
                                                                          style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                            );
                                                          },
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  8,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color: Colors.red
                                                                  .withOpacity(
                                                                    0.2,
                                                                  ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    12,
                                                                  ),
                                                            ),
                                                            child: const Icon(
                                                              Icons
                                                                  .delete_outline,
                                                              color: Colors.red,
                                                              size: 20,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),

                                              const SizedBox(height: 16),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'BILLING ADDRESS',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.white70,
                                                      letterSpacing: 1.0,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Container(
                                                    width: double.infinity,
                                                    padding:
                                                        const EdgeInsets.all(
                                                          10,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.black26,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      border: Border.all(
                                                        color: Colors.white10,
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      card['billing_address'] ??
                                                          'No address provided',
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Colors.white70,
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    Positioned(
                                      top: 0,
                                      left: 24,
                                      right: 24,
                                      child: Container(
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                            255,
                                            255,
                                            161,
                                            126,
                                          ),
                                          borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(4),
                                            bottomRight: Radius.circular(4),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color.fromARGB(
                                                255,
                                                255,
                                                161,
                                                126,
                                              ).withOpacity(0.5),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
        ),
      );
    }
  }
}

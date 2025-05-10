import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentsPage extends StatefulWidget {
  final bool isRenter;
  final String email;

  const PaymentsPage({super.key, required this.isRenter, required this.email});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  List<Map<String, String>> paymentCards = [];
  bool isLoading = true;
  String? errorMessage;

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
                  // Handle potential null or invalid card numbers
                  final cardNumber = card['card_number']?.toString() ?? '';
                  final last4 =
                      cardNumber.length >= 4
                          ? cardNumber.substring(cardNumber.length - 4)
                          : cardNumber;

                  // Format the expiry date for display
                  String expiryDate = card['expiry_date']?.toString() ?? '';
                  if (expiryDate.isNotEmpty && expiryDate.contains('-')) {
                    final parts = expiryDate.split('-');
                    if (parts.length >= 2) {
                      expiryDate = '${parts[1]}/${parts[0].substring(2)}';
                    }
                  }

                  return {
                    'last4': last4,
                    'expiry': expiryDate,
                    'card_number': cardNumber,
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
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        fetchPaymentCards();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete payment method: ${response.body}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('Exception deleting card: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete payment method: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
                  backgroundColor: const Color(
                    0xFF2C2C2C,
                  ), // charcoal gray surface from theme.dart
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Text(
                    'Add Payment Method',
                    style: TextStyle(
                      color: const Color.fromARGB(
                        255,
                        255,
                        161,
                        126,
                      ), // sunset orange from theme.dart
                      fontWeight: FontWeight.bold,
                    ),
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
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.3),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: const Color.fromARGB(
                                  255,
                                  255,
                                  161,
                                  126,
                                ), // sunset orange from theme.dart
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: cvvController,
                          decoration: InputDecoration(
                            labelText: 'CVV',
                            labelStyle: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.3),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            counterStyle: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: billingController,
                          decoration: InputDecoration(
                            labelText: 'Billing Address',
                            labelStyle: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.3),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          maxLines: 2,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surface.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Expiration Date',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: month,
                                      isExpanded: true,
                                      dropdownColor:
                                          Theme.of(context).colorScheme.surface,
                                      decoration: InputDecoration(
                                        labelText: 'Month',
                                        labelStyle: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.6),
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
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.3),
                                          ),
                                        ),
                                      ),
                                      style: TextStyle(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
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
                                      dropdownColor:
                                          Theme.of(context).colorScheme.surface,
                                      decoration: InputDecoration(
                                        labelText: 'Year',
                                        labelStyle: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.6),
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
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.3),
                                          ),
                                        ),
                                      ),
                                      style: TextStyle(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
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
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (numberController.text.isEmpty ||
                            cvvController.text.isEmpty ||
                            billingController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Please fill all fields'),
                              backgroundColor:
                                  Theme.of(context).colorScheme.error,
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
                              SnackBar(
                                content: const Text(
                                  'Payment method added successfully',
                                ),
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
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
                                backgroundColor:
                                    Theme.of(context).colorScheme.error,
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
                              backgroundColor:
                                  Theme.of(context).colorScheme.error,
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
    if (!widget.isRenter) {
      return Scaffold(
        appBar: AppBar(title: const Text('Payments'), elevation: 0),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock,
                size: 64,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Only renters can access this page',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Payment Methods'),
        elevation: 0,
        backgroundColor: const Color(
          0xFF2C2C2C,
        ), // charcoal gray from theme.dart
        foregroundColor: Colors.white, // from theme.dart
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showAddCardDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Card'),
        backgroundColor: const Color.fromARGB(
          255,
          255,
          161,
          126,
        ), // sunset orange from theme.dart
        foregroundColor: Colors.black, // text/icons on primary from theme.dart
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
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading payment methods...',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                )
                : errorMessage != null
                ? Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.error.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Oops! Something went wrong',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: fetchPaymentCards,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                : paymentCards.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surface.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.credit_card_off,
                          size: 48,
                          color: const Color.fromARGB(
                            255,
                            255,
                            161,
                            126,
                          ).withOpacity(0.8), // sunset orange from theme.dart
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No payment methods found',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add a credit card to get started',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: showAddCardDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Payment Method'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
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
                        child: Text(
                          'Saved Cards',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.8),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: paymentCards.length,
                          itemBuilder: (context, index) {
                            final card = paymentCards[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).colorScheme.surface,
                                    Theme.of(
                                      context,
                                    ).colorScheme.surface.withOpacity(0.7),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Material(
                                  color: Colors.transparent,
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16),
                                    leading: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                          255,
                                          255,
                                          161,
                                          126,
                                        ).withOpacity(
                                          0.2,
                                        ), // sunset orange from theme.dart
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.credit_card,
                                        color: const Color.fromARGB(
                                          255,
                                          255,
                                          161,
                                          126,
                                        ), // sunset orange from theme.dart
                                        size: 28,
                                      ),
                                    ),
                                    title: Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: Text(
                                        '**** **** **** ${card['last4']}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    subtitle: Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 14,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.6),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Expires: ${card['expiry']}',
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: IconButton(
                                      icon: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.error.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.delete_outline,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.error,
                                        ),
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder:
                                              (_) => AlertDialog(
                                                backgroundColor: const Color(
                                                  0xFF2C2C2C,
                                                ), // charcoal gray from theme.dart
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                title: Text(
                                                  'Delete Payment Method',
                                                  style: TextStyle(
                                                    color:
                                                        Theme.of(
                                                          context,
                                                        ).colorScheme.onSurface,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                content: Text(
                                                  'Are you sure you want to delete this payment method?',
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface
                                                        .withOpacity(0.8),
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed:
                                                        () => Navigator.pop(
                                                          context,
                                                        ),
                                                    child: Text(
                                                      'Cancel',
                                                      style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurface
                                                            .withOpacity(0.8),
                                                      ),
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      deleteCard(
                                                        card['card_number']!,
                                                      );
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          Theme.of(
                                                            context,
                                                          ).colorScheme.error,
                                                      foregroundColor:
                                                          Colors.white,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
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
                                    ),
                                  ),
                                ),
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

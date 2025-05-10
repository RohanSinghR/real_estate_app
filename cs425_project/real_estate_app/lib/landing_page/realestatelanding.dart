import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:real_estate_app/theme/theme.dart';
import 'package:carousel_slider/carousel_slider.dart';

class Realestatelanding extends StatefulWidget {
  const Realestatelanding({super.key});

  @override
  State<Realestatelanding> createState() => _RealestatelandingState();
}

class _RealestatelandingState extends State<Realestatelanding> {
  bool isLoggedIn = false;
  String loggedInUserName = '';
  Widget btn(String btntext, BuildContext context, VoidCallback fn) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: SizedBox(
        width: 100,
        child: ElevatedButton(
          onPressed: fn,
          style: themeData.elevatedButtonTheme.style,
          child: Text(btntext),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.black.withOpacity(0.6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.orangeAccent),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  bool pressed = true;

  Widget _aboutCard(IconData icon, String title, String subtitle) {
    return Container(
      height: 150,
      width: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 30, color: Colors.orange),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGlowingSocialIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Colors.orangeAccent, Colors.deepOrange],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orangeAccent.withOpacity(0.6),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _builtItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8)),
        ),
      ],
    );
  }

  void _showLoginDialog(BuildContext context) {
    emailController.clear();
    passwordcontroller.clear();

    MediaQueryData mediaQueryData = MediaQuery.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          insetPadding: EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Container(
            height: mediaQueryData.size.height * 0.3,
            width: mediaQueryData.size.width * 0.2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2C2C2C), Color(0xFF0D0D0D)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Login to Homify',
                  style: const TextStyle(
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.orangeAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordcontroller,
                  obscureText: obscureLogin ? true : false,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscureLogin = !obscureLogin;
                        });
                      },
                      icon:
                          obscureLogin
                              ? Icon(Icons.visibility)
                              : Icon(Icons.visibility_off),
                    ),
                    hintText: 'Password',
                    hintStyle: TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.orangeAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      login(context);
                    },
                    child: Text('Login'),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String loggedInUserType = '';
  Future<void> login(BuildContext context) async {
    final url = Uri.parse('http://localhost:3000/api/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailController.text.trim(),
          'password_hash': passwordcontroller.text.trim(),
        }),
      );

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = data['user'];

        setState(() {
          isLoggedIn = true;
          loggedInUserName = user['name'];
          loggedInUserType = user['user_type'] ?? '';
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Welcome, ${user['name']}!')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${response.body}')),
        );
      }
    } catch (e) {
      print('Login error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login error: $e')));
    }
  }

  final namecontroller = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final jobTitleController = TextEditingController();
  final agencyController = TextEditingController();
  final contactController = TextEditingController();
  final locationController = TextEditingController();
  final rewardPointsController = TextEditingController();
  final passwordcontroller = TextEditingController();
  final creditCardNameController = TextEditingController();
  final creditCardNumberController = TextEditingController();
  final creditCardCVVController = TextEditingController();
  final creditCardBillingController = TextEditingController();

  String selectedMonth = '01';
  String selectedYear = DateTime.now().year.toString();
  String userType = 'Renter';
  bool obscureSign = true;
  bool obscureLogin = true;
  void _showSignUpDialog(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);

    showDialog(
      context: context,
      builder: (_) {
        pressed = true;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.transparent,
              contentPadding: EdgeInsets.zero,
              insetPadding: EdgeInsets.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              content: Container(
                width: mediaQueryData.size.width * 0.3,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2C2C2C), Color(0xFF0D0D0D)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(
                        'Create Your Account',
                        style: TextStyle(
                          color: Colors.orangeAccent,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        style: TextStyle(color: Colors.white),
                        controller: namecontroller,
                        decoration: _inputDecoration('name'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        style: TextStyle(color: Colors.white),
                        controller: emailController,
                        decoration: _inputDecoration('Email'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        style: TextStyle(color: Colors.white),
                        controller: addressController,
                        decoration: _inputDecoration('Address'),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        style: TextStyle(color: Colors.white),
                        controller: passwordcontroller,
                        obscureText: obscureSign ? true : false,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obscureSign = !obscureSign;
                              });
                            },
                            icon:
                                obscureSign
                                    ? Icon(Icons.visibility)
                                    : Icon(Icons.visibility_off),
                          ),
                          hintText: "Password",
                          hintStyle: TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.orangeAccent),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: userType,
                        dropdownColor: Colors.grey[900],
                        decoration: _inputDecoration('I am a'),
                        items:
                            ['Agent', 'Renter'].map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(
                                  type,
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            }).toList(),
                        onChanged: (value) => setState(() => userType = value!),
                      ),
                      const SizedBox(height: 12),
                      if (userType == 'Agent') ...[
                        TextField(
                          style: TextStyle(color: Colors.white),
                          controller: jobTitleController,
                          decoration: _inputDecoration('Job Title'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          style: TextStyle(color: Colors.white),
                          controller: agencyController,
                          decoration: _inputDecoration('Real Estate Agency'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          style: TextStyle(color: Colors.white),
                          controller: contactController,
                          decoration: _inputDecoration('Phone Number'),
                        ),
                      ] else ...[
                        TextField(
                          style: TextStyle(color: Colors.white),
                          controller: locationController,
                          decoration: _inputDecoration('Preferred Location'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: creditCardNameController,
                          style: TextStyle(color: Colors.white),
                          cursorColor: Colors.orangeAccent,
                          decoration: _inputDecoration('Cardholder Name'),
                        ),
                        SizedBox(height: 12),
                        TextField(
                          controller: creditCardNumberController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: Colors.white),
                          cursorColor: Colors.orangeAccent,
                          decoration: _inputDecoration('Card Number'),
                        ),
                        SizedBox(height: 12),
                        TextField(
                          controller: creditCardCVVController,
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          style: TextStyle(color: Colors.white),
                          cursorColor: Colors.orangeAccent,
                          decoration: _inputDecoration('CVV'),
                        ),
                        SizedBox(height: 12),
                        TextField(
                          controller: creditCardBillingController,
                          style: TextStyle(color: Colors.white),
                          cursorColor: Colors.orangeAccent,
                          decoration: _inputDecoration('Billing Address'),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: selectedMonth,
                                dropdownColor: Colors.black87,
                                decoration: _inputDecoration('MM'),
                                items:
                                    List.generate(
                                      12,
                                      (index) => (index + 1).toString().padLeft(
                                        2,
                                        '0',
                                      ),
                                    ).map((month) {
                                      return DropdownMenuItem(
                                        value: month,
                                        child: Text(
                                          month,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      );
                                    }).toList(),
                                onChanged:
                                    (value) =>
                                        setState(() => selectedMonth = value!),
                              ),
                            ),
                            SizedBox(width: 6),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: selectedYear,
                                dropdownColor: Colors.black87,
                                decoration: _inputDecoration('YYYY'),
                                items:
                                    List.generate(
                                      10,
                                      (i) =>
                                          (DateTime.now().year + i).toString(),
                                    ).map((year) {
                                      return DropdownMenuItem(
                                        value: year,
                                        child: Text(
                                          year,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      );
                                    }).toList(),
                                onChanged:
                                    (value) =>
                                        setState(() => selectedYear = value!),
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 20),
                      pressed
                          ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orangeAccent,
                            ),
                            onPressed: () {
                              setState(() => pressed = false);

                              signup(context);
                            },
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(color: Colors.black),
                            ),
                          )
                          : CircularProgressIndicator(
                            color: Colors.orangeAccent,
                          ),
                      pressed
                          ? TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Colors.white70),
                            ),
                          )
                          : Text(''),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> signup(BuildContext context) async {
    final url = Uri.parse('http://localhost:3000/api/signup');
    final String normalizedUserType = userType.toLowerCase();

    final Map<String, dynamic> payload = {
      'name': namecontroller.text.trim(),
      'email': emailController.text.trim(),
      'address': addressController.text.trim(),
      'password_hash': passwordcontroller.text.trim(),
      'user_type': normalizedUserType,
    };

    if (normalizedUserType == 'agent') {
      payload.addAll({
        'job_title': jobTitleController.text.trim(),
        'agency': agencyController.text.trim(),
        'contact_info': contactController.text.trim(),
      });
    } else if (normalizedUserType == 'renter') {
      final expiryDate = '$selectedYear-$selectedMonth-01';
      payload.addAll({
        'preferred_location': locationController.text.trim(),
        'credit_card_number': creditCardNumberController.text.trim(),
        'credit_card_cvv': creditCardCVVController.text.trim(),
        'credit_card_billing_address': creditCardBillingController.text.trim(),
        'credit_card_expiry': expiryDate,
      });
    }

    try {
      print('Sending signup request with payload: $payload');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      print('Signup response status: ${response.statusCode}');
      print('Signup response body: ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign up successful! Please login.')),
        );

        namecontroller.clear();
        emailController.clear();
        addressController.clear();
        passwordcontroller.clear();
        jobTitleController.clear();
        agencyController.clear();
        contactController.clear();
        locationController.clear();
        creditCardNumberController.clear();
        creditCardCVVController.clear();
        creditCardBillingController.clear();

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup failed: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error occurred: $e')));
      print('Exception during signup: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: Color(0xFFFFF5E5),

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
        child: ScrollConfiguration(
          behavior: ScrollBehavior().copyWith(scrollbars: false),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.black,
                pinned: false,
                floating: false,
                snap: false,
                expandedHeight: mediaQueryData.size.height / 2,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  title: Text(
                    'Homify',
                    style: TextStyle(
                      color: const Color.fromARGB(229, 255, 255, 255),
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: Colors.black.withOpacity(0.7),
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  centerTitle: true,
                  background: SizedBox(
                    width: double.infinity,
                    child: Image.asset(
                      'assets/images/landing1.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                actions: [
                  if (!isLoggedIn) ...[
                    btn('Login', context, () => _showLoginDialog(context)),
                    btn('Sign Up', context, () => _showSignUpDialog(context)),
                    SizedBox(width: 12),
                  ] else ...[
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: PopupMenuButton<String>(
                        offset: Offset(0, 50),
                        onSelected: (value) {
                          if (value == 'logout') {
                            setState(() {
                              isLoggedIn = false;
                              loggedInUserName = '';
                            });
                          } else if (value == 'Payment Method') {
                            Navigator.pushNamed(
                              context,
                              '/payments',
                              arguments: {
                                'userType': loggedInUserType,
                                'email': emailController.value.text,
                              },
                            );
                          } else if (value == 'Edit properties') {}
                        },
                        itemBuilder:
                            (context) => [
                              if (loggedInUserType.toLowerCase() == 'renter')
                                PopupMenuItem<String>(
                                  value: 'Payment Method',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.credit_card,
                                        color: Colors.orangeAccent,
                                      ),
                                      const SizedBox(width: 8),
                                      Text('Payment Method'),
                                    ],
                                  ),
                                )
                              else if (loggedInUserType.toLowerCase() ==
                                  'agent')
                                PopupMenuItem<String>(
                                  value: 'Edit Properties',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.home_work,
                                        color: Colors.orangeAccent,
                                      ),
                                      const SizedBox(width: 8),
                                      Text('Edit Properties'),
                                    ],
                                  ),
                                ),
                              const PopupMenuDivider(),
                              PopupMenuItem<String>(
                                value: 'logout',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.logout,
                                      color: Colors.orangeAccent,
                                    ),
                                    const SizedBox(width: 8),
                                    Text('Logout'),
                                  ],
                                ),
                              ),
                            ],
                        child: CircleAvatar(
                          backgroundColor: Colors.orangeAccent,
                          child: Text(
                            loggedInUserName.isNotEmpty
                                ? loggedInUserName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              SliverToBoxAdapter(child: SizedBox(height: 100)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Container(
                    width: mediaQueryData.size.width / 3,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText:
                            'Search by city, neighborhood, or property type',
                        prefixIcon: Icon(Icons.search, color: Colors.grey[700]),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 100)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: CarouselSlider.builder(
                    disableGesture: true,
                    itemCount: 6,
                    itemBuilder: (context, index, realIndex) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: GridTile(
                          child: Image.asset(
                            'assets/images/property${index + 1}.jpg',

                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                    options: CarouselOptions(
                      height: 500,
                      enlargeCenterPage: true,
                      autoPlay: true,
                      aspectRatio: 16 / 9,
                      autoPlayInterval: const Duration(seconds: 3),
                      viewportFraction: 0.3,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 100)),

              if (isLoggedIn && loggedInUserType.toLowerCase() == 'renter') ...[
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          const Color(0xFF0D0D0D),
                          const Color(0xFF0D0D0D),
                          const Color.fromARGB(
                            255,
                            128,
                            42,
                            11,
                          ).withOpacity(0.05),
                          const Color.fromARGB(
                            255,
                            255,
                            161,
                            126,
                          ).withOpacity(0.1),
                        ],
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.house_rounded,
                                  color: Colors.white,
                                  size: 32,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Find Your Dream Home',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.3),
                                        offset: const Offset(0, 2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'As a renter, you have access to our exclusive property listings. Browse available homes, apartments, and commercial spaces tailored to your preferences.',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Center(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/propertyType',
                                    arguments: {
                                      'email': emailController.value.text,
                                    },
                                  );
                                },
                                icon: Icon(Icons.search, color: Colors.black),
                                label: Text(
                                  'View Available Properties',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 40)),
              ] else if (isLoggedIn &&
                  loggedInUserType.toLowerCase() == 'agent') ...[
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          const Color(0xFF0D0D0D),
                          const Color(0xFF0D0D0D),
                          const Color.fromARGB(
                            255,
                            128,
                            42,
                            11,
                          ).withOpacity(0.05),
                          const Color.fromARGB(
                            255,
                            255,
                            161,
                            126,
                          ).withOpacity(0.1),
                        ],
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.home_work,
                                  color: Colors.white,
                                  size: 32,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Manage Your Listings',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.3),
                                        offset: const Offset(0, 2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Welcome back, agent! Manage your property listings, update details, add new properties, and respond to inquiries from interested renters. Your portfolio is just a click away.',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Edit properties coming soon!',
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    },
                                    icon: Icon(Icons.edit, color: Colors.black),
                                    label: Text(
                                      'Edit Properties',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Add new property feature coming soon!',
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    },
                                    icon: Icon(
                                      Icons.add_home,
                                      color: Colors.black,
                                    ),
                                    label: Text(
                                      'Add New Property',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _builtItem(
                                    'Active Listings',
                                    '5',
                                    Icons.home,
                                  ),
                                  _builtItem(
                                    'New Inquiries',
                                    '12',
                                    Icons.message,
                                  ),
                                  _builtItem(
                                    'Views This Week',
                                    '438',
                                    Icons.visibility,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 60,
                            height: 4,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.orange,
                                  Colors.deepOrangeAccent,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),

                          const SizedBox(height: 16),
                          Text(
                            'About Homify',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),

                          Text(
                            "Homify is a modern real estate platform crafted to bridge the gap between renters and property agents. Whether you're searching for an apartment, a house, a vacation home, or commercial space, Homify makes the process seamless, secure, and efficient. With personalized listings, agent-renter communication, and integrated payment support, Homify brings together trust, technology, and transparency to simplify your property journey.Your next home is just a few clicks away—experience the future of renting with Homify.",
                            style: TextStyle(
                              color: themeData.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            alignment: WrapAlignment.center,
                            children: [
                              _aboutCard(
                                Icons.house,
                                '15+ Listings',
                                'Curated sample data',
                              ),
                              _aboutCard(
                                Icons.people,
                                '10+ Test Users',
                                'Student research-based',
                              ),
                              _aboutCard(
                                Icons.star,
                                'Built by Students',
                                'Academic project',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 100)),
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1F1F1F), Color(0xFF0D0D0D)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 40,
                    horizontal: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 60,
                        height: 4,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.orange, Colors.deepOrangeAccent],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Homify',
                        style: TextStyle(
                          color: Colors.orangeAccent,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Text(
                        'Find your dream home with confidence.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.email, color: Colors.orangeAccent),
                          const SizedBox(width: 8),
                          Text(
                            'contact@homify.com',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.phone, color: Colors.orangeAccent),
                          const SizedBox(width: 8),
                          Text(
                            '+1 234 567 8900',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildGlowingSocialIcon(Icons.facebook),
                          const SizedBox(width: 20),
                          _buildGlowingSocialIcon(Icons.camera),
                          const SizedBox(width: 20),
                          _buildGlowingSocialIcon(Icons.chrome_reader_mode),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Text(
                        '© 2025 Homify. All rights reserved.',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

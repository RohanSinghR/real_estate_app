import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:real_estate_app/theme/theme.dart';
import 'package:carousel_slider/carousel_slider.dart';

class Realestatelanding extends StatefulWidget {
  Realestatelanding({super.key});

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

  Widget _buildAboutStatCard(IconData icon, String title, String subtitle) {
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

  void _showLoginDialog(BuildContext context) {
    final TextEditingController emailcontroller = TextEditingController();
    final TextEditingController passwordcontroller = TextEditingController();
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
                  controller: emailcontroller,
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
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
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
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.orangeAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
                      login(context);
                      Navigator.of(dialogContext).pop();
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

  Future<void> login(BuildContext context) async {
    final url = Uri.parse('http://localhost:3000/api/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailController.text,
          'password_hash': passwordController.text,
        }),
      );

      print('Login response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = data['user'];
        setState(() {
          isLoggedIn = true;
          loggedInUserName = user['name']; // from API response
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

  final creditCardNameController = TextEditingController();
  final creditCardNumberController = TextEditingController();
  final creditCardCVVController = TextEditingController();
  final passwordController = TextEditingController();
  String selectedMonth = '01';
  String selectedYear = DateTime.now().year.toString();
  String userType = 'Agent';
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final jobTitleController = TextEditingController();
  final agencyController = TextEditingController();
  final contactController = TextEditingController();
  final moveInDateController = TextEditingController();
  final locationController = TextEditingController();
  final budgetController = TextEditingController();

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
                        controller: nameController,
                        decoration: _inputDecoration('Full Name'),
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
                        controller: emailController,
                        decoration: _inputDecoration('Email'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: _inputDecoration('Password'),
                      ),
                      SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: userType,
                        dropdownColor: Colors.grey[900],
                        decoration: _inputDecoration('I am a'),
                        items:
                            ['Agent', 'Prospective Renter'].map((type) {
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
                          decoration: _inputDecoration('Contact Info'),
                        ),
                      ] else ...[
                        TextField(
                          style: TextStyle(color: Colors.white),
                          controller: moveInDateController,
                          decoration: _inputDecoration('Desired Move-in Date'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          style: TextStyle(color: Colors.white),
                          controller: locationController,
                          decoration: _inputDecoration('Preferred Location'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          style: TextStyle(color: Colors.white),
                          controller: budgetController,
                          decoration: _inputDecoration('Budget'),
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
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: creditCardCVVController,
                                keyboardType: TextInputType.number,
                                obscureText: true,
                                style: TextStyle(color: Colors.white),
                                cursorColor: Colors.orangeAccent,
                                decoration: _inputDecoration('CVV'),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: selectedMonth,
                                      dropdownColor: Colors.black87,
                                      decoration: _inputDecoration('MM'),
                                      items:
                                          List.generate(
                                            12,
                                            (index) => (index + 1)
                                                .toString()
                                                .padLeft(2, '0'),
                                          ).map((month) {
                                            return DropdownMenuItem(
                                              value: month,
                                              child: Text(
                                                month,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                      onChanged:
                                          (value) => setState(
                                            () => selectedMonth = value!,
                                          ),
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
                                                (DateTime.now().year + i)
                                                    .toString(),
                                          ).map((year) {
                                            return DropdownMenuItem(
                                              value: year,
                                              child: Text(
                                                year,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                      onChanged:
                                          (value) => setState(
                                            () => selectedYear = value!,
                                          ),
                                    ),
                                  ),
                                ],
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
                              setState(() {
                                pressed = false;
                              });
                              Timer(Duration(milliseconds: 2000), () {
                                signup(context);
                                Navigator.pop(context);
                                _showLoginDialog(context);
                              });
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

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': nameController.text,
        'email': emailController.text,
        'address': addressController.text,
        'password_hash': passwordController.text,
        'user_type': userType,
        'job_title': jobTitleController.text,
        'agency': agencyController.text,
        'contact_info': contactController.text,
        'move_in_date': moveInDateController.text,
        'preferred_location': locationController.text,
        'budget': int.tryParse(budgetController.text) ?? 0,
        'credit_card_name': creditCardNameController.text,
        'credit_card_number': creditCardNumberController.text,
        'credit_card_cvv': creditCardCVVController.text,
        'credit_card_exp_month': selectedMonth,
        'credit_card_exp_year': selectedYear,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sign up successful!')));
      Navigator.pop(context); // or _showLoginDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup failed: ${response.body}')),
      );
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
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
                          }
                        },
                        itemBuilder:
                            (context) => [
                              PopupMenuItem<String>(
                                value: 'logout',
                                child: Text('Logout'),
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
                          footer: Text(
                            'Property ${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
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
                          const SizedBox(height: 24),
                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            alignment: WrapAlignment.center,
                            children: [
                              _buildAboutStatCard(
                                Icons.house,
                                '500+ Properties',
                                'Premium locations',
                              ),
                              _buildAboutStatCard(
                                Icons.people,
                                '300+ Clients',
                                'Trusted worldwide',
                              ),
                              _buildAboutStatCard(
                                Icons.star,
                                'Top Agents',
                                'Local experts',
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

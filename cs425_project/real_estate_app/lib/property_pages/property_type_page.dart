import 'package:flutter/material.dart';

import 'house_page.dart';
import 'apartment_page.dart';
import 'commercial_page.dart';
import 'vacation_page.dart';
import 'land_page.dart';

final ThemeData themeData = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: Color.fromARGB(255, 255, 161, 126),
    onPrimary: Colors.black,
    secondary: Color(0xFFFFC36B),
    onSecondary: Colors.black,
    error: Colors.red,
    onError: Colors.white,
    surface: Color(0xFF2C2C2C),
    onSurface: Colors.white,
  ),
  scaffoldBackgroundColor: const Color(0xFF0D0D0D),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF2C2C2C),
    foregroundColor: Colors.white,
  ),
);

class PropertyTypePage extends StatelessWidget {
  const PropertyTypePage({super.key});

  static const List<Map<String, dynamic>> propertyTypes = [
    {'label': 'House', 'image': 'images/4.jpeg', 'page': HousePage()},
    {'label': 'Apartment', 'image': 'images/2.jpeg', 'page': ApartmentPage()},
    {
      'label': 'Commercial',
      'image': 'images/3.jpeg',
      'page': CommercialBuildingPage(),
    },
    {
      'label': 'Vacation Home',
      'image': 'images/1.jpeg',
      'page': VacationHomePage(),
    },
    {'label': 'Land', 'image': 'images/6.jpeg', 'page': LandPage()},
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeData,
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D0D0D), Color(0xFF2C2C2C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'Choose Property Type',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount =
                          constraints.maxWidth >= 1000
                              ? 4
                              : constraints.maxWidth >= 700
                              ? 3
                              : 2;

                      return GridView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: propertyTypes.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1,
                        ),
                        itemBuilder: (context, index) {
                          final property = propertyTypes[index];
                          return _buildImageButton(
                            context,
                            property['label'],
                            property['image'],
                            property['page'],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageButton(
    BuildContext context,
    String label,
    String imagePath,
    Widget page,
  ) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      style: ElevatedButton.styleFrom(padding: EdgeInsets.zero, elevation: 4),
      child: Ink(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.4),
              BlendMode.darken,
            ),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black,
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

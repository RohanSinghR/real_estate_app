import 'package:url_strategy/url_strategy.dart';
import 'package:flutter/material.dart';
import 'package:real_estate_app/landing_page/realestatelanding.dart';

void main() {
  setPathUrlStrategy();
  runApp(RealEstateMain());
}

class RealEstateMain extends StatelessWidget {
  const RealEstateMain({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Realestatelanding(),
      theme: ThemeData(useMaterial3: true),
    );
  }
}

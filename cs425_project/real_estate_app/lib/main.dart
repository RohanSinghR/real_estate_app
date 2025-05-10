import 'package:flutter/material.dart';
import 'package:real_estate_app/landing_page/realestatelanding.dart';
import 'package:real_estate_app/landing_page/settings/paymentspage.dart';
import 'package:url_strategy/url_strategy.dart';

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
      onGenerateRoute: (settings) {
        if (settings.name == '/payments') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder:
                (context) => PaymentsPage(
                  isRenter: args['isRenter'],
                  email: args['email'],
                ),
          );
        }

        return MaterialPageRoute(builder: (_) => const Realestatelanding());
      },
      initialRoute: '/',
      theme: ThemeData(useMaterial3: true),
    );
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'https://real-estate-app-backend-o7gz.onrender.com';

  static Future<String> signup({
    required String name,
    required String email,
    required String password,
    required String userType,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': 'Jane Doe',
          'email': 'jane@example.com',
          'address': '123 Homify Lane',
          'password_hash': 'secure123',
          'user_type': 'Prospective Renter',
          'move_in_date': '2025-06-01',
          'preferred_location': 'Chicago',
          'budget': 1800,
          'credit_card_name': 'Jane Doe',
          'credit_card_number': '4111111111111111',
          'credit_card_cvv': '123',
          'credit_card_exp_month': '06',
          'credit_card_exp_year': '2027',
        }),
      );

      if (response.statusCode == 200) {
        return 'Signup successful';
      } else {
        return 'Signup failed: ${response.body}';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }
}

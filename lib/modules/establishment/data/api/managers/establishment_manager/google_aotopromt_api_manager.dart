import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:symmetry_establishment/app/constants/app_config.dart';


Future<List<String>> fetchSuggestions(String input) async {
  if (input.isEmpty) return [];

  final String apiKey = AppConfig.googleApiKey;
  const String apiUrl = 'https://maps.googleapis.com/maps/api/geocode/json';
  final Uri requestUri = Uri.parse('$apiUrl?address=$input&sensor=true&key=$apiKey');

  try {
    final response = await http.get(requestUri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List results = data['results'];

      // Extract suggestions from the API response
      return results.map<String>((result) => result['formatted_address']).toList();
    } else {
      throw Exception('Failed to fetch suggestions');
    }
  } catch (e) {
    print('Error fetching suggestions: $e');
    return [];
  }
}



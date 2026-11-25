import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:login_rive_animation/models/reptile.dart';

class HerpetarioApi {
  // Chrome reaches the host as localhost. A physical phone needs the computer's
  // LAN IP (run `ipconfig`); use http://10.0.2.2:8090 for the Android emulator.
  static const String baseUrl =
      kIsWeb ? 'http://localhost:8090' : 'http://192.168.20.134:8090';

  static Future<List<Reptile>> fetchReptiles() async {
    final response = await http
        .get(Uri.parse('$baseUrl/reptiles'))
        .timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) {
      throw Exception('Error loading reptiles (HTTP ${response.statusCode})');
    }
    // Spring sends JSON without a charset, so http would fall back to Latin-1
    // and break accents ("Pitón"). Decode the raw bytes as UTF-8 instead.
    final body = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    return body
        .map((json) => Reptile.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

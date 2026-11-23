import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  // Chrome reaches the host as localhost. A physical phone needs the computer's
  // LAN IP (run `ipconfig`); use http://10.0.2.2:8090 for the Android emulator.
  static const String baseUrl =
      kIsWeb ? 'http://localhost:8090' : 'http://192.168.0.66:8090';

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  // Created once so rebuilds don't re-hit the API.
  late final Future<List<dynamic>> _products = fetchProducts();

  Future<List<dynamic>> fetchProducts() async {
    final response = await http.get(Uri.parse('${ProductsScreen.baseUrl}/products'));
    if (response.statusCode != 200) {
      throw Exception('Error loading products (HTTP ${response.statusCode})');
    }
    return jsonDecode(response.body) as List<dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Productos de Spring Boot')),
      body: FutureBuilder<List<dynamic>>(
        future: _products,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final products = snapshot.data ?? [];
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                title: Text(product['name'].toString()),
                subtitle: Text('Stock: ${product['stock']}'),
                trailing: Text('\$${product['price']}'),
              );
            },
          );
        },
      ),
    );
  }
}

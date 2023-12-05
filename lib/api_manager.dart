import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiManager {
  final String baseUrl;
  final storage = const FlutterSecureStorage();

  ApiManager({required this.baseUrl});

  //membuat fungsi memanggil api login.php
  Future<String?> authenticate(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final token = jsonResponse['token'];

      // Save the token securely
      await storage.write(key: 'auth_token', value: token);

      return token;
    } else {
      throw Exception('Failed to authenticate');
    }
  }

  //membuat fungsi memanggil api register.php
  Future<void> register(String name, String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': username, 'password': password}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to register');
    }
  }

  //membuat fungsi tambah data
  Future<void> addUser(String nama, String prodi) async {
    try {
      final token = await storage.read(key: 'auth_token');

      if (token == null) {
        throw Exception('Token not found');
      }

      final response = await http.post(
        Uri.parse(
            '$baseUrl/crud.php'), // Ganti dengan endpoint yang sesuai untuk menambahkan user
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({'nama': nama, 'prodi': prodi}),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to add user. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any errors that occurred during the addUser operation
      print('Error adding user: $e');
      throw Exception(
          'Failed to add user. Please check your connection and try again.');
    }
  }

  // Fungsi untuk menghapus data pengguna
    Future<void> deleteUser(int userId) async {
    try {
      final token = await storage.read(key: 'auth_token');

      if (token == null) {
        throw Exception('Token not found');
      }

      final response = await http.delete(
        Uri.parse(
            '$baseUrl/crud.php/$userId'), // Menggunakan DELETE request untuk hapus data pengguna berdasarkan ID
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to delete user. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any errors that occurred during the deleteUser operation
      print('Error deleting user: $e');
      throw Exception(
          'Failed to delete user. Please check your connection and try again.');
    }
  }

  //membuat fungsi memanggil api list user atau crud.php
  Future<List<Map<String, dynamic>>> getUsers() async {
    final token = await storage.read(key: 'auth_token');

    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/crud.php'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(jsonResponse['mahasiswa']);
    } else {
      throw Exception('Failed to get users');
    }
  }
}

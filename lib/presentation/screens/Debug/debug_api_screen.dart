import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/data/API/authservice.dart';
import 'package:flutter_application_1/data/API/BaseURL.dart';

class DebugAPIScreen extends StatefulWidget {
  const DebugAPIScreen({Key? key}) : super(key: key);

  @override
  State<DebugAPIScreen> createState() => _DebugAPIScreenState();
}

class _DebugAPIScreenState extends State<DebugAPIScreen> {
  String _debugLog = '';
  bool _isLoading = false;

  void _addLog(String message) {
    setState(() {
      _debugLog += '${DateTime.now().toIso8601String()}: $message\n';
    });
    print(message);
  }

  Future<void> _testAPI() async {
    setState(() {
      _isLoading = true;
      _debugLog = '';
    });

    try {
      _addLog('Starting API tests...');

      // Test 1: Check token
      final token = await AuthService.getToken();
      _addLog('Token: ${token ?? "NULL"}');

      // Test 2: Test base URL
      _addLog('Base URL: $base_url');

      // Test 3: Test Posyandu endpoint
      _addLog('Testing Posyandu endpoint...');
      final posyanduResponse = await http.get(
        Uri.parse('$base_url/posyandu'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      _addLog('Posyandu Status: ${posyanduResponse.statusCode}');
      _addLog('Posyandu Response: ${posyanduResponse.body}');

      // Test 4: Test Balita endpoint
      _addLog('Testing Balita endpoint...');
      final balitaResponse = await http.get(
        Uri.parse('$base_url/balita'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      _addLog('Balita Status: ${balitaResponse.statusCode}');
      _addLog('Balita Response: ${balitaResponse.body}');

      // Test 5: Parse JSON
      if (balitaResponse.statusCode == 200) {
        try {
          final data = json.decode(balitaResponse.body);
          _addLog('JSON parsing successful');
          _addLog('Data keys: ${data.keys.toList()}');
          if (data['data'] != null) {
            _addLog('Balita count: ${(data['data'] as List).length}');
          }
        } catch (e) {
          _addLog('JSON parsing error: $e');
        }
      }
    } catch (e) {
      _addLog('Test error: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug API'),
        backgroundColor: const Color(0xFF03A9F4),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _testAPI,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF03A9F4),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child:
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Test API'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _debugLog.isEmpty
                        ? 'Tekan tombol "Test API" untuk memulai debug'
                        : _debugLog,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

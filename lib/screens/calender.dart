import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'appointmentdetailsscreen.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  List<dynamic> appointments = [];
  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    getUserData(); // Fetch user data on screen initialization
  }

  Future<void> getUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    if (token.isNotEmpty) {
      try {
        final response = await http.get(
          Uri.parse('http://10.0.2.2:8000/api/user'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          setState(() {
            user = json.decode(response.body); // Set user data
          });
          // After fetching user data, fetch appointments
          fetchAppointments(user!['id']); // Pass the user ID to fetch appointments
        } else {
          throw Exception('Failed to load user data: ${response.statusCode}');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading user data: ${e.toString()}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to access your data')),
      );
      // Navigate to login page or show login dialog
    }
  }

  Future<void> fetchAppointments(int userId) async {
    String url = 'http://10.0.2.2:8000/api/appointments/$userId';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          appointments = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load appointments');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading appointments: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Your Appointments')),
      body: user == null // Check if user data is loaded
          ? Center(child: CircularProgressIndicator())
          : appointments.isEmpty
          ? Center(child: Text('No appointments found.'))
          : ListView.builder(
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: ListTile(
              title: Text(appointment['service']['name']),
              subtitle: Text(
                'Time: ${appointment['appointment_time']}\nStatus: ${appointment['status']}',
                style: TextStyle(color: Colors.grey),
              ),
              onTap: () {
                // Handle appointment selection if needed
                // Navigate to appointment details screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AppointmentDetailScreen(appointment: appointment),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

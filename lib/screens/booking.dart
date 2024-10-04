import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:salonease1/utils/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  Map<String, dynamic> user = {};
  List<dynamic> categories = [];
  List<dynamic> services = [];
  List<Contact> _contacts = [];
  int? selectedCategoryId;
  int? selectedServiceId;
  int? selectedStylistId;
  Contact? selectedContact;
  DateTime? selectedDateTime;

  @override
  void initState() {
    super.initState();
    getUserData();
    fetchCategories();
    fetchServices();
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
            user = json.decode(response.body);
          });
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
    }
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/categories'));
      if (response.statusCode == 200) {
        setState(() {
          categories = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading categories: ${e.toString()}')),
      );
    }
  }

  Future<void> fetchServices([int? categoryId]) async {
    String url = categoryId != null
        ? 'http://10.0.2.2:8000/api/services/$categoryId'
        : 'http://10.0.2.2:8000/api/services';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          services = json.decode(response.body);
          print('Fetched services: $services'); // Log services
        });
      } else {
        throw Exception('Failed to load services');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading services: ${e.toString()}')),
      );
    }
  }


  void onCategorySelected(int? categoryId) {
    setState(() {
      selectedCategoryId = categoryId;
    });
    fetchServices(categoryId);
  }

  void onServiceSelected(int? serviceId) {
    setState(() {
      selectedServiceId = serviceId;
      // Set the stylistId based on the selected service
      final selectedService = services.firstWhere((service) => service['id'] == serviceId, orElse: () => null);
      selectedStylistId = selectedService != null ? selectedService['stylist_id'] : null;
    });
  }

  Future<void> bookAppointment(int serviceId, int stylistId) async {
    if (selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a date and time for the appointment.')),
      );
      return;
    }

    if (user['id'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to book an appointment.')),
      );
      return;
    }

    final data = {
      'user_id': user['id'],
      'service_id': serviceId,
      'stylist_id': stylistId,
      'appointment_time': DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedDateTime!),
    };

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/appointments'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Appointment booked successfully!')),
        );
        showAppointmentConfirmation();
      } else {
        final errorMessage = json.decode(response.body)['error'] ?? 'Unknown error occurred';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to book appointment: $errorMessage')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error booking appointment: ${e.toString()}')),
      );
    }
  }

  void showAppointmentConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Appointment Confirmed'),
          content: Text('Your appointment has been successfully booked for ${DateFormat('yyyy-MM-dd HH:mm').format(selectedDateTime!)}'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _requestPermission() async {
    PermissionStatus status = await Permission.contacts.request();
    print("Permission status: $status");
    return status.isGranted;
  }

  Future<void> _fetchContacts() async {
    try {
      if (await _requestPermission()) {
        Iterable<Contact> contacts = await ContactsService.getContacts();
        setState(() {
          _contacts = contacts.toList();
        });
        print('Contacts: ${_contacts.length}');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permission denied to access contacts.')),
        );
      }
    } catch (e) {
      print('Error fetching contacts: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching contacts: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Category Dropdown
            DropdownButtonFormField<int>(
              value: selectedCategoryId,
              hint: const Text('Select Category'),
              onChanged: (int? value) {
                onCategorySelected(value);
              },
              items: categories.map<DropdownMenuItem<int>>((category) {
                return DropdownMenuItem<int>(
                  value: category['id'],
                  child: Text(category['name']),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Service List
            DropdownButtonFormField<int>(
              value: selectedServiceId,
              hint: const Text('Select Service'),
              onChanged: (int? value) {
                onServiceSelected(value); // Update stylist ID based on selected service
              },
              items: services.map<DropdownMenuItem<int>>((service) {
                return DropdownMenuItem<int>(
                  value: service['id'],
                  child: Text(service['name']),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // DateTime Picker
            TextButton.icon(
              onPressed: _selectDateTime,
              icon: const Icon(Icons.calendar_today),
              label: Text(
                selectedDateTime != null
                    ? DateFormat('yyyy-MM-dd HH:mm').format(selectedDateTime!)
                    : 'Select Date & Time',
              ),
            ),

            const SizedBox(height: 16),

            // Contact Picker
            TextButton.icon(
              onPressed: () {
                if (_contacts.isNotEmpty) {
                  _showContactsDialog(); // Display contacts in a dialog for selection
                } else {
                  _fetchContacts(); // Fetch contacts if not already fetched
                }
              },
              icon: const Icon(Icons.contacts),
              label: Text(
                selectedContact != null
                    ? selectedContact!.displayName ?? 'No Name'
                    : 'Select Contact',
              ),
            ),

            const SizedBox(height: 16),

            // Book Appointment Button
            ElevatedButton(
              onPressed: () {
                print('Selected Service ID: $selectedServiceId');
                print('Selected Stylist ID: $selectedStylistId');

                if (selectedServiceId != null && selectedStylistId != null) {
                  bookAppointment(selectedServiceId!, selectedStylistId!);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please select a service and stylist.')),
                  );
                }

              },
              child: const Text('Book Appointment'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateTime() async {
    DateTime now = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateTime ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      TimeOfDay? timePicked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDateTime ?? now),
      );

      if (timePicked != null) {
        setState(() {
          selectedDateTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            timePicked.hour,
            timePicked.minute,
          );
        });
      }
    }
  }

  void _showContactsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Contact'),
          content: SizedBox(
            height: 300,
            child: ListView.builder(
              itemCount: _contacts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_contacts[index].displayName ?? ''),
                  onTap: () {
                    setState(() {
                      selectedContact = _contacts[index];
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}

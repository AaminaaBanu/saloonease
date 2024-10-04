import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:salonease1/utils/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic> user = {};
  List<dynamic> categories = [];
  List<dynamic> services = [];
  int? selectedCategoryId;
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
      // Navigate to login page or show login dialog
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

  void selectDateTime(int serviceId, int stylistId) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
        bookAppointment(serviceId, stylistId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    return Scaffold(

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: Config.heightSize * 0.07,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: List<Widget>.generate(
                      categories.length,
                      (index) {
                        return GestureDetector(
                          onTap: () {
                            onCategorySelected(categories[index]['id']);
                          },
                          child: Card(
                            margin: const EdgeInsets.only(right: 10),
                            color: selectedCategoryId == categories[index]['id']
                                ? Colors.blue
                                : Config.primaryColor,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  FaIcon(
                                    FontAwesomeIcons.spa,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 20),
                                  Text(
                                    categories[index]['name'] ?? 'Category',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Config.spaceSmall,
                Column(
                  children: List.generate(services.length, (index) {
                    final stylist = services[index]['stylist'];
                    return Card(
                      borderOnForeground: true,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(services[index]['name'] ?? 'Service',
                            style: Theme.of(context).textTheme.labelLarge),
                        subtitle: Text(
                          'Stylist: ${stylist != null ? stylist['name'] : 'Unknown'}',
                        ),
                        trailing: Text(
                          'LKR. ${services[index]['price'] ?? 'Price'}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        onTap: () {
                          selectDateTime(services[index]['id'], stylist['id']);
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
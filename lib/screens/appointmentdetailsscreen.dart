import 'package:flutter/material.dart';
import 'package:salonease1/utils/config.dart';

class AppointmentDetailScreen extends StatelessWidget {
  final Map<String, dynamic> appointment;

  const AppointmentDetailScreen({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Appointment Details'),
      backgroundColor: Config.primaryColor),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${appointment['service']['name']}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            Text(
              'Appointment Time',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              ' ${appointment['appointment_time']}',
              style: TextStyle(fontSize: 18,),
            ),
            SizedBox(height: 10),
            Text(
              'Stylist',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${appointment['stylist']['name']}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${appointment['status']}',
              style: TextStyle(fontSize: 18,),
            ),
            SizedBox(height: 10),
            if (appointment['service']['description'] != null) // If description exists
              Text(
                'Description: ${appointment['service']['description']}',
                style: TextStyle(fontSize: 18),
              ),
            if (appointment['service']['description'] != null) // If description exists
              SizedBox(height: 10),
            Text(
              'Price',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'LKR. ${appointment['service']['price']}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            ElevatedButton(onPressed: (){
              Navigator.of(context).pop();
            }, child: Text('Bact to Appointment')),

            // Add any other details you want to show here
          ],
        ),
      ),
    );
  }
}

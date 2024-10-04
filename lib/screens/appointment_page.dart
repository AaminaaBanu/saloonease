import 'package:flutter/material.dart';
import 'package:salonease1/utils/config.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

enum FilterStatus { upcoming, completed, cancelled }

class _AppointmentPageState extends State<AppointmentPage> {
  FilterStatus status = FilterStatus.upcoming;
  Alignment _alignment = Alignment.centerLeft;
  List<dynamic> schedules = [
    {
      'Employee_name': 'Sachini Fernando',
      'Employee_profile': 'assets/stylist1.jpg',
      'category': 'Hair Stylist',
      'status': FilterStatus.upcoming,
    },
    {
      'Employee_name': 'Nimal Perera',
      'Employee_profile': 'assets/stylist2.jpeg',
      'category': 'Makeup Artist',
      'status': FilterStatus.completed,
    },
    {
      'Employee_name': 'Jeevan Perera',
      'Employee_profile': 'assets/stylist3.jpeg',
      'category': 'Makeup Artist',
      'status': FilterStatus.completed,
    },
    {
      'Employee_name': 'Kamal Silva',
      'Employee_profile': 'assets/stylist4.jpg',
      'category': 'Hair Stylist',
      'status': FilterStatus.cancelled,
    },
  ];
  @override
  Widget build(BuildContext context) {
    List<dynamic> filteredSchedules = schedules.where((schedule) {
      return schedule['status'] == status;
    }).toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Appointments Schedule',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Config.spaceSmall,
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (FilterStatus filterStatus in FilterStatus.values)
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                status = filterStatus;
                                if (status == FilterStatus.upcoming) {
                                  _alignment = Alignment.centerLeft;
                                } else if (status == FilterStatus.completed) {
                                  _alignment = Alignment.center;
                                } else {
                                  _alignment = Alignment.centerRight;
                                }
                              });
                            },
                            child: Center(
                              child: Text(filterStatus.name),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                AnimatedAlign(
                  alignment: _alignment,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    width: MediaQuery.of(context).size.width / 3,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Config.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        status.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Config.spaceSmall,
            // Add filtered schedule list here (for displaying the appointments)
            Expanded(
              child: ListView.builder(
                itemCount: filteredSchedules.length,
                itemBuilder: (context, index) {
                  var schedule = filteredSchedules[index];

                  bool isLastElement = index == filteredSchedules.length - 1;
                  return Card(
                    shape: const RoundedRectangleBorder(
                      side: BorderSide(color: Colors.grey),
                    ),
                    margin: !isLastElement
                        ? const EdgeInsets.only(bottom: 20)
                        : EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundImage:
                                    AssetImage(schedule['Employee_profile']),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    schedule['Employee_name'],
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    schedule['category'],
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          // Schedule card
                          const ScheduleCard(),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (status != FilterStatus.cancelled) ...[
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Config.primaryColor,
                                    ),
                                    onPressed: () {},
                                    child: const Text(
                                      'Reschedule',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(width: 20),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {},
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: Config.primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScheduleCard extends StatelessWidget {
  const ScheduleCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Icon(
            Icons.calendar_today,
            color: Config.primaryColor,
            size: 15,
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            'Monday 11/28/2024',
            style: TextStyle(
              color: Config.primaryColor,
            ),
          ),
          SizedBox(
            width: 20,
          ),
          Icon(
            Icons.access_alarm,
            color: Config.primaryColor,
            size: 17,
          ),
          SizedBox(
            width: 5,
          ),
          Flexible(
            child: Text(
              '10:00 AM',
              style: TextStyle(
                color: Config.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:salonease1/utils/config.dart';

class StylistCard extends StatefulWidget {
  const StylistCard({super.key});

  @override
  State<StylistCard> createState() => _StylistCardState();
}

class _StylistCardState extends State<StylistCard> {
  @override
  Widget build(BuildContext context) {
    Config().init(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 10,
      ),
      height: 150,
      child: GestureDetector(
          child: Card(
            elevation: 5,
            color: Colors.white,
            child: Row(
              children: [
                SizedBox(
                  width: Config.screenWidth! * 0.33,
                  child: Image.asset('assets/stylist2.jpeg', fit: BoxFit.fill),
                ),
                const Flexible(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Nimesh Fernando',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Makeup Artist',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        Spacer(),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Icon(
                                Icons.star,
                                color: Colors.yellow,
                                size: 16,
                              ),
                              Spacer(flex: 1),
                              Text('4.5'),
                              Spacer(flex: 1),
                              Text('(20)'),
                              Spacer(flex: 7),
                            ]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          onTap: () {
            // Redirect to employee details
          }),
    );
  }
}

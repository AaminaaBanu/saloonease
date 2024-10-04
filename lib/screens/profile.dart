import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:salonease1/utils/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class ProfileScreen extends StatefulWidget {
  final File? profileImage; // Receive the profile image
  final Function(File) onImagePicked; // Callback to notify parent of new image

  const ProfileScreen({
    Key? key,
    required this.profileImage,
    required this.onImagePicked,
  }) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _profileImage; // Local image to be displayed
  Map<String, dynamic> user = {}; // Store user data
  String _address = 'Searching...'; // Store user location
  String _currentpostion = ''; // Store user current location

  @override
  void initState() {
    super.initState();
    _profileImage = widget.profileImage; // Initialize with passed image
    getUserData(); // Fetch user data when the screen loads
    _getCurrentLocation(); // Fetch user location when the screen loads
  }

  Future<void> _pickImageFromProfile() async {
    final ImagePicker _picker = ImagePicker();

    // Show dialog to select image source
    final String? source = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Image Source'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'Camera'),
              child: Text('Camera'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'Gallery'),
              child: Text('Gallery'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (source == 'Camera') {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
      _updateProfileImage(pickedFile);
    } else if (source == 'Gallery') {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      _updateProfileImage(pickedFile);
    }
  }

// Helper method to update the profile image
  void _updateProfileImage(XFile? pickedFile) {
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path); // Update local image
      });
      widget.onImagePicked(File(pickedFile.path)); // Notify parent of new image
    }
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

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location services are disabled')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location permissions are permanently denied, we cannot request permissions')),
      );
      return;
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permissions are denied (actual value: $permission).')),
        );
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentpostion =
      'Lat: ${position.latitude}, Long: ${position.longitude}';
    });

    await _getAddressFromLatLng(position);
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks[0];
      setState(() {
        _address = '${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting address: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: <Widget>[
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                    child: _profileImage == null ? Icon(Icons.person, size: 40) : null,
                  ),
                  Positioned(
                    bottom: -5,
                    right: -5,
                    child: IconButton(
                      icon: Icon(Icons.camera_alt),
                      onPressed: _pickImageFromProfile,
                      color: Config.primaryColor,
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.white),
                        shape: MaterialStateProperty.all(CircleBorder()),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            user['name'] ?? 'Name', // Display user name
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.email, size: 20),
              SizedBox(width: 5),
              Text(
                user['email'] ?? 'Email', // Display user email
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ],

          ),

          Divider(
            color: Colors.grey,
            thickness: 1,
            indent: 20,
            endIndent: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.pin_drop, size: 20),
                SizedBox(width: 10),
                Expanded(  // Ensure the text takes only the available space
                  child: Text(
                    _address, // Display the address
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),


        ],
      ),
    );
  }
}

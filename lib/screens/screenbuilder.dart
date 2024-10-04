import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:salonease1/screens/booking.dart';
import 'home_page.dart';
import 'profile.dart';
import 'calender.dart';

class Screenbuild extends StatefulWidget {
  @override
  _ScreenbuildState createState() => _ScreenbuildState();
}

class _ScreenbuildState extends State<Screenbuild> {
  File? _profileImage; // Store profile image

  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    // Initialize screens with a callback for updating the profile image
    _screens.addAll([
      HomePage(),
      AppointemetsScreen(),
      BookingScreen(),
      ProfileScreen(
        profileImage: _profileImage,
        onImagePicked: (newImage) {
          setState(() {
            _profileImage = newImage; // Update image in parent
          });
        },
      ),
    ]);
  }

  // Function to handle image picking from AppBar
  Future<void> _pickImageFromAppBar() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path); // Update state
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SalonEase'),
        actions: <Widget>[
          GestureDetector(
            onTap: _pickImageFromAppBar, // Pick image from app bar
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                  child: _profileImage == null ? const Icon(Icons.person, size: 20) : null,
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(color: Colors.grey, height: 1.0),
        ),
      ),
      body: PageView(
        controller: _pageController,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _pageController.jumpToPage(index);
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Appointments'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Booking'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

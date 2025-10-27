// ignore_for_file: unused_field, library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:myrheumlogapp/view/themes/app_theme.dart';

class UserDobPage extends StatefulWidget {
  const UserDobPage({super.key});

  @override
  _UserDobPageState createState() => _UserDobPageState();
}

class _UserDobPageState extends State<UserDobPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeInAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  DateTime? _selectedDate;

  void _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: primaryBlue,
            hintColor: primaryBlue,
            colorScheme: ColorScheme.light(primary: primaryBlue),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Stack(
        children: [
          Container(
            /* decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple, Colors.deepPurple],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),*/
          ),
          Column(
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Select Your Date of Birth",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: () => _pickDate(context),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          padding: EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 30,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.black, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Text(
                            _selectedDate == null
                                ? "Tap to Select Date"
                                : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "This information helps us personalize your experience.",
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_selectedDate != null) {
                        // Proceed with the selected date
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Date of Birth Selected: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Please select your date of birth."),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 30,
                      ),
                    ),
                    child: Text(
                      "Confirm",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

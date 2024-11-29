// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:fyp_2/widget/bottomnav.dart';
import 'package:introduction_slider/introduction_slider.dart';

void main() => runApp(const MaterialApp(home: MySlider()));

class MySlider extends StatelessWidget {
  const MySlider({super.key});

  @override
  Widget build(BuildContext context) {
    return IntroductionSlider(
      items: const [
        IntroductionSliderItem(
          logo: FlutterLogo(),
          title: Text("Book Your Favorite Sports"),
          subtitle: Text(
              "Easily book your favorite sports activities and facilities with just a few taps. Stay active and enjoy your sports time without any hassle."),
          backgroundColor: Color.fromARGB(255, 255, 196, 0),
        ),
        IntroductionSliderItem(
          logo: FlutterLogo(),
          title: Text("Manage Your Reservations"),
          subtitle: Text(
              "Keep track of all your bookings in one place. Modify or cancel reservations as needed to fit your schedule."),
          backgroundColor:Color.fromARGB(255, 255, 196, 0),
        ),
        IntroductionSliderItem(
          logo: FlutterLogo(),
          title: Text("Stay Updated with Notifications"),
          subtitle: Text(
              "Receive notifications about your upcoming reservations, tournament registrations, and special events. Never miss out on any updates."),
          backgroundColor:Color.fromARGB(255, 255, 196, 0),
        ),
      ],
      done: Done(
        child: Icon(Icons.done),
        home: Bottom(),
      ),
      next: Next(child: const Icon(Icons.arrow_forward)),
      back: Back(child: const Icon(Icons.arrow_back)),
      dotIndicator: DotIndicator(),
    );
  }
}

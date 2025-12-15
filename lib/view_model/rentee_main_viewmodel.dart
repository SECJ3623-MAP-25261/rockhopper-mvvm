import 'package:flutter/material.dart';

class RenteeMainViewModel extends ChangeNotifier {
  int currentIndex = 0;

  void changeTab(int index) {
    currentIndex = index;
    notifyListeners();
  }
}

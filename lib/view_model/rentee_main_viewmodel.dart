// lib/view_model/rentee_main_viewmodel.dart
import 'package:flutter/foundation.dart';

class RenteeMainViewModel extends ChangeNotifier {
  int currentIndex = 0;

  void changeTab(int index) {
    currentIndex = index;
    notifyListeners();
  }
}
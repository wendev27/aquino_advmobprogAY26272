import 'package:flutter/material.dart';

// Purpose: Manage application-wide counter state
// Responsibilities: Store counter value and notify listeners when counter changes
// Why this class exists: To provide app-wide counter state using Provider pattern
// This is application-wide state that persists across screens and navigation

class CounterProvider extends ChangeNotifier {
  // Current counter value
  int _counter = 0;

  // Getter for current counter value
  // Outputs: Current counter value
  int get counter => _counter;

  // Increment the counter
  // Why this exists: To allow incrementing the app-wide counter
  void increment() {
    _counter++;
    notifyListeners();
  }

  // Decrement the counter
  // Why this exists: To allow decrementing the app-wide counter
  void decrement() {
    if (_counter > 0) {
      _counter--;
      notifyListeners();
    }
  }

  // Reset the counter to zero
  // Why this exists: To allow resetting the app-wide counter
  void reset() {
    _counter = 0;
    notifyListeners();
  }
}

import 'package:flutter/foundation.dart';

class NavigationViewModel extends ChangeNotifier {
  int _currentTabIndex = 0;
  String? _chatInitialPrompt;

  int get currentTabIndex => _currentTabIndex;
  String? get chatInitialPrompt => _chatInitialPrompt;

  void setTabIndex(int index) {
    _currentTabIndex = index;
    // Reset chat initial prompt when switching away from chat or manually navigating to chat
    if (index != 2 || (index == 2 && _currentTabIndex != 2)) {
      _chatInitialPrompt = null;
    }
    notifyListeners();
  }

  void navigateToChatWithPrompt(String prompt) {
    _chatInitialPrompt = prompt;
    _currentTabIndex = 2; // Switch to chat tab
    notifyListeners();
  }

  void resetChatPrompt() {
    _chatInitialPrompt = null;
    notifyListeners();
  }
}

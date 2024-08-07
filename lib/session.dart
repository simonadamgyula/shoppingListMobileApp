import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:session_storage/session_storage.dart';

class Session extends ChangeNotifier {
  final SessionStorage _session = SessionStorage();

  void setSessionId(String sessionId) {
    log(sessionId);
    _session["session_id"] = sessionId;
    notifyListeners();
  }

  void logOut() {
    _session.remove("session_id");
    notifyListeners();
  }

  void updateHouseholds() {
    notifyListeners();
  }

  String? getSessionId() {
    return _session["session_id"];
  }
}
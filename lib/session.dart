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

  String? getSessionId() {
    return _session["session_id"];
  }
}
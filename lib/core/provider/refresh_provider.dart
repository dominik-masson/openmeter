import 'package:flutter/cupertino.dart';

class RefreshProvider extends ChangeNotifier{

  bool _refresh = false;

  bool get refreshState => _refresh;

  setRefresh(bool state){
    _refresh = state;
    notifyListeners();
  }

}
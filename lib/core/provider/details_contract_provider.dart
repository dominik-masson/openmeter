import 'package:flutter/material.dart';

import '../model/compare_costs.dart';
import '../model/provider_dto.dart';

class DetailsContractProvider extends ChangeNotifier {
  ProviderDto? _provider;
  CompareCosts? _compareCosts;
  bool _deleteProvider = false;
  bool _removeCanceledDate = false;

  get getCurrentProvider => _provider;

  void setCurrentProvider(ProviderDto? provider) {
    _provider = provider;

    notifyListeners();
  }

  get getDeleteProviderState => _deleteProvider;

  void setDeleteProviderState(bool value, bool notify) {
    _deleteProvider = value;

    if (notify) {
      notifyListeners();
    }
  }

  get getRemoveCanceledDateState => _removeCanceledDate;

  void setRemoveCanceledDateState(bool value, bool notify) {
    _removeCanceledDate = value;

    if (notify) {
      notifyListeners();
    }
  }

  CompareCosts? get getCompareContract => _compareCosts;

  void setCompareContract(CompareCosts? costs, bool notify) {
    _compareCosts = costs;

    if(notify) {
      notifyListeners();
    }
  }

  void setCompareId(int id){
    _compareCosts!.id = id;
    notifyListeners();
  }

}

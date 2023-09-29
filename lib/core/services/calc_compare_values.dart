import '../model/compare_costs.dart';
import '../model/contract_costs.dart';
import '../model/contract_dto.dart';

class CalcCompareValues {
  final ContractDto _currentCost;
  final CompareCosts _compareCost;

  CalcCompareValues(
      {required ContractDto currentCost, required CompareCosts compareCost})
      : _compareCost = compareCost,
        _currentCost = currentCost;

  _compareBonus() {
    final compareCosts = _compareCost.costs;

    if (_currentCost.bonus != null) {
      if (compareCosts.bonus != null) {
        return compareCosts.bonus! - _currentCost.bonus!;
      } else {
        return _currentCost.bonus!;
      }
    } else if (compareCosts.bonus != null) {
      return compareCosts.bonus!;
    }
  }

  _calcTotalDifference() {
    int usage = _compareCost.usage;

    int currentBonus = _currentCost.bonus ?? 0;

    double energyPriceTotalCurrent = usage * _currentCost.energyPrice / 100;

    double currentTotal =
        energyPriceTotalCurrent + _currentCost.basicPrice - currentBonus;
    double compareTotal = getCompareTotal();

    return currentTotal - compareTotal;
  }

  double getCompareTotal() {
    final compareCosts = _compareCost.costs;

    int usage = _compareCost.usage;
    int compareBonus = compareCosts.bonus ?? 0;
    double energyPriceTotalCompare = usage * compareCosts.energyPrice / 100;

    return energyPriceTotalCompare + compareCosts.basicPrice - compareBonus;
  }

  ContractCosts compareCosts() {
    final compareCosts = _compareCost.costs;

    double basicPrice = _currentCost.basicPrice - compareCosts.basicPrice;
    double energyPrice = _currentCost.energyPrice - compareCosts.energyPrice;
    int bonus = _compareBonus();

    double total = _calcTotalDifference();

    return ContractCosts(
      basicPrice: basicPrice,
      energyPrice: energyPrice,
      bonus: bonus,
      total: total,
    );
  }
}

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

    if (_currentCost.costs.bonus != null) {
      if (compareCosts.bonus != null) {
        return compareCosts.bonus! - _currentCost.costs.bonus!;
      } else {
        return _currentCost.costs.bonus!;
      }
    } else if (compareCosts.bonus != null) {
      return compareCosts.bonus!;
    }
  }

  _calcTotalDifference() {
    int usage = _compareCost.usage;
    ContractCosts currentCosts = _currentCost.costs;

    int currentBonus = currentCosts.bonus ?? 0;

    double energyPriceTotalCurrent = usage * currentCosts.energyPrice / 100;

    double currentTotal =
        energyPriceTotalCurrent + currentCosts.basicPrice - currentBonus;
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
    ContractCosts currentCosts = _currentCost.costs;

    double basicPrice = currentCosts.basicPrice - compareCosts.basicPrice;
    double energyPrice = currentCosts.energyPrice - compareCosts.energyPrice;
    int bonus = _compareBonus();

    double total = _calcTotalDifference();

    return ContractCosts(
        basicPrice: basicPrice,
        energyPrice: energyPrice,
        bonus: bonus,
        total: total,
        discount: 0.0);
  }
}

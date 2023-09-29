class ContractCosts {
  double basicPrice;
  double energyPrice;
  int? bonus;
  double? total;

  ContractCosts({
    required this.basicPrice,
    required this.energyPrice,
    this.bonus,
    this.total,
  });
}

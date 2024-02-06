class ContractCosts {
  double basicPrice;
  double energyPrice;
  int? bonus;
  double? total;
  double discount;

  ContractCosts({
    required this.basicPrice,
    required this.energyPrice,
    this.bonus,
    this.total,
    required this.discount,
  });
}

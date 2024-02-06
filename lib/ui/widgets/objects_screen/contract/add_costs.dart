import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/database/local_database.dart';
import '../../../../core/model/compare_costs.dart';
import '../../../../core/model/contract_costs.dart';
import '../../../../core/model/contract_dto.dart';
import '../../../../core/provider/contract_provider.dart';
import '../../../../core/provider/details_contract_provider.dart';
import '../../../../core/helper/compare_cost_helper.dart';
import '../../../../utils/convert_meter_unit.dart';

class AddCosts extends StatefulWidget {
  const AddCosts({super.key});

  @override
  State<AddCosts> createState() => _AddCostsState();
}

class _AddCostsState extends State<AddCosts> {
  final _form = GlobalKey<FormState>();

  final TextEditingController _basicPrice = TextEditingController();
  final TextEditingController _energyPrice = TextEditingController();
  final TextEditingController _bonus = TextEditingController();
  final TextEditingController _usage = TextEditingController();

  final ConvertMeterUnit _convertMeterUnit = ConvertMeterUnit();
  bool _isUpdate = false;

  late ContractDto contract;

  @override
  void dispose() {
    _basicPrice.dispose();
    _energyPrice.dispose();
    _bonus.dispose();
    _usage.dispose();

    super.dispose();
  }

  Widget _createNumberTextFields(
      String label, String suffix, TextEditingController controller) {
    return TextFormField(
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.number,
      controller: controller,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Bitte gib eine $label an!';
        }
        return null;
      },
      decoration: InputDecoration(
        label: Text(label),
        suffix: Text(suffix),
        labelStyle: const TextStyle(
          fontSize: 16,
        ),
      ),
    );
  }

  double _convertEnergyPrice() {
    if (_energyPrice.text.contains(',')) {
      return double.parse(_energyPrice.text.replaceAll(',', '.'));
    } else {
      return double.parse(_energyPrice.text);
    }
  }

  _handleOnSave() async {
    if (_form.currentState!.validate()) {
      final provider =
          Provider.of<DetailsContractProvider>(context, listen: false);

      int bonus = _bonus.text.isEmpty ? 0 : int.parse(_bonus.text);

      ContractCosts costs = ContractCosts(
          basicPrice: double.parse(_basicPrice.text),
          energyPrice: _convertEnergyPrice(),
          bonus: bonus,
          discount: 0.0);

      CompareCosts compareCosts = CompareCosts(
        costs: costs,
        usage: int.parse(_usage.text),
        parentId: contract.id,
      );

      if (!_isUpdate) {
        provider.setCompareContract(compareCosts, true);

        Navigator.of(context).pop();
      } else {
        final CompareCostHelper helper = CompareCostHelper();
        final db = Provider.of<LocalDatabase>(context, listen: false);
        final contractProvider =
            Provider.of<ContractProvider>(context, listen: false);

        final oldCompareCosts = contract.compareCosts;

        if (oldCompareCosts != null) {
          compareCosts.id = oldCompareCosts.id;
        }

        helper
            .updateCompare(
                compare: compareCosts,
                db: db,
                contractProvider: contractProvider,
                provider: provider,
                currentContract: contract)
            .then((value) => Navigator.of(context).pop());
      }
    }
  }

  _initController(CompareCosts? compareContract) {
    if (compareContract != null) {
      final costs = compareContract.costs;
      _basicPrice.text = costs.basicPrice.toString();
      _energyPrice.text = costs.energyPrice.toString();
      _bonus.text = costs.bonus == null ? '' : costs.bonus.toString();
      _usage.text = compareContract.usage.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider =
        Provider.of<DetailsContractProvider>(context, listen: false);

    contract = provider.getCurrentContract;

    final compareContract = provider.getCompareContract;

    _initController(compareContract);

    if (contract.compareCosts != null) {
      _isUpdate = true;
    }

    return Form(
      key: _form,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _createNumberTextFields('Grundpreis', 'in Euro/Jahr', _basicPrice),
            const SizedBox(
              height: 15,
            ),
            _createNumberTextFields('Arbeitspreis', 'in Cent', _energyPrice),
            const SizedBox(
              height: 15,
            ),
            TextFormField(
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.number,
              controller: _bonus,
              decoration: const InputDecoration(
                label: Text('Bonus'),
                suffix: Text('in Euro'),
                labelStyle: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            TextFormField(
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.number,
              controller: _usage,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Bitte gib einen Verbrauchswert an!';
                }

                return null;
              },
              decoration: InputDecoration(
                label: const Text('Verbrauch'),
                suffix: Text(
                    'in ${_convertMeterUnit.getUnitString(contract.unit)}'),
                labelStyle: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton.extended(
                onPressed: _handleOnSave,
                label: const Text('Vergleichen'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

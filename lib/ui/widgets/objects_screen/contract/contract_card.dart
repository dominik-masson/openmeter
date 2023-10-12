import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/model/contract_dto.dart';
import '../../../../core/model/provider_dto.dart';
import '../../../../core/provider/contract_provider.dart';
import '../../../../core/provider/details_contract_provider.dart';
import '../../../../core/provider/room_provider.dart';
import '../../../../utils/convert_meter_unit.dart';
import '../../../../utils/meter_typ.dart';
import '../../../screens/contract/details_contract.dart';
import '../../meter/meter_circle_avatar.dart';
import '../../tags/canceled_tag.dart';
import '../../tags/should_cancel_tag.dart';

class ContractCard extends StatefulWidget {
  final ContractDto contractDto;

  const ContractCard({super.key, required this.contractDto});

  @override
  State<ContractCard> createState() => _ContractCardState();
}

class _ContractCardState extends State<ContractCard> {
  final ConvertMeterUnit _convertMeterUnit = ConvertMeterUnit();

  Widget _provider(ProviderDto provider) {
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text(
                  provider.name,
                  style: const TextStyle(fontSize: 15),
                ),
                const Text(
                  'Anbieter',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  provider.contractNumber,
                  style: const TextStyle(fontSize: 15),
                ),
                const Text(
                  'Vertragsnummer',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ContractProvider>(context);
    final roomProvider = Provider.of<RoomProvider>(context);
    final detailsProvider = Provider.of<DetailsContractProvider>(context);

    bool hasSelected = provider.getHasSelectedItems;

    ContractDto contract = widget.contractDto;

    final ProviderDto? providerDto = contract.provider;
    bool isCanceled = providerDto?.canceled ?? false;

    final String local = Platform.localeName;
    final formatSimpleCurrency = NumberFormat.simpleCurrency(locale: local);

    final formatDecimal =
        NumberFormat.decimalPatternDigits(locale: local, decimalDigits: 2);

    final avatarData = meterTyps[contract.meterTyp]['avatar'];

    return GestureDetector(
      onLongPress: () {
        if (roomProvider.getStateHasSelected == false) {
          provider.toggleSelectedContracts(contract);
        }
      },
      onTap: () {
        if (roomProvider.getStateHasSelected == false) {
          if (hasSelected) {
            provider.toggleSelectedContracts(contract);
          } else {
            final provider =
                Provider.of<DetailsContractProvider>(context, listen: false);
            provider.setCurrentProvider(contract.provider);
            provider.setCurrentContract(contract);

            Navigator.of(context)
                .push(
              MaterialPageRoute(
                builder: (context) => DetailsContract(
                  contract: contract,
                ),
              ),
            )
                .then(
              (value) {
                detailsProvider.setCurrentProvider(null);
              },
            );

            detailsProvider.setCompareContract(null, true);
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.only(left: 8, right: 8),
        height: 175,
        child: Card(
          color: (contract.isSelected != null && contract.isSelected!)
              ? Colors.grey.withOpacity(0.5)
              : null,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  children: [
                    MeterCircleAvatar(
                      color: avatarData['color'],
                      icon: avatarData['icon'],
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Text(
                      meterTyps[contract.meterTyp]['anbieter'],
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Spacer(),
                    if (isCanceled)
                      const SizedBox(
                        height: 25,
                        child: CanceledTag(),
                      ),
                    if (contract.provider != null &&
                        contract.provider!.showShouldCanceled)
                      const SizedBox(
                        height: 25,
                        child: ShouldCancelTag(),
                      ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text(
                          formatSimpleCurrency
                              .format(contract.costs.basicPrice),
                          style: const TextStyle(fontSize: 15),
                        ),
                        const Text(
                          'Grundpreis',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          '${formatDecimal.format(contract.costs.energyPrice)} Cent/${_convertMeterUnit.getUnitString(contract.unit)}',
                          style: const TextStyle(fontSize: 15),
                        ),
                        const Text(
                          'Arbeitspreis',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          formatSimpleCurrency.format(contract.costs.discount),
                          style: const TextStyle(fontSize: 15),
                        ),
                        const Text(
                          'Abschlag',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                if (contract.provider != null) _provider(contract.provider!),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

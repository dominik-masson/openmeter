import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../core/database/local_database.dart';
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
  const ContractCard({Key? key}) : super(key: key);

  @override
  State<ContractCard> createState() => _ContractCardState();
}

class _ContractCardState extends State<ContractCard> {
  final ConvertMeterUnit _convertMeterUnit = ConvertMeterUnit();

  int _pageIndex = 0;
  final _pageController = PageController(initialPage: 0, keepPage: true);

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<LocalDatabase>(context);

    final contractProvider = Provider.of<ContractProvider>(context);
    final roomProvider = Provider.of<RoomProvider>(context);

    final detailsProvider = Provider.of<DetailsContractProvider>(context);

    return StreamBuilder(
      stream: db.contractDao.watchAllContracts(),
      builder: (context, snapshot) {
        final items = snapshot.data ?? [];

        if (items.isEmpty) {
          return const Center(
            child: Text(
              'Es wurden noch keine Verträge erstellt. \n Drücke jetzt auf das Plus um ein Vertrag zu erstellen.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          );
        }

        if (items.length != contractProvider.getAllContractLength) {
          contractProvider.convertData(items, db);
        }

        contractProvider.prepareProvider(db);

        final first = contractProvider.getFirstContracts;
        final second = contractProvider.getSecondContracts;

        if (_pageController.positions.isNotEmpty) {
          int currentPage = _pageController.page! > 0.5 ? 1 : 0;

          if (_pageIndex != currentPage && _pageController.page! < 1.0) {
            _pageIndex = 0;
          }
        }

        return Column(
          children: [
            SizedBox(
              height: first.length == 1 && second.isEmpty ? 180 : 360,
              child: PageView.builder(
                controller: _pageController,
                physics: const AlwaysScrollableScrollPhysics(),
                onPageChanged: (value) {
                  setState(() {
                    _pageIndex = value;
                  });
                },
                itemCount: first.length,
                itemBuilder: (context, index) {
                  ContractDto contract1 = first.elementAt(index);
                  ContractDto? contract2;

                  if (index < second.length) {
                    contract2 = second.elementAt(index);
                  }

                  return Column(
                    children: [
                      _card(
                        contract: contract1,
                        provider: contractProvider,
                        roomProvider: roomProvider,
                        detailsProvider: detailsProvider,
                      ),
                      if (contract2 != null)
                        _card(
                          contract: contract2,
                          provider: contractProvider,
                          roomProvider: roomProvider,
                          detailsProvider: detailsProvider,
                        ),
                    ],
                  );
                },
              ),
            ),
            AnimatedSmoothIndicator(
              activeIndex: _pageIndex,
              count: first.length,
              effect: WormEffect(
                activeDotColor: Theme.of(context).primaryColorLight,
                dotHeight: 10,
                dotWidth: 10,
              ),
            ),
          ],
        );
      },
    );
  }

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

  Widget _card(
      {required ContractDto contract,
      required ContractProvider provider,
      required RoomProvider roomProvider,
      required DetailsContractProvider detailsProvider}) {
    bool hasSelected = provider.getHasSelectedItems;

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

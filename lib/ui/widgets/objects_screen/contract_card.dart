import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../core/database/local_database.dart';
import '../../../core/model/contract_dto.dart';
import '../../../core/model/provider_dto.dart';
import '../../../core/provider/contract_provider.dart';
import '../../../core/provider/room_provider.dart';
import '../../screens/add_contract.dart';
import '../../../utils/meter_typ.dart';
import '../meter/meter_circle_avatar.dart';

class ContractCard extends StatefulWidget {
  const ContractCard({Key? key}) : super(key: key);

  @override
  State<ContractCard> createState() => _ContractCardState();
}

class _ContractCardState extends State<ContractCard> {
  int _pageIndex = 0;
  final _pageController = PageController(initialPage: 0, keepPage: true);

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<LocalDatabase>(context);

    final contractProvider = Provider.of<ContractProvider>(context);
    final roomProvider = Provider.of<RoomProvider>(context);

    return StreamBuilder(
      stream: db.contractDao.watchALlContracts(),
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

        final first = contractProvider.getFirstContracts;
        final second = contractProvider.getSecondContracts;

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
                      ),
                      if (contract2 != null)
                        _card(
                          contract: contract2,
                          provider: contractProvider,
                          roomProvider: roomProvider,
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
                  provider.name!,
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
                  provider.contractNumber!,
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
      required RoomProvider roomProvider}) {
    bool hasSelected = provider.getHasSelectedItems;

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
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => AddContract(contract: contract)));
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.only(left: 8, right: 8),
        height: 175,
        child: Card(
          color: contract.isSelected! ? Colors.grey.withOpacity(0.5) : null,
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
                          formatSimpleCurrency.format(contract.basicPrice),
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
                          '${formatDecimal.format(contract.energyPrice!)} Cent/${meterTyps[contract.meterTyp]['einheit']}',
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
                          formatSimpleCurrency.format(contract.discount),
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

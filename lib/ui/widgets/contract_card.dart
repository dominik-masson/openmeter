import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/database/local_database.dart';
import '../screens/add_contract.dart';
import '../utils/meter_typ.dart';

class ContractCard extends StatefulWidget {
  const ContractCard({Key? key}) : super(key: key);

  @override
  State<ContractCard> createState() => _ContractCardState();
}

class _ContractCardState extends State<ContractCard> {
  Future<bool> _deleteContract(
      BuildContext context, int contractId, int providerId) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Sind Sie sich sicher?'),
            content: const Text('Möchten Sie diesen Vertrag wirklich löschen?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Abbrechen'),
              ),
              TextButton(
                onPressed: () {
                  if (providerId != -1) {
                    Provider.of<LocalDatabase>(context, listen: false)
                        .contractDao
                        .deleteProvider(providerId);
                  }
                  Provider.of<LocalDatabase>(context, listen: false)
                      .contractDao
                      .deleteContract(contractId);
                  Navigator.of(context).pop(true);
                },
                child: const Text(
                  'Löschen',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<LocalDatabase>(context);
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

        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          semanticChildCount: items.length < 3 ? 0 : 3,
          shrinkWrap: true,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final contract = items[index];

            return Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Dismissible(
                  key: Key('${contract.uid}'),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    return await _deleteContract(
                        context, contract.uid, contract.provider);
                  },
                  background: Container(
                    alignment: AlignmentDirectional.centerEnd,
                    padding: const EdgeInsets.all(50),
                    color: Colors.red,
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  child: contract.provider != -1
                      ? _cardWithProvider(contract, db)
                      : _card(contract)),
            );
          },
        );
      },
    );
  }

  Widget _card(ContractData contract) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => AddContract(contract: contract),
      )),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                children: [
                  meterTyps[contract.meterTyp]['avatar'],
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
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text(
                        '${contract.basicPrice.toString()} €',
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
                        '${contract.energyPrice.toString()} Cent/${meterTyps[contract.meterTyp]['einheit']}',
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
                        '${contract.discount.toString()} €',
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardWithProvider(ContractData contract, LocalDatabase db) {
    return FutureBuilder(
      future: db.contractDao.selectProvider(contract.provider),
      builder: (context, snapshot) {
        final provider = snapshot.data;

        if (provider == null) {
          return Container();
        }

        return GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) =>
                AddContract(contract: contract, provider: provider),
          )),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      meterTyps[contract.meterTyp]['avatar'],
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
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text(
                            '${contract.basicPrice.toString()} €',
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
                            '${contract.energyPrice.toString()} Cent/${meterTyps[contract.meterTyp]['einheit']}',
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
                            '${contract.discount.toString()} €',
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/database/local_database.dart';
import '../../../../core/model/contract_dto.dart';
import '../../../../core/model/provider_dto.dart';
import '../../../../core/provider/contract_provider.dart';
import '../../../../core/provider/details_contract_provider.dart';
import '../../../../utils/meter_typ.dart';
import '../../tags/canceled_tag.dart';
import '../../tags/should_cancel_tag.dart';
import 'provider_bottom_sheet.dart';

class ProviderCard extends StatefulWidget {
  final ProviderDto? provider;
  final ContractDto contract;

  const ProviderCard({super.key, this.provider, required this.contract});

  @override
  State<ProviderCard> createState() => _ProviderCardState();
}

class _ProviderCardState extends State<ProviderCard> {
  final DateFormat _dateFormat = DateFormat('dd.MM.yyyy');

  final TextStyle textStyle = const TextStyle(fontSize: 16);
  ProviderDto? currentProvider;

  bool hasCanceled = false;

  @override
  initState() {
    if (widget.provider != null) {
      currentProvider = widget.provider!;
    }
    super.initState();
  }

  _selectCanceledDate() async {
    final ContractProvider contractProvider =
        Provider.of<ContractProvider>(context, listen: false);
    final LocalDatabase db = Provider.of<LocalDatabase>(context, listen: false);
    final DetailsContractProvider detailsContractProvider =
        Provider.of<DetailsContractProvider>(context, listen: false);

    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: currentProvider!.canceledDate != null
          ? currentProvider!.canceledDate!
          : DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 10),
      lastDate: DateTime(DateTime.now().year + 10),
      locale: const Locale('de', ''),
    );

    if (date != null) {
      setState(() {
        currentProvider!.canceledDate = date;
        currentProvider!.canceled = true;
        currentProvider!.showShouldCanceled = false;
      });

      contractProvider.updateProvider(
        db: db,
        provider: currentProvider!,
        contractId: widget.contract.id!,
      );

      detailsContractProvider.setCurrentProvider(currentProvider);
    }
  }

  _providerData() {
    return Table(
      children: [
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Anbieter',
                style: textStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: SelectableText(
                currentProvider!.name,
                style: textStyle,
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Nummer',
                style: textStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: SelectableText(
                currentProvider!.contractNumber,
                style: textStyle,
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Beginn',
                style: textStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                _dateFormat.format(currentProvider!.validFrom),
                style: textStyle,
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Ende',
                style: textStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                _dateFormat.format(currentProvider!.validUntil),
                style: textStyle,
              ),
            ),
          ],
        ),
        if (currentProvider!.renewal != null)
          TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Verlängerung',
                  style: textStyle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  '${currentProvider!.renewal} Monate',
                  style: textStyle,
                ),
              ),
            ],
          ),
        if (currentProvider!.notice != null)
          TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Kündigungsfrist',
                  style: textStyle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  '${currentProvider!.notice} Monate',
                  style: textStyle,
                ),
              ),
            ],
          ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Gekündigt am',
                style: textStyle,
              ),
            ),
            SizedBox(
              height: 25,
              child: TextButton(
                onPressed: () => _selectCanceledDate(),
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(EdgeInsets.zero),
                  alignment: Alignment.centerLeft,
                  textStyle: MaterialStateProperty.all(textStyle),
                  foregroundColor: MaterialStateProperty.all(
                    currentProvider!.canceled ?? false
                        ? Theme.of(context).textTheme.titleLarge!.color
                        : null,
                  ),
                ),
                child: currentProvider!.canceled ?? false
                    ? Text(_dateFormat.format(currentProvider!.canceledDate!))
                    : const Text('Datum wählen'),
              ),
            ),
          ],
        )
      ],
    );
  }

  _emptyProvider(DetailsContractProvider provider) {
    return Column(
      children: [
        Text(
          'Es wurde noch kein Vertrag für diesen ${meterTyps[widget.contract.meterTyp]['anbieter']} angelegt.',
          style: textStyle.copyWith(
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
        TextButton(
          onPressed: () => _openBottomSheet(),
          style: ButtonStyle(
            textStyle: MaterialStateProperty.all(
              textStyle.copyWith(
                color: Colors.grey,
              ),
            ),
            foregroundColor: MaterialStateProperty.all(Colors.grey),
          ),
          child: const Text(
            'Drücke hier, um einen Vertrag zu erstellen',
          ),
        ),
      ],
    );
  }

  _openBottomSheet() async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProviderBottomSheet(
        createProvider: currentProvider != null ? false : true,
        contractId: widget.contract.id!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DetailsContractProvider>(context);

    currentProvider = provider.getCurrentProvider;

    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Vertragsübersicht',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _openBottomSheet(),
                    icon: const Icon(
                      Icons.edit_note,
                      size: 30,
                    ),
                  ),
                ],
              ),
              if (currentProvider != null && currentProvider!.canceled!)
                const SizedBox(
                  height: 25,
                  child: CanceledTag(),
                ),
              if (currentProvider != null &&
                  currentProvider!.showShouldCanceled)
                const SizedBox(
                  height: 25,
                  child: ShouldCancelTag(),
                ),
              const SizedBox(
                height: 10,
              ),
              currentProvider == null
                  ? _emptyProvider(provider)
                  : _providerData(),
              const SizedBox(
                height: 5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

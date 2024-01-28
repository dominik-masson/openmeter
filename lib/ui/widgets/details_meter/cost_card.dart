import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/database/local_database.dart';
import '../../../core/model/meter_dto.dart';
import '../../../core/provider/cost_provider.dart';
import '../../../core/provider/entry_provider.dart';

class CostBar extends StatefulWidget {
  final MeterDto meter;

  const CostBar({super.key, required this.meter});

  @override
  State<CostBar> createState() => _CostBarState();
}

class _CostBarState extends State<CostBar> {
  DateTime? _firstDate;
  DateTime? _lastDate;
  DateTime? _oneYearEarly;
  bool _errorDate = false;

  @override
  void initState() {
    int firstDate =
        Provider.of<CostProvider>(context, listen: false).getFirstDate;
    int lastDate =
        Provider.of<CostProvider>(context, listen: false).getLastDate;

    if (firstDate == 0 || lastDate == 0) {
      _firstDate = DateTime(
          DateTime.now().year - 1, DateTime.now().month, DateTime.now().day);
      _lastDate = DateTime.now();
      _oneYearEarly = DateTime(
          DateTime.now().year - 1, DateTime.now().month, DateTime.now().day);
    } else {
      _firstDate = DateTime.fromMillisecondsSinceEpoch(firstDate);
      _lastDate = DateTime.fromMillisecondsSinceEpoch(lastDate);
      _oneYearEarly =
          DateTime(_lastDate!.year - 1, _lastDate!.month, _lastDate!.day);
    }

    super.initState();
  }

  void _showDatePicker(
      BuildContext context, bool firstDate, CostProvider costProvider) async {
    await showDatePicker(
      context: context,
      initialDate: firstDate ? _oneYearEarly! : DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 10),
      lastDate: DateTime.now(),
      locale: const Locale('de', ''),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }

      setState(() {
        _errorDate = !_errorDate;
        if (firstDate) {
          _firstDate = pickedDate;
          costProvider.saveFistDate(_firstDate!.millisecondsSinceEpoch);
        } else {
          _lastDate = pickedDate;
          costProvider.saveLastDate(_lastDate!.millisecondsSinceEpoch);
        }
      });
    });
  }

  void _informationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Infos zu Werten',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        content: Text(
          'Alle errechneten Werte sind nur grobe Schätzungen und spiegeln nicht zwangsweise die Realität wieder.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _errorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Fehler beim Datum',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        content: Text(
          'Ein gewähltes Datum stimmt nicht mit den vorhandenen Einträgen überein. Bitte wähle ein neues Datum um die Werte zu berechnen!',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  int _calcDifferenceMont() {
    if (_lastDate != null && _firstDate != null) {
      return (_lastDate!.difference(_firstDate!).inDays / 30).floor();
    } else {
      return 0;
    }
  }

  List<int> _getValueFromDates(List<Entrie> entries) {
    final result = entries.map((e) {
      return '${e.date.month}.${e.date.year}';
    }).toList();

    int posLastDate = result.indexOf(DateFormat('M.yyyy').format(_lastDate!));
    int posFirstDate = result.indexOf(DateFormat('M.yyyy').format(_firstDate!));

    if (posFirstDate == -1 || posLastDate == -1) {
      return [];
    }

    int valLastDate = entries.elementAt(posLastDate).count;
    int valFirstDate = entries.elementAt(posFirstDate).count;

    return [valFirstDate, valLastDate];
  }

  @override
  Widget build(BuildContext context) {
    final costProvider = Provider.of<CostProvider>(context);
    final db = Provider.of<LocalDatabase>(context);
    final entryCardProvider =
        Provider.of<EntryProvider>(context, listen: false);

    final months = _calcDifferenceMont();

    return FutureBuilder(
      future: db.entryDao.getLastEntry(widget.meter.id!),
      builder: (context, snapshot) {
        final entryData = snapshot.data;

        if (entryData == null) {
          return Container();
        }

        List<int> countValues = [];

        if (entryData.length >= 11) {
          countValues = _getValueFromDates(entryData);
          if (countValues.isEmpty) {
            _errorDate = true;
          } else {
            _errorDate = false;
            costProvider.setCount(countValues[0], countValues[1]);
          }
        }

        return FutureBuilder(
          future: db.contractDao.getContractByTyp(widget.meter.typ),
          builder: (context, snapshot) {
            final contractData = snapshot.data;

            if (contractData == null) {
              entryCardProvider.setContractData(false);
              return Container();
            } else {
              entryCardProvider.setContractData(true);
            }

            costProvider.setValues(
              contractData.basicPrice,
              contractData.energyPrice,
              contractData.discount,
            );
            costProvider.setSumMont(months);

            if (entryData.length > 11) {
              return _card(
                context,
                costProvider,
              );
            } else {
              return Container();
            }
          },
        );
      },
    );
  }

  Widget _card(
    BuildContext context,
    CostProvider costProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kostenübersicht',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Row(
                children: [
                  if (_errorDate)
                    IconButton(
                      onPressed: () => _errorDialog(context),
                      icon: const FaIcon(
                        FontAwesomeIcons.circleExclamation,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  IconButton(
                    onPressed: () => _informationDialog(context),
                    icon: const FaIcon(FontAwesomeIcons.circleInfo, size: 20),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            _showDatePicker(context, true, costProvider);
                          },
                          child: Text(
                            DateFormat('dd.MM.yyyy').format(_firstDate!),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: Theme.of(context).primaryColor,
                                ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_sharp,
                          color: Color(0xff32A287),
                        ),
                        TextButton(
                          onPressed: () {
                            _showDatePicker(context, false, costProvider);
                          },
                          child: Text(
                            DateFormat('dd.MM.yyyy').format(_lastDate!),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: Theme.of(context).primaryColor,
                                ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Kosten',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          '${costProvider.calcCost()}€',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'bezahlt',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          '${costProvider.calcPayedDiscount()}€',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          costProvider.calcRest().isNegative
                              ? 'Nachzahlung'
                              : 'Rückzahlung',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          '${costProvider.calcRest().toStringAsFixed(2)}€',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

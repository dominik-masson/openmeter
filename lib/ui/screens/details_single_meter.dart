import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' as drift;

import '../../core/database/local_database.dart';
import '../../core/provider/theme_changer.dart';
import '../../core/services/torch_controller.dart';
import '../widgets/entry_card.dart';
import '../widgets/line_chart_single_meter.dart';

class DetailsSingleMeter extends StatefulWidget {
  final MeterData meter;

  const DetailsSingleMeter({Key? key, required this.meter}) : super(key: key);

  @override
  State<DetailsSingleMeter> createState() => _DetailsSingleMeterState();
}

class _DetailsSingleMeterState extends State<DetailsSingleMeter> {
  final TextEditingController _datecontroller = TextEditingController();
  final TextEditingController _countercontroller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate = DateTime.now();

  final TorchController _torchController = TorchController();

  @override
  void dispose() {
    _datecontroller.dispose();
    _countercontroller.dispose();

    super.dispose();
  }

  void _showDatePicker(BuildContext context) async {
    await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 10),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }

      setState(() {
        _selectedDate = pickedDate;
        _datecontroller.text = DateFormat('dd.MM.yyyy').format(_selectedDate!);
      });
    });
  }

  _saveEntry() async {
    final db = Provider.of<LocalDatabase>(context, listen: false);

    if (_formKey.currentState!.validate()) {
      final entry = EntriesCompanion(
        meter: drift.Value(widget.meter.id),
        date: drift.Value(_selectedDate!),
        count: drift.Value(int.parse(_countercontroller.text)),
      );

      await db.meterDao.createEntry(entry).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Eintrag wird hinzugefügt!'),
          ),
        );
        Navigator.of(context).pop();
        _countercontroller.clear();
        _selectedDate = DateTime.now();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.meter.typ),
        actions: [
          IconButton(
              onPressed: () => _showBottomModel(context),
              icon: const Icon(Icons.add))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Zählernummer
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Text(
                widget.meter.number,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
            const Divider(),
            EntryCard(meter: widget.meter),
            const SizedBox(
              height: 15,
            ),
            LineChartSingleMeter(
              meterId: widget.meter.id,
            ),
          ],
        ),
      ),
    );
  }

  _showBottomModel(BuildContext context) {
    var getMode =
        Provider.of<ThemeChanger>(context, listen: false).getThemeMode;
    bool darkMode;
    if (getMode == ThemeMode.dark || getMode == ThemeMode.system) {
      darkMode = true;
    } else {
      darkMode = false;
    }

    return showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            height: 400,
            padding: const EdgeInsets.all(25),
            child: Center(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Neuer Zählerstand',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            // _getTorch();
                            _torchController.getTorch();
                          },
                          icon: Icon(
                            Icons.flashlight_on,
                            color: darkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      readOnly: true,
                      textInputAction: TextInputAction.next,
                      controller: _datecontroller
                        ..text = _selectedDate != null
                            ? DateFormat('dd.MM.yyyy').format(_selectedDate!)
                            : '',
                      onTap: () => _showDatePicker(context),
                      decoration: const InputDecoration(
                          icon: Icon(Icons.date_range), label: Text('Datum')),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Bitte geben sie den Zählerstand an!';
                        }
                        if (int.parse(value) < 0) {
                          return 'Bitte gebe eine positive Zahl an!';
                        }
                        return null;
                      },
                      controller: _countercontroller,
                      decoration: const InputDecoration(
                          icon: Icon(Icons.onetwothree),
                          label: Text('Zählerstand')),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _saveEntry,
                          icon: const Icon(Icons.check),
                          label: const Text('Speichern'),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

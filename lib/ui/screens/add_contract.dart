import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' as drift;
import 'package:provider/provider.dart';

import '../../core/database/local_database.dart';
import '../../../utils/meter_typ.dart';
import '../../core/model/contract_dto.dart';
import '../../core/model/provider_dto.dart';
import '../../core/provider/contract_provider.dart';
import '../../core/provider/database_settings_provider.dart';

class AddContract extends StatefulWidget {
  final ContractDto? contract;

  const AddContract({Key? key, required this.contract}) : super(key: key);

  @override
  State<AddContract> createState() => _AddContractState();
}

class _AddContractState extends State<AddContract> {
  final _formKey = GlobalKey<FormState>();
  final _expansionKey = GlobalKey();
  final TextEditingController _dateEndController = TextEditingController();
  final TextEditingController _dateBeginController = TextEditingController();
  final TextEditingController _providerName = TextEditingController();
  final TextEditingController _contractNumber = TextEditingController();
  final TextEditingController _notice = TextEditingController();
  final TextEditingController _basicPrice = TextEditingController();
  final TextEditingController _energyPrice = TextEditingController();
  final TextEditingController _discount = TextEditingController();
  final TextEditingController _bonus = TextEditingController();
  final TextEditingController _note = TextEditingController();

  String _meterTyp = 'Stromzähler';
  bool _providerExpand = false;
  DateTime? _dateBegin = DateTime.now();
  DateTime? _dateEnd = DateTime(
      DateTime.now().year + 2, DateTime.now().month, DateTime.now().day);

  bool _isUpdate = false;
  String _pageName = 'Neuer Vertrag';

  ContractDto? _contractDto;

  @override
  void initState() {
    if (widget.contract != null) {
      _pageName = meterTyps[widget.contract!.meterTyp]['anbieter'];
      _setController();
    }
    super.initState();
  }

  void _setController() {
    _contractDto = widget.contract;

    if (_contractDto == null) {
      return;
    }

    final String local = Platform.localeName;
    final formatPattern =
        NumberFormat.decimalPatternDigits(locale: local, decimalDigits: 2);

    _isUpdate = true;
    _meterTyp = _contractDto!.meterTyp!;
    _basicPrice.text = formatPattern.format(_contractDto!.basicPrice);
    _energyPrice.text = formatPattern.format(_contractDto!.energyPrice);
    _discount.text = formatPattern.format(_contractDto!.discount);
    _bonus.text = _contractDto!.bonus.toString();
    _note.text = _contractDto!.note!;

    final ProviderDto? provider = _contractDto!.provider;

    if (provider != null) {
      _providerName.text = provider.name!;
      _contractNumber.text = provider.contractNumber!;
      _dateBeginController.text =
          DateFormat('dd.MM.yyyy').format(provider.validFrom!);
      _dateEndController.text =
          DateFormat('dd.MM.yyyy').format(provider.validUntil!);
      _notice.text = provider.notice.toString();
      _providerExpand = true;
    } else {
      return;
    }
  }

  Future<void> _saveEntry() async {
    final db = Provider.of<LocalDatabase>(context, listen: false);
    int? providerId;
    int bonus;
    int notice;

    if (_formKey.currentState!.validate()) {
      Provider.of<DatabaseSettingsProvider>(context, listen: false)
          .setHasUpdate(true);

      // no update and provider is set
      if (!_isUpdate && (_providerExpand || _providerName.text.isNotEmpty)) {
        if (_notice.text.isEmpty) {
          notice = 0;
        } else {
          notice = int.parse(_notice.text);
        }

        final provider = ProviderCompanion(
            name: drift.Value(_providerName.text),
            contractNumber: drift.Value(_contractNumber.text),
            notice: drift.Value(notice),
            validFrom: drift.Value(_dateBegin!),
            validUntil: drift.Value(_dateEnd!));

        providerId = await db.contractDao.createProvider(provider);
      }

      if (_bonus.text.isEmpty) {
        bonus = 0;
      } else {
        bonus = int.parse(_bonus.text);
      }

      // create contract
      if (!_isUpdate) {
        final contract = ContractCompanion(
          meterTyp: drift.Value(_meterTyp),
          provider: drift.Value(providerId),
          basicPrice:
              drift.Value(double.parse(_basicPrice.text.replaceAll(',', '.'))),
          energyPrice:
              drift.Value(double.parse(_energyPrice.text.replaceAll(',', '.'))),
          discount:
              drift.Value(double.parse(_discount.text.replaceAll(',', '.'))),
          bonus: drift.Value(bonus),
          note: drift.Value(_note.text),
        );

        await db.contractDao.createContract(contract).then((value) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
              'Vertrag wird erstellt!',
            ),
          ));
          Navigator.of(context).pop();
        });
      } else {
        // Update contract

        if (_providerExpand || _providerName.text.isNotEmpty) {
          if (_notice.text.isEmpty) {
            notice = 0;
          } else {
            notice = int.parse(_notice.text);
          }

          if (_contractDto!.provider == null) {
            final provider = ProviderCompanion(
                name: drift.Value(_providerName.text),
                contractNumber: drift.Value(_contractNumber.text),
                notice: drift.Value(notice),
                validFrom: drift.Value(_dateBegin!),
                validUntil: drift.Value(_dateEnd!));

            providerId = await db.contractDao.createProvider(provider);
          } else {
            final providerData = ProviderData(
              id: _contractDto!.provider!.id!,
              name: _providerName.text,
              contractNumber: _contractNumber.text,
              notice: int.parse(_notice.text),
              validFrom: _dateBegin!,
              validUntil: _dateBegin!,
            );

            await db.contractDao.updateProvider(providerData);
            providerId = _contractDto!.provider!.id!;
          }
        }

        final contract = ContractData(
          id: _contractDto!.id!,
          meterTyp: _meterTyp,
          provider: providerId,
          basicPrice: double.parse(_basicPrice.text.replaceAll(',', '.')),
          energyPrice: double.parse(_energyPrice.text.replaceAll(',', '.')),
          discount: double.parse(_discount.text.replaceAll(',', '.')),
          bonus: int.parse(_bonus.text),
          note: _note.text,
        );

        await db.contractDao.updateContract(contract).then((value) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
              'Vertrag wird aktualisiert!',
            ),
          ));
          Navigator.of(context).pop();
        });

        if (mounted) {
          Provider.of<ContractProvider>(context, listen: false)
              .updateContract(db: db, data: contract, providerId: providerId);
        }
      }
    }
  }

  void _deleteProvider() async {
    final db = Provider.of<LocalDatabase>(context, listen: false);

    await db.contractDao
        .deleteProvider(_contractDto!.provider!.id!)
        .then((value) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'Anbieter wird gelöscht!',
        ),
      ));
    });

    if (mounted) {
      Provider.of<DatabaseSettingsProvider>(context, listen: false)
          .setHasUpdate(true);
    }

    setState(() {
      _providerName.clear();
      _contractNumber.clear();
      _notice.clear();
    });
  }

  void _showDatePicker(BuildContext context, String typ) async {
    await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 10),
      lastDate: DateTime(DateTime.now().year + 10),
      locale: const Locale('de', ''),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        if (typ == 'begin') {
          _dateBegin = pickedDate;
          _dateBeginController.text =
              DateFormat('dd.MM.yyyy').format(_dateBegin!);
        } else {
          _dateEnd = pickedDate;
          _dateEndController.text = DateFormat('dd.MM.yyyy').format(_dateEnd!);
        }
      });
    });
  }

  Widget _dropdownMeterTyp(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: DropdownButtonFormField(
        validator: (value) {
          if (value == null) {
            return 'Bitte wähle einen Zählertyp!';
          }
          return null;
        },
        value: _meterTyp,
        isExpanded: true,
        decoration: const InputDecoration(
          label: Text('Zählertyp'),
          icon: Icon(Icons.gas_meter_outlined),
          // contentPadding: EdgeInsets.all(0.0),
          isDense: true,
        ),
        items: meterTyps.entries.map((e) {
          return DropdownMenuItem(
            value: e.key,
            child: Row(
              children: [
                e.value['avatar'],
                const SizedBox(
                  width: 20,
                ),
                Text(e.key),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _meterTyp = value!;
          });
        },
      ),
    );
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
      ),
    );
  }

  void _scrollToContent(GlobalKey expansionKey) {
    final keyContext = expansionKey.currentContext;
    if (keyContext != null) {
      Future.delayed(const Duration(milliseconds: 200)).then((value) {
        Scrollable.ensureVisible(keyContext,
            duration: const Duration(milliseconds: 200));
      });
    }
  }

  Widget _provider() {
    return ExpansionTile(
      title: Text(
        'Vertragsdetails',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: _providerExpand
              ? Theme.of(context).primaryColorLight
              : Theme.of(context).hintColor,
        ),
      ),
      key: _expansionKey,
      initiallyExpanded: _providerExpand,
      tilePadding: const EdgeInsets.all(0),
      onExpansionChanged: (value) {
        if (value) {
          _scrollToContent(_expansionKey);
        }
        setState(() {
          _providerExpand = !_providerExpand;
        });
      },
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isUpdate)
              TextButton(
                onPressed: () => _deleteProvider(),
                child: const Text(
                  'Anbieter löschen',
                  style: TextStyle(color: Colors.redAccent, fontSize: 16),
                ),
              ),
            TextFormField(
              controller: _providerName,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Bitte gib einen Anbieter/Vertragsnamen an!';
                }
                return null;
              },
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                label: Text('Anbieter/Vertragsname'),
              ),
            ),
            TextFormField(
              textInputAction: TextInputAction.next,
              controller: _contractNumber,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Bitte gib eine Vertragsnummer an!';
                }
                return null;
              },
              decoration: const InputDecoration(
                label: Text('Vertragsnummer'),
              ),
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    readOnly: true,
                    controller: _dateBeginController
                      ..text = _dateBegin != null
                          ? DateFormat('dd.MM.yyyy').format(_dateBegin!)
                          : '',
                    onTap: () => _showDatePicker(context, 'begin'),
                    decoration: const InputDecoration(
                      label: Text('Vertragsbeginn'),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    readOnly: true,
                    controller: _dateEndController
                      ..text = _dateEnd != null
                          ? DateFormat('dd.MM.yyyy').format(_dateEnd!)
                          : '',
                    onTap: () => _showDatePicker(context, 'end'),
                    decoration: const InputDecoration(
                      label: Text('Vertragslaufzeit'),
                    ),
                  ),
                ),
              ],
            ),
            TextFormField(
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.number,
              controller: _notice,
              decoration: const InputDecoration(
                label: Text('Kündigungsfrist'),
                suffixText: 'Monate',
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageName),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveEntry,
        label: const Text('Speichern'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _dropdownMeterTyp(context),
                const SizedBox(
                  height: 15,
                ),
                _createNumberTextFields('Grundpreis', 'in Euro', _basicPrice),
                const SizedBox(
                  height: 15,
                ),
                _createNumberTextFields(
                    'Arbeitspreis', 'in Cent', _energyPrice),
                const SizedBox(
                  height: 15,
                ),
                _createNumberTextFields('Abschlag', 'in Euro', _discount),
                const SizedBox(
                  height: 15,
                ),
                // _createNumberTextFields('Bonus', 'in Euro'),
                TextFormField(
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  controller: _bonus,
                  decoration: const InputDecoration(
                    label: Text('Bonus'),
                    suffix: Text('in Euro'),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                  textInputAction: TextInputAction.next,
                  controller: _note,
                  decoration: const InputDecoration(
                    label: Text('Notiz'),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                _provider(),
                if (_providerExpand)
                  const SizedBox(
                    height: 70,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

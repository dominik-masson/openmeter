import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' as drift;
import 'package:provider/provider.dart';

import '../../core/database/local_database.dart';
import '../utils/meter_typ.dart';

class AddContract extends StatefulWidget {
  final ContractData? contract;
  final ProviderData? provider;

  const AddContract({Key? key, required this.contract, this.provider})
      : super(key: key);

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

  @override
  void initState() {
    if (widget.provider != null) {
      _pageName = meterTyps[widget.contract!.meterTyp]['anbieter'];
      _setController();
    }
    super.initState();
  }

  void _setController() {
    final contract = widget.contract;

    if (contract == null) {
      return;
    }

    _isUpdate = true;
    _meterTyp = contract.meterTyp;
    _basicPrice.text = contract.basicPrice.toString();
    _energyPrice.text = contract.energyPrice.toString();
    _discount.text = contract.discount.toString();
    _bonus.text = contract.bonus.toString();
    _note.text = contract.bonus.toString();

    if (widget.provider != null) {
      final provider = widget.provider;
      if (provider == null) {
        return;
      }

      _providerName.text = provider.name;
      _contractNumber.text = provider.contractNumber;
      _dateBeginController.text =
          DateFormat('dd.MM.yyyy').format(provider.validFrom);
      _dateEndController.text =
          DateFormat('dd.MM.yyyy').format(provider.validUntil);
      _notice.text = provider.notice.toString();
      _providerExpand = true;
    }
  }

  Future<void> _saveEntry() async {
    final db = Provider.of<LocalDatabase>(context, listen: false);
    int providerId = -1;
    int bonus;
    int notice;

    if (_formKey.currentState!.validate()) {
      if (_providerExpand && !_isUpdate) {
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

      if (!_isUpdate) {
        final contract = ContractCompanion(
            meterTyp: drift.Value(_meterTyp),
            provider: drift.Value(providerId),
            basicPrice: drift.Value(double.parse(_basicPrice.text.replaceAll(',', '.'))),
            energyPrice: drift.Value(double.parse(_energyPrice.text.replaceAll(',', '.'))),
            discount: drift.Value(double.parse(_discount.text.replaceAll(',', '.'))),
            bonus: drift.Value(bonus),
            note: drift.Value(_note.text));

        await db.contractDao.createContract(contract).then((value) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
              'Vertrag wird erstellt!',
            ),
          ));
          Navigator.of(context).pop();
        });
      } else {
        if(_providerExpand){
          final provider = ProviderData(
            uid: widget.provider!.uid,
            name: _providerName.text,
            contractNumber: _contractNumber.text,
            notice: int.parse(_notice.text),
            validFrom: _dateBegin!,
            validUntil: _dateBegin!,
          );

          await db.contractDao.updateProvider(provider);
        }

        final contract = ContractData(
          uid: widget.contract!.uid,
          meterTyp: _meterTyp,
          provider: widget.provider!.uid,
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
      }
    }
  }

  void _showDatePicker(BuildContext context, String typ) async {
    await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 10),
      lastDate: DateTime(DateTime.now().year + 10),
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
          children: [
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
  }
}

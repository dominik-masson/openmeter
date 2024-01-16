import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' as drift;
import 'package:provider/provider.dart';

import '../../../core/database/local_database.dart';
import '../../../../utils/meter_typ.dart';
import '../../../core/model/contract_dto.dart';
import '../../../core/model/meter_typ.dart';
import '../../../core/model/provider_dto.dart';
import '../../../core/provider/contract_provider.dart';
import '../../../core/provider/database_settings_provider.dart';
import '../../../core/provider/details_contract_provider.dart';
import '../../../core/provider/refresh_provider.dart';
import '../../../core/helper/provider_helper.dart';
import '../../../utils/convert_meter_unit.dart';
import '../../widgets/meter/meter_circle_avatar.dart';
import '../../widgets/objects_screen/contract/add_provider.dart';

class AddContract extends StatefulWidget {
  final ContractDto? contract;

  const AddContract({super.key, required this.contract});

  @override
  State<AddContract> createState() => _AddContractState();
}

class _AddContractState extends State<AddContract> {
  final _formKey = GlobalKey<FormState>();
  final _expansionKey = GlobalKey();

  final TextEditingController _basicPrice = TextEditingController();
  final TextEditingController _energyPrice = TextEditingController();
  final TextEditingController _discount = TextEditingController();
  final TextEditingController _bonus = TextEditingController();
  final TextEditingController _note = TextEditingController();
  final TextEditingController _unitController = TextEditingController();

  final ConvertMeterUnit convertMeterUnit = ConvertMeterUnit();

  String _meterTyp = 'Stromzähler';
  bool _providerExpand = false;

  bool _isUpdate = false;
  String _pageName = 'Neuer Vertrag';

  ContractDto? _contractDto;
  ProviderDto? _providerDto;

  final ProviderHelper _providerHelper = ProviderHelper();

  @override
  void initState() {
    _setController();
    super.initState();
  }

  @override
  void dispose() {
    _energyPrice.dispose();
    _basicPrice.dispose();
    _discount.dispose();
    _bonus.dispose();
    _note.dispose();
    _unitController.dispose();

    super.dispose();
  }

  void _setController() {
    _contractDto = widget.contract;

    final meterTyp =
        meterTyps.firstWhere((element) => element.meterTyp == _meterTyp);

    if (_contractDto == null) {
      _unitController.text = meterTyp.unit;
      return;
    }

    final String local = Platform.localeName;
    final formatPattern =
        NumberFormat.decimalPatternDigits(locale: local, decimalDigits: 2);

    _pageName = meterTyp.providerTitle;
    _isUpdate = true;
    _meterTyp = _contractDto!.meterTyp;
    _basicPrice.text = formatPattern.format(_contractDto!.costs.basicPrice);
    _energyPrice.text = formatPattern.format(_contractDto!.costs.energyPrice);
    _discount.text = formatPattern.format(_contractDto!.costs.discount);
    _bonus.text = _contractDto!.costs.bonus.toString();
    _note.text = _contractDto!.note!;
    _unitController.text = _contractDto!.unit;
  }

  int _convertBonus() {
    if (_bonus.text.isEmpty) {
      return 0;
    } else {
      return int.parse(_bonus.text);
    }
  }

  Future<ProviderDto?> _handleProvider(
      LocalDatabase db, DetailsContractProvider detailsProvider) async {
    final contractProvider =
        Provider.of<ContractProvider>(context, listen: false);

    // Create Provider
    if (_contractDto?.provider == null && _providerDto != null) {
      ProviderDto provider =
          await _providerHelper.createProvider(db: db, provider: _providerDto!);

      return provider;
    }

    // Delete Provider
    if (detailsProvider.getDeleteProviderState) {
      await _providerHelper.deleteProvider(
        db: db,
        provider: _contractDto!.provider!,
        contractProvider: contractProvider,
        contractId: _contractDto!.id!,
      );

      detailsProvider.setDeleteProviderState(false, false);

      return null;
    }

    // Update Provider
    if (_isUpdate) {
      if (_providerDto != null) {
        ProviderDto? provider = await _providerHelper.updateProvider(
            db: db, provider: _providerDto!);

        return provider;
      } else {
        return _contractDto?.provider;
      }
    }

    return detailsProvider.getCurrentProvider;
  }

  _convertDouble(String text) {
    String newText = text.replaceAll('.', '');

    return double.parse(newText.replaceAll(',', '.'));
  }

  double _convertEnergyPrice(String energyPrice) {
    if (energyPrice.contains(',')) {
      return double.parse(energyPrice.replaceAll(',', '.'));
    } else {
      return double.parse(energyPrice);
    }
  }

  Future<void> _createEntry(
      LocalDatabase db, DetailsContractProvider detailsProvider) async {
    int bonus = _convertBonus();

    ProviderDto? provider = await _handleProvider(db, detailsProvider);

    final contract = ContractCompanion(
      meterTyp: drift.Value(_meterTyp),
      provider: drift.Value(provider?.id),
      basicPrice: drift.Value(_convertDouble(_basicPrice.text)),
      energyPrice: drift.Value(_convertEnergyPrice(_energyPrice.text)),
      discount: drift.Value(_convertDouble(_discount.text)),
      bonus: drift.Value(bonus),
      note: drift.Value(_note.text),
      isArchived: drift.Value(_contractDto?.isArchived ?? false),
      unit: drift.Value(_unitController.text),
    );

    int contractId = await db.contractDao.createContract(contract);

    if (context.mounted) {
      Navigator.of(context).pop(ContractDto.fromCompanion(
        data: contract,
        contractId: contractId,
        provider: provider,
      ));
    }
  }

  Future<void> _updateEntry(
      LocalDatabase db, DetailsContractProvider detailsProvider) async {
    final provider = Provider.of<ContractProvider>(context, listen: false);

    int bonus = _convertBonus();
    ProviderDto? providerDto = await _handleProvider(db, detailsProvider);

    final contract = ContractData(
      id: _contractDto!.id!,
      meterTyp: _meterTyp,
      provider: providerDto?.id,
      basicPrice: _convertDouble(_basicPrice.text),
      energyPrice: _convertEnergyPrice(_energyPrice.text),
      discount: _convertDouble(_discount.text),
      bonus: bonus,
      note: _note.text,
      isArchived: _contractDto!.isArchived,
      unit: _unitController.text,
    );

    await db.contractDao.updateContract(contract).then((value) {
      Navigator.of(context).pop(
        ContractDto.fromData(
          contract,
          providerDto?.toData(),
        ),
      );
    });

    provider.updateContract(
        db: db, data: contract, providerId: providerDto?.id);
  }

  Future<void> _handleOnSave(DetailsContractProvider detailsProvider) async {
    final db = Provider.of<LocalDatabase>(context, listen: false);

    if (_formKey.currentState!.validate()) {
      if (_isUpdate) {
        await _updateEntry(db, detailsProvider);
      } else {
        await _createEntry(db, detailsProvider);
      }

      if (context.mounted) {
        Provider.of<RefreshProvider>(context, listen: false).setRefresh(true);
        Provider.of<DatabaseSettingsProvider>(context, listen: false)
            .setHasUpdate(true);
      }
    }
  }

  Widget _dropdownMeterTyp(BuildContext context, List<MeterTyp> newMeterTyps) {
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
        ),
        isDense: false,
        items: newMeterTyps.map((element) {
          final avatarData = element.avatar;
          return DropdownMenuItem(
            value: element.meterTyp,
            child: Row(
              children: [
                MeterCircleAvatar(
                  color: avatarData.color,
                  icon: avatarData.icon,
                  size: MediaQuery.of(context).size.width * 0.045,
                ),
                const SizedBox(
                  width: 20,
                ),
                Text(element.meterTyp),
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

  _getProvider(ProviderDto? provider, DetailsContractProvider detailsProvider) {
    _providerDto = provider;

    _handleOnSave(detailsProvider);
  }

  Widget _provider() {
    return ExpansionTile(
      title: Text(
        'Vertragsdetails',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: _providerExpand
              ? Theme.of(context).primaryColor
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
        AddProvider(
          showCanceledButton: _contractDto?.provider != null,
          createProvider: _isUpdate,
          onSave: _getProvider,
          textSize: 18,
          provider: widget.contract?.provider,
        ),
      ],
    );
  }

  // Map<String, dynamic> _filterMeterTyps() {
  //   Map<String, dynamic> result = {};

  //   for (String key in meterTyps.keys) {
  //     dynamic value = meterTyps[key];
  //
  //     if (value['anbieter'] != '') {
  //       result.addAll({
  //         key: value,
  //       });
  //     }
  //   }
  //
  //   return result;
  // }

  List<MeterTyp> _filterMeterTyps() {
    List<MeterTyp> result = [];

    for (MeterTyp element in meterTyps) {
      if (element.providerTitle.isNotEmpty) {
        result.add(element);
      }
    }

    return result;
  }

  _unitField() {
    return Row(
      children: [
        Flexible(
          child: TextFormField(
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
                icon: FaIcon(
                  FontAwesomeIcons.ruler,
                  size: 16,
                ),
                label: Text('Einheit'),
                hintText: 'm^3 entspricht m\u00B3'),
            controller: _unitController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Bitte geben Sie eine Einheit an!';
              }
              return null;
            },
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),
        Column(
          children: [
            const Text(
              'Vorschau',
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
            convertMeterUnit.getUnitWidget(
              count: '',
              unit: _unitController.text,
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 19,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<MeterTyp> newMeterTyps = _filterMeterTyps();
    final detailsProvider = Provider.of<DetailsContractProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_pageName),
      ),
      floatingActionButton: _providerExpand
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _handleOnSave(detailsProvider),
              label: const Text('Speichern'),
            ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _dropdownMeterTyp(context, newMeterTyps),
                const SizedBox(
                  height: 15,
                ),
                _unitField(),
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

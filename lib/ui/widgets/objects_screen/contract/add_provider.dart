import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/model/provider_dto.dart';
import '../../../../core/provider/details_contract_provider.dart';

class AddProvider extends StatefulWidget {
  final bool showCanceledButton;
  final ProviderDto? provider;
  final double textSize;
  final Function(ProviderDto?, bool) onSave;
  final bool createProvider;

  const AddProvider({
    super.key,
    required this.showCanceledButton,
    this.provider,
    required this.textSize,
    required this.onSave,
    required this.createProvider,
  });

  @override
  State<AddProvider> createState() => _AddProviderState();
}

class _AddProviderState extends State<AddProvider> {
  ProviderDto? _currentProvider;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _dateEndController = TextEditingController();
  final TextEditingController _dateBeginController = TextEditingController();
  final TextEditingController _renewal = TextEditingController();
  final TextEditingController _canceledDateController = TextEditingController();
  final TextEditingController _providerName = TextEditingController();
  final TextEditingController _contractNumber = TextEditingController();
  final TextEditingController _notice = TextEditingController();

  DateTime? _dateBegin = DateTime.now();
  DateTime? _dateEnd = DateTime(
      DateTime.now().year + 2, DateTime.now().month, DateTime.now().day);
  DateTime? _canceledDate;

  final DateFormat _formatDate = DateFormat('dd.MM.yyyy');

  bool firstInit = true;
  bool isDelete = false;

  @override
  void dispose() {
    _dateEndController.dispose();
    _dateBeginController.dispose();
    _renewal.dispose();
    _canceledDateController.dispose();
    _providerName.dispose();
    _contractNumber.dispose();
    _notice.dispose();

    super.dispose();
  }

  void _initController(bool isDelete) {
    if (_currentProvider != null && firstInit) {
      firstInit = false;

      final provider = _currentProvider!;

      _initDateTimes(provider);

      if (_canceledDate != null) {
        _canceledDateController.text = _formatDate.format(_canceledDate!);
      } else {
        _canceledDateController.clear();
      }

      _providerName.text = provider.name;
      _contractNumber.text = provider.contractNumber;

      _dateBeginController.text = _formatDate.format(provider.validFrom);
      _dateEndController.text = _formatDate.format(provider.validUntil);

      _notice.text = provider.notice.toString();

      _renewal.text =
          provider.renewal == null ? '' : provider.renewal.toString();
    } else {
      _dateBeginController.text = _formatDate.format(_dateBegin!);
      _dateEndController.text = _formatDate.format(_dateEnd!);
    }

    if (isDelete) {
      _resetController();
    }
  }

  void _initDateTimes(ProviderDto provider) {
    _dateBegin = provider.validFrom;
    _dateEnd = provider.validUntil;
    _canceledDate = provider.canceledDate;
  }

  _resetController() {
    _dateBeginController.text = _formatDate.format(_dateBegin!);
    _dateEndController.text = _formatDate.format(_dateEnd!);
    _providerName.clear();
    _contractNumber.clear();
    _canceledDateController.clear();
    _notice.clear();
    _renewal.clear();
  }

  void _showDatePicker(BuildContext context, String typ) async {
    DateTime initDate = DateTime.now();

    switch (typ) {
      case 'begin':
        initDate = _dateBegin!;
        break;
      case 'canceled':
        initDate = _canceledDate == null ? DateTime.now() : _canceledDate!;
        break;
      case 'end':
        initDate = _dateEnd!;
        break;
      default:
        initDate = DateTime.now();
        break;
    }

    await showDatePicker(
      context: context,
      initialDate: initDate,
      firstDate: DateTime(DateTime.now().year - 10),
      lastDate: DateTime(DateTime.now().year + 10),
      locale: const Locale('de', ''),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        switch (typ) {
          case 'begin':
            _dateBegin = pickedDate;
            _dateBeginController.text = _formatDate.format(_dateBegin!);
            break;
          case 'canceled':
            _canceledDate = pickedDate;
            _canceledDateController.text = _formatDate.format(_canceledDate!);
            break;
          default:
            _dateEnd = pickedDate;
            _dateEndController.text = _formatDate.format(_dateEnd!);
            break;
        }
      });
    });
  }

  ProviderDto getProvider() {
    int? renewal = _renewal.text.isEmpty ? null : int.parse(_renewal.text);
    int? notice = _notice.text.isEmpty ? null : int.parse(_notice.text);

    return ProviderDto(
      id: _currentProvider?.id,
      name: _providerName.text,
      contractNumber: _contractNumber.text,
      validUntil: _dateEnd!,
      validFrom: _dateBegin!,
      notice: notice,
      renewal: renewal,
      canceledDate: _canceledDate,
      canceled: _canceledDate != null,
      showShouldCanceled: false,
    );
  }

  _deleteProvider() {
    _resetController();
    isDelete = true;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DetailsContractProvider>(context);

    _currentProvider = provider.getCurrentProvider;

    _initController(provider.getDeleteProviderState);

    if (provider.getDeleteProviderState) {
      provider.setDeleteProviderState(false, false);
    }

    if (provider.getRemoveCanceledDateState) {
      _canceledDateController.clear();
      provider.setRemoveCanceledDateState(false, false);
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showCanceledButton)
            TextButton(
              onPressed: _deleteProvider,
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
            decoration: InputDecoration(
              label: const Text('Anbieter/Vertragsname'),
              labelStyle: TextStyle(fontSize: widget.textSize),
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
            decoration: InputDecoration(
              label: const Text('Vertragsnummer'),
              labelStyle: TextStyle(fontSize: widget.textSize),
            ),
          ),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: TextFormField(
                  readOnly: true,
                  controller: _dateBeginController,
                  onTap: () => _showDatePicker(context, 'begin'),
                  decoration: InputDecoration(
                    label: const Text('Vertragsbeginn'),
                    labelStyle: TextStyle(fontSize: widget.textSize),
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
                  controller: _dateEndController,
                  onTap: () => _showDatePicker(context, 'end'),
                  decoration: InputDecoration(
                    label: const Text('Vertragslaufzeit'),
                    labelStyle: TextStyle(fontSize: widget.textSize),
                  ),
                ),
              ),
            ],
          ),
          TextFormField(
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.number,
            controller: _notice,
            decoration: InputDecoration(
              label: const Text('Kündigungsfrist'),
              labelStyle: TextStyle(fontSize: widget.textSize),
              suffixText: 'Monate',
            ),
          ),
          TextFormField(
            keyboardType: TextInputType.number,
            controller: _renewal,
            decoration: InputDecoration(
              label: const Text('Vertragsverlängerung'),
              labelStyle: TextStyle(fontSize: widget.textSize),
              suffixText: 'Monate',
            ),
          ),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: TextFormField(
                  readOnly: true,
                  controller: _canceledDateController,
                  onTap: () => _showDatePicker(context, 'canceled'),
                  decoration: InputDecoration(
                    label: const Text('Gekündigt am'),
                    labelStyle: TextStyle(fontSize: widget.textSize),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              if (_canceledDate != null && widget.showCanceledButton)
                Expanded(
                  flex: 1,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _canceledDateController.clear();
                        _canceledDate = null;
                      });
                    },
                    child: const Text('Kündigung entfernen'),
                  ),
                ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton.extended(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  widget.onSave(isDelete ? null : getProvider(), isDelete);
                }
              },
              label: const Text('Speichern'),
            ),
          ),
        ],
      ),
    );
  }
}

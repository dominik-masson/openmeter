import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/provider/sort_provider.dart';

class SortMeterCards {
  dynamic _selectedSort;
  dynamic _selectedOrder;

  SortMeterCards();

  Future getFilter({
    required BuildContext context,
  }) {
    final sortProvider = Provider.of<SortProvider>(context, listen: false);
    _selectedSort = sortProvider.getSort;
    _selectedOrder = sortProvider.getOrder;

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sortieren nach'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Raum'),
                  leading: Radio(
                    value: 'room',
                    groupValue: _selectedSort,
                    onChanged: (value) {
                      setState(
                        () => _selectedSort = value,
                      );
                    },
                  ),
                  onTap: () {
                    setState(
                      () => _selectedSort = 'room',
                    );
                  },
                ),
                ListTile(
                  title: const Text('Zähler'),
                  leading: Radio(
                    value: 'meter',
                    groupValue: _selectedSort,
                    onChanged: (value) {
                      setState(
                        () => _selectedSort = value,
                      );
                    },
                  ),
                  onTap: () {
                    setState(
                      () => _selectedSort = 'meter',
                    );
                  },
                ),
                const Divider(thickness: 0.3),
                ListTile(
                  title: const Text('Aufsteigend'),
                  leading: Radio(
                    value: 'asc',
                    groupValue: _selectedOrder,
                    onChanged: (value) {
                      setState(
                        () => _selectedOrder = value,
                      );
                    },
                  ),
                  onTap: () {
                    setState(
                      () => _selectedOrder = 'asc',
                    );
                  },
                ),
                ListTile(
                  title: const Text('Absteigend'),
                  leading: Radio(
                    value: 'desc',
                    groupValue: _selectedOrder,
                    onChanged: (value) {
                      setState(
                        () => _selectedOrder = value,
                      );
                    },
                  ),
                  onTap: () {
                    setState(
                      () => _selectedOrder = 'desc',
                    );
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () {
              sortProvider.setSort(_selectedSort);
              sortProvider.setOrder(_selectedOrder);
              Navigator.of(context).pop(true);
            },
            child: const Text(
              'Sortieren',
            ),
          ),
        ],
      ),
    );
  }
}

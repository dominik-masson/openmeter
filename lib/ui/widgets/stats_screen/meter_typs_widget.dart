import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/database/local_database.dart';
import '../../../core/provider/stats_provider.dart';

class MeterTypsWidget extends StatefulWidget {
  const MeterTypsWidget({Key? key}) : super(key: key);

  @override
  State<MeterTypsWidget> createState() => _MeterTypsWidgetState();
}

class _MeterTypsWidgetState extends State<MeterTypsWidget> {
  @override
  Widget build(BuildContext context) {
    final statsProvider = Provider.of<StatsProvider>(context);
    final db = Provider.of<LocalDatabase>(context);

    final List<String> tagsId = statsProvider.getTagsIdList;
    final int handleTags = statsProvider.getHandleTags;

    if (tagsId.isNotEmpty) {
      if (handleTags == 1) {
        return _calcWithSelectedTags(db);
      } else {
        return _calcWithoutSelectedTags(db);
      }
    }

    return _calcWithoutTags();
  }
}

Widget _calcWithSelectedTags(LocalDatabase db) {
  return Container();
}

Widget _calcWithoutSelectedTags(LocalDatabase db) {
  return StreamBuilder(
    stream: db.meterDao.watchAllMeterWithRooms(),
    builder: (context, snapshot) {
      final List<MeterData> meters = [];

      return Container();
    },
  );
}

Widget _calcWithoutTags() {
  return Container();
}

import 'package:flutter/material.dart';

import '../../widgets/design_settings_screen/change_preview.dart';
import '../../widgets/design_settings_screen/compact_nav_bar.dart';
import '../../widgets/design_settings_screen/dynamic_color_tile.dart';
import '../../widgets/design_settings_screen/font_size_tile.dart';
import '../../widgets/design_settings_screen/theme_title.dart';
import '../../widgets/design_settings_screen/display_awake.dart';

class DesignScreen extends StatefulWidget {
  const DesignScreen({super.key});

  @override
  State<DesignScreen> createState() => _DesignScreenState();
}

class _DesignScreenState extends State<DesignScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Darstellung'),
      ),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: ChangePreview(),
              ),
              SizedBox(
                height: 15,
              ),
              ThemeTitle(),
              DynamicColorTile(),
              CompactNavBarSettings(),
              FontSizeTile(),
              Divider(),
              DisplayAwake(),
            ],
          ),
        ),
      ),
    );
  }
}

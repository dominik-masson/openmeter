import 'package:flutter/material.dart';
import 'package:openmeter/core/enums/font_size_value.dart';
import 'package:openmeter/utils/custom_colors.dart';
import 'package:provider/provider.dart';

import '../../../core/provider/design_provider.dart';
import '../../../core/provider/theme_changer.dart';
import '../../../utils/custom_icons.dart';

class ChangePreview extends StatelessWidget {
  const ChangePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 250,
      child: Card(
        child: Center(
          child: Container(
            width: MediaQuery.sizeOf(context).width * 0.65,
            height: 200,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: const Border(
                right: BorderSide(
                  width: 1,
                  color: Colors.grey,
                  style: BorderStyle.solid,
                ),
                bottom: BorderSide(
                  width: 1,
                  color: Colors.grey,
                  style: BorderStyle.solid,
                ),
                left: BorderSide(
                  width: 1,
                  color: Colors.grey,
                  style: BorderStyle.solid,
                ),
                top: BorderSide(
                  width: 1,
                  color: Colors.grey,
                  style: BorderStyle.solid,
                ),
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(10),
              ),
            ),
            child: Column(
              children: [
                _meterCard(context),
                const Spacer(),
                _navBar(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _getTextHeight(ThemeChanger themeChanger) {
    final textMode = themeChanger.getFontSizeValue;

    switch (textMode) {
      case FontSizeValue.large:
        return 17;
      case FontSizeValue.small:
        return 13;
      default:
        return 15;
    }
  }

  _meterInformation(BoxDecoration decoration, ThemeChanger themeChanger) {
    final double height = _getTextHeight(themeChanger);

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(),
        1: FlexColumnWidth(),
        2: FixedColumnWidth(100),
      },
      children: [
        TableRow(
          children: [
            Column(
              children: [
                Container(
                  width: 60,
                  height: height - 2,
                  decoration: decoration,
                ),
                const SizedBox(
                  height: 4,
                ),
                Container(
                  width: 30,
                  height: height - 6,
                  decoration: decoration,
                ),
              ],
            ),
            Column(
              children: [
                Container(
                  width: 60,
                  height: height - 2,
                  decoration: decoration,
                ),
                const SizedBox(
                  height: 4,
                ),
                Container(
                  width: 30,
                  height: height - 6,
                  decoration: decoration,
                ),
              ],
            ),
            Column(
              children: [
                Container(
                  width: 80,
                  height: height - 2,
                  decoration: decoration,
                ),
              ],
            )
          ],
        ),
      ],
    );
  }

  _meterCard(BuildContext context) {
    final themeChanger = Provider.of<ThemeChanger>(context);

    final color = themeChanger.getThemeMode == ThemeMode.dark
        ? Colors.white30
        : CustomColors.lightGrey;

    const radius = BorderRadius.all(Radius.circular(16));

    final decoration = BoxDecoration(
      color: color,
      borderRadius: radius,
    );

    final double height = _getTextHeight(themeChanger);

    return SizedBox(
      height: 120,
      width: double.infinity,
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: color,
                    radius: 13,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Container(
                    width: 100,
                    height: height,
                    decoration: decoration,
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              _meterInformation(decoration, themeChanger),
              const Spacer(),
              Center(
                child: Container(
                  width: 100,
                  height: height - 4,
                  decoration: decoration,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _navBar(BuildContext context) {
    final provider = Provider.of<DesignProvider>(context);

    bool compactNavBar = provider.getStateCompactNavBar;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(9)),
      child: NavigationBar(
        selectedIndex: 0,
        height: 63,
        labelBehavior: compactNavBar
            ? NavigationDestinationLabelBehavior.alwaysHide
            : NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(CustomIcons.voltmeter),
            label: 'Zähler',
          ),
          NavigationDestination(
            icon: Icon(Icons.widgets),
            label: 'Objekte',
          ),
        ],
      ),
    );
  }
}

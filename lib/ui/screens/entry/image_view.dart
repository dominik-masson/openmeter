import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/model/entry_dto.dart';
import '../../../core/provider/database_settings_provider.dart';
import '../../../core/provider/entry_provider.dart';
import '../../../core/helper/meter_image_helper.dart';
import '../../../utils/convert_count.dart';
import '../../../utils/convert_meter_unit.dart';

class ImageView extends StatefulWidget {
  final File image;
  final EntryDto entry;

  const ImageView({super.key, required this.image, required this.entry});

  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView>
    with SingleTickerProviderStateMixin {
  final MeterImageHelper _meterImageHelper = MeterImageHelper();

  final _transformationController = TransformationController();
  TapDownDetails? _doubleTapDetails;

  late AnimationController _animationController;
  Animation<Matrix4>? _animation;

  final double _scale = 5;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() {
        _transformationController.value = _animation!.value;
      });

    super.initState();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entryProvider = Provider.of<EntryProvider>(context);
    String unit = entryProvider.getMeterUnit;
    String meterNumber = entryProvider.getMeterNumber;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  meterNumber,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                ConvertMeterUnit().getUnitWidget(
                  count: ConvertCount.convertCount(widget.entry.count),
                  unit: unit,
                  textStyle: Theme.of(context).textTheme.bodyMedium!,
                ),
              ],
            ),
            Text(
              DateFormat('dd.MM.yyyy').format(widget.entry.date),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
      body: GestureDetector(
        onDoubleTapDown: (details) => _doubleTapDetails = details,
        onDoubleTap: () {
          final positions = _doubleTapDetails!.localPosition;

          final x = -positions.dx * (_scale - 1);
          final y = -positions.dy * (_scale - 1.5);

          final zoomed = Matrix4.identity()
            ..translate(x, y)
            ..scale(_scale);

          final value = _transformationController.value.isIdentity()
              ? zoomed
              : Matrix4.identity();

          _animation =
              Matrix4Tween(begin: _transformationController.value, end: value)
                  .animate(CurveTween(curve: Curves.easeOut)
                      .animate(_animationController));

          _animationController.forward(from: 0);
        },
        child: InteractiveViewer(
          transformationController: _transformationController,
          minScale: 0.2,
          maxScale: _scale,
          child: Center(child: Image.file(widget.image)),
        ),
      ),
      bottomNavigationBar: _bottomBar(),
    );
  }

  _createButtons(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Column(
        children: [
          Icon(
            icon,
            size: 25,
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          )
        ],
      ),
    );
  }

  _bottomBar() {
    final buttonStyle = ButtonStyle(
      foregroundColor: MaterialStateProperty.all(
        Theme.of(context).textTheme.bodyLarge!.color,
      ),
    );

    final databaseSettingsProvider =
        Provider.of<DatabaseSettingsProvider>(context);

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.1,
      child: Card(
        child: Table(
          children: [
            TableRow(
              children: [
                TextButton(
                  onPressed: () async {
                    bool success = await _meterImageHelper
                        .saveImageToGallery(widget.image);

                    if (mounted) {
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Bild wurde in der Galerie gespeichert!',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Bild konnte nicht in die Galerie gespeichert werden!',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                  style: buttonStyle,
                  child: _createButtons(
                    Icons.save_alt,
                    'Speichern',
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    databaseSettingsProvider.toggleInAppActionState();
                    await Share.shareXFiles([XFile(widget.image.path)]).then(
                      (value) =>
                          databaseSettingsProvider.toggleInAppActionState(),
                    );
                  },
                  child: _createButtons(
                    Icons.share,
                    'Teilen',
                  ),
                  style: buttonStyle,
                ),
                TextButton(
                  onPressed: () async {
                    await _meterImageHelper
                        .deleteImage(widget.image.path)
                        .then((value) => Navigator.of(context).pop(true));
                  },
                  child: _createButtons(
                    Icons.delete_outline,
                    'Löschen',
                  ),
                  style: buttonStyle,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

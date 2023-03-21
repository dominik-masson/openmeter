import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class TagsTile extends StatelessWidget {
  const TagsTile({Key? key,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text(
        'Tags',
        style: TextStyle(
          fontSize: 18,
        ),
      ),
      leading: const FaIcon(FontAwesomeIcons.tags),
      onTap: () => Navigator.of(context).pushNamed('tags_screen'),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TagsTile extends StatelessWidget {
  const TagsTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        'Tags',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      leading: const FaIcon(FontAwesomeIcons.tags),
      onTap: () => Navigator.of(context).pushNamed('tags_screen'),
    );
  }
}

import 'package:discyo/components/dialogs.dart';
import 'package:discyo/models/loader.dart';
import 'package:flutter/material.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    this.title,
    this.icon,
    this.button,
    Key? key,
  }) : super(key: key);

  final String? title;
  final IconData? icon;
  final Widget? button;

  Widget _buildBackButton(BuildContext context) {
    return IconButton(
      icon: const BackButtonIcon(),
      alignment: Alignment.centerLeft,
      onPressed: () => Navigator.of(context).pop(),
      padding: EdgeInsets.symmetric(vertical: 8.0),
    );
  }

  Widget _buildTitle(BuildContext context) {
    if (icon == null)
      return Text(title!, style: Theme.of(context).textTheme.headline4);
    return Flexible(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 4.0)),
          Flexible(
            child: Text(
              title!,
              style: Theme.of(context).textTheme.headline4,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  static Widget filterButton(FilteredListLoader loader) {
    return PopupMenuButton(
      itemBuilder: (context) {
        List<PopupMenuEntry> entries = [];
        for (var i = 0; i < loader.filters.length; i++) {
          entries.addAll(loader.filters[i].options.map<PopupMenuEntry>((o) {
            return PopupMenuItem(
              child: StatefulBuilder(
                builder: (context, _setState) => CheckboxListTile(
                  activeColor: Theme.of(context).colorScheme.primary,
                  checkColor: Theme.of(context).colorScheme.background,
                  contentPadding: const EdgeInsets.all(0),
                  title: loader.filters[i].label(o),
                  value: loader.filters[i].state(o),
                  onChanged: (_) => _setState(() => loader.toggle(i, o)),
                  controlAffinity: ListTileControlAffinity.trailing,
                ),
              ),
            );
          }).toList());
          entries.add(PopupMenuDivider());
        }
        if (entries.length > 0) entries.removeLast();
        return entries;
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: EdgeInsets.symmetric(vertical: 8.0),
      icon: Align(
        alignment: Alignment.centerRight,
        child: Icon(Icons.filter_alt),
      ),
    );
  }

  static Widget helpButton(
      BuildContext context, String title, String description) {
    return IconButton(
      onPressed: () => showInfoDialog(context, title, description),
      icon: Icon(Icons.help_outline),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (title == null)
      return Align(
        alignment: Alignment.centerLeft,
        child: _buildBackButton(context),
      );
    if (button == null)
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _buildBackButton(context),
          _buildTitle(context),
          SizedBox(width: 40.0, height: 40.0),
        ],
      );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        _buildBackButton(context),
        _buildTitle(context),
        button!,
      ],
    );
  }
}

class EditPageHeader extends StatelessWidget {
  const EditPageHeader({
    required this.title,
    required this.cancel,
    required this.save,
    Key? key,
  }) : super(key: key);

  final String title;
  final void Function() cancel;
  final void Function() save;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.close),
          alignment: Alignment.centerLeft,
          onPressed: cancel,
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.headline4,
        ),
        IconButton(
          icon: Icon(Icons.check),
          alignment: Alignment.centerLeft,
          onPressed: save,
        ),
      ],
    );
  }
}

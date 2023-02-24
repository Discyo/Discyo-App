import 'package:flutter/material.dart';

class ListItem extends StatelessWidget {
  const ListItem({
    required this.title,
    required this.thumbnail,
    this.callback,
    this.icon,
    Key? key,
  }) : super(key: key);

  final String title;
  final ImageProvider thumbnail;
  final void Function()? callback;
  final IconData? icon;

  static Widget get placeholder => SizedBox(
        height: 70,
        width: double.infinity,
        child: Center(child: CircularProgressIndicator()),
      );

  Widget _buildLabel(BuildContext context) {
    if (icon == null)
      return Expanded(
        child: Text(
          title,
          style: Theme.of(context).textTheme.subtitle1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              title,
              style: Theme.of(context).textTheme.subtitle1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Icon(icon),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      width: double.infinity,
      child: TextButton(
        onPressed: callback,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 54,
                height: 54,
                child: Image(image: thumbnail, fit: BoxFit.cover),
              ),
            ),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 6)),
            _buildLabel(context),
          ],
        ),
      ),
    );
  }
}

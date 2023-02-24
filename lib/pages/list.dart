import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:discyo/components/header.dart';
import 'package:discyo/components/list_item.dart';
import 'package:discyo/components/palette_background.dart';
import 'package:discyo/models/loader.dart';
import 'package:discyo/models/media/medium.dart';

class ListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

    return PaletteBackground(
      colors: PaletteBackground.defaultColors,
      layout: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: ChangeNotifierProvider<FilteredListLoader>.value(
          value: args["loader"],
          child: Consumer<FilteredListLoader>(
            builder: (context, loader, child) {
              return Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: PageHeader(
                      title: args["title"],
                      icon: args["icon"],
                      button: PageHeader.filterButton(loader),
                    ),
                  ),
                  Expanded(
                    child: _ListBody(
                      loader: loader,
                      showStates: args["show_states"],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ListBody extends StatelessWidget {
  const _ListBody({
    required this.loader,
    this.showStates = false,
    Key? key,
  }) : super(key: key);

  final FilteredListLoader loader;
  final bool showStates;

  Widget _buildItem(BuildContext context, Medium item) {
    return ListItem(
      title: item.title,
      thumbnail: item.thumbnailProvider,
      callback: () async {
        await Navigator.pushNamed(
          context,
          "/details",
          arguments: item,
        );
        if (item.dirty) loader.reload();
      },
      icon: showStates ? item.state?.icon : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loader.loading && loader.items.length == 0)
      return Center(child: CircularProgressIndicator());
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo.metrics.extentAfter <= 800) {
          loader.load();
          return true;
        }
        return false;
      },
      child: ListView.builder(
        itemCount: loader.canLoadMore
            ? loader.items.length + 1
            : loader.items.length,
        itemBuilder: (_, i) => i >= loader.items.length
            ? ListItem.placeholder
            : _buildItem(context, loader.items[i]),
      ),
    );
  }
}

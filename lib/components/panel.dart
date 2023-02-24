import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PanelManager extends StatefulWidget {
  const PanelManager({
    required this.panels,
    required this.titles,
    required this.icons,
  })  : assert(panels.length == titles.length),
        assert(titles.length == icons.length);

  final List<Panel> panels;
  final List<String> titles;
  final List icons;

  @override
  _PanelManagerState createState() => _PanelManagerState();
}

class _PanelManagerState extends State<PanelManager> {
  int selected = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  Widget _buildIcon(dynamic asset, bool isSelected) {
    if (asset is IconData) return Icon(asset, size: 28);
    if (asset is ImageProvider)
      return Padding(
        padding: const EdgeInsets.all(2),
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            border: isSelected
                ? Border.all(color: Theme.of(context).accentColor, width: 1.5)
                : null,
            shape: BoxShape.circle,
            image: DecorationImage(fit: BoxFit.cover, image: asset),
          ),
        ),
      );
    return SizedBox(width: 28, height: 28);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!widget.panels[selected].navigatorKey.currentState!.canPop())
          return true;
        widget.panels[selected].navigatorKey.currentState!.pop();
        return false;
      },
      child: Scaffold(
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Stack(
            children: List<Widget>.generate(widget.panels.length, (i) {
              return Offstage(
                offstage: i != selected,
                child: widget.panels[i],
              );
            }),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: List<BottomNavigationBarItem>.generate(
            widget.panels.length,
            (i) {
              return BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: _buildIcon(widget.icons[i], i == selected),
                ),
                label: widget.titles[i],
              );
            },
          ),
          currentIndex: selected,
          onTap: (i) => setState(() {
            if (selected == i) {
              while (
                  widget.panels[selected].navigatorKey.currentState!.canPop())
                widget.panels[selected].navigatorKey.currentState!.pop();
            } else {
              selected = i;
            }
          }),
          backgroundColor: Theme.of(context).primaryColor,
          unselectedItemColor: Theme.of(context).primaryColorLight,
          selectedItemColor: Theme.of(context).accentColor,
          selectedFontSize: 12.0,
        ),
      ),
    );
  }
}

class Panel extends StatelessWidget {
  const Panel({
    required this.navigatorKey,
    required this.routes,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final Map<String, WidgetBuilder> routes;

  MaterialPageRoute generateRoute(RouteSettings settings) {
    WidgetBuilder builder;
    if (!routes.containsKey(settings.name))
      throw Exception('Invalid route: ${settings.name}');
    builder = routes[settings.name]!;
    return MaterialPageRoute(builder: builder, settings: settings);
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      initialRoute: routes.keys.elementAt(0),
      onGenerateRoute: generateRoute,
    );
  }
}

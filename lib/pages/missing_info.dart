import 'package:flutter/material.dart';
import 'package:discyo/components/dialogs.dart';
import 'package:discyo/components/fields.dart';
import 'package:discyo/components/palette_background.dart';
import 'package:discyo/localizations/localizations.dart';
import 'package:discyo/utils.dart';

class MissingInfoPage extends StatefulWidget {
  MissingInfoPage({
    Key? key,
    required this.missingInfo,
    required this.setInfo,
  }) : super(key: key);

  final List<String> missingInfo;
  final Function setInfo;

  @override
  _MissingInfoPageState createState() => _MissingInfoPageState();
}

class _MissingInfoPageState extends State<MissingInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  bool _usernameTaken = false;
  final _nameController = TextEditingController();
  String _country = "";
  final _countrySuggestions = getConfigurationMap("countries");

  Map<String, dynamic> _getInfo() {
    Map<String, dynamic> info = {};
    if (widget.missingInfo.contains("username"))
      info["username"] = _usernameController.text;
    if (widget.missingInfo.contains("name"))
      info["name"] = _nameController.text;
    if (widget.missingInfo.contains("country_code"))
      info["country_code"] = _country;
    return info;
  }

  Future<void> _submit(BuildContext context) async {
    final localized = DiscyoLocalizations.of(context);
    _usernameTaken = false;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    int exitCode = await widget.setInfo(_getInfo());
    if (exitCode != 201 && exitCode != 406) {
      showError(context, localized.error("unexpected"));
      return;
    }
    // if exit code is 201, the screen should update automatically as user is observed
    if (exitCode == 406) {
      _usernameTaken = true;
      _formKey.currentState?.validate();
    }
  }

  List<Widget> _buildFields(BuildContext context) {
    final localized = DiscyoLocalizations.of(context);
    List<Widget> fields = [];
    if (widget.missingInfo.contains("username")) {
      fields.add(buildTextField(
        context,
        _usernameController,
        localized.label("username"),
        validator: (value) {
          if (value?.isEmpty ?? true) return localized.error("empty_username");
          final le = value?.length ?? 0;
          if (le < 3 || le > 32)
            return localized.error("invalid_username_length");
          final re = r"^[a-zA-Z0-9_-]+$";
          if (!RegExp(re).hasMatch(value ?? ""))
            return localized.error("invalid_username_characters");
          if (_usernameTaken)
            return localized.error("username_in_use");
          return null;
        },
      ));
    }

    if (widget.missingInfo.contains("name")) {
      fields.add(buildTextField(
        context,
        _nameController,
        localized.label("name"),
      ));
    }

    if (widget.missingInfo.contains("country_code")) {
      fields.add(buildDropdownField(
        context,
        localized.label("country"),
        _country,
        _countrySuggestions,
        (value) => _country = value,
      ));
    }

    return fields;
  }

  @override
  Widget build(BuildContext context) {
    final localized = DiscyoLocalizations.of(context);
    return PaletteBackground(
      colors: PaletteBackground.loginColors,
      layout: Form(
        key: _formKey,
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                      Text(localized.label("missing_info_title"),
                          style: Theme.of(context).textTheme.headline4)
                    ] +
                    _buildFields(context) +
                    <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      OutlinedButton(
                        child: Text(
                          localized.label("ok"),
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        onPressed: () => showProgress(
                          context,
                          _submit(context),
                          localized.label("loading"),
                        ),
                      ),
                    ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:discyo/components/dialogs.dart';
import 'package:discyo/components/fields.dart';
import 'package:discyo/components/header.dart';
import 'package:discyo/components/palette_background.dart';
import 'package:discyo/localizations/localizations.dart';
import 'package:discyo/utils.dart';
import 'package:flutter/material.dart';

class RegisterFormPage extends StatefulWidget {
  RegisterFormPage({
    Key? key,
    required this.dryRun,
    required this.register,
  }) : super(key: key);

  final Future<List<String>?> Function(Map<String, dynamic> info) dryRun;
  final Future<bool> Function(Map<String, dynamic> info) register;

  @override
  _RegisterFormPageState createState() => _RegisterFormPageState();
}

class _RegisterFormPageState extends State<RegisterFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _country = "";
  final _countrySuggestions = getConfigurationMap("countries");
  List<String>? _conflicts = [];

  Map<String, dynamic> _getInfo() {
    return {
      "email": _emailController.text,
      "username": _usernameController.text,
      "name": _nameController.text,
      "password": _passwordController.text,
      "country_code": _country,
      "languages": [WidgetsBinding.instance.window.locale.languageCode],
    };
  }

  Future<void> _register(BuildContext context) async {
    final localized = DiscyoLocalizations.of(context);
    _conflicts = []; // Reset conflicts
    if (_formKey.currentState?.validate() ?? false)
      _conflicts = await widget.dryRun(_getInfo());
    if (_conflicts == null) {
      _conflicts = [];
      showError(context, localized.error("unexpected"));
      return;
    }
    if (_formKey.currentState?.validate() ?? false) {
      widget.register(_getInfo()).then((registered) {
        if (registered)
          Navigator.pushNamedAndRemoveUntil(
              context, '/register_confirm', ModalRoute.withName('/'));
        else
          showError(context, localized.error("unexpected"));
      });
    }
  }

  List<Widget> _buildFields(BuildContext context) {
    final localized = DiscyoLocalizations.of(context);
    return [
      buildTextField(context, _emailController, localized.label("email"),
          validator: (value) {
        if (value?.isEmpty ?? true) return localized.error("empty_email");
        final re =
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
        if (!RegExp(re).hasMatch(value ?? ""))
          return localized.error("invalid_email");
        if (_conflicts?.contains("email") ?? false)
          return localized.error("email_in_use");
        return null;
      }),
      buildTextField(context, _usernameController, localized.label("username"),
          validator: (value) {
        if (value?.isEmpty ?? true) return localized.error("empty_username");
        final le = value?.length ?? 0;
        if (le < 3 || le > 32)
          return localized.error("invalid_username_length");
        final re = r"^[a-zA-Z0-9_-]+$";
        if (!RegExp(re).hasMatch(value ?? ""))
          return localized.error("invalid_username_characters");
        if (_conflicts?.contains("username") ?? false)
          return localized.error("username_in_use");
        return null;
      }),
      buildTextField(context, _nameController, localized.label("name")),
      buildTextField(context, _passwordController, localized.label("password"),
          obscure: true, validator: (value) {
        if (value?.isEmpty ?? true) return localized.error("empty_password");
        if ((value?.length ?? 0) < 6)
          return localized.error("invalid_password");
        return null;
      }),
      buildDropdownField(
        context,
        localized.label("country"),
        _country,
        _countrySuggestions,
        (value) => _country = value,
      ),
    ];
  }

  Widget _buildButton(BuildContext context) {
    final localized = DiscyoLocalizations.of(context);
    return OutlinedButton(
      child: Text(
        localized.label("register"),
        style: Theme.of(context).textTheme.subtitle1,
      ),
      onPressed: () => showProgress(
        context,
        _register(context),
        localized.label("loading"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PaletteBackground(
      colors: PaletteBackground.loginColors,
      layout: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: <Widget>[PageHeader()] +
                  _buildFields(context) +
                  <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    _buildButton(context),
                  ],
            ),
          ),
        ),
      ),
    );
  }
}

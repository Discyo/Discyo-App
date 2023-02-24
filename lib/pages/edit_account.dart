import 'dart:io';
import 'package:discyo/api.dart';
import 'package:discyo/components/dialogs.dart';
import 'package:discyo/components/fields.dart';
import 'package:discyo/components/header.dart';
import 'package:discyo/components/palette_background.dart';
import 'package:discyo/localizations/localizations.dart';
import 'package:discyo/models/media/medium.dart';
import 'package:discyo/models/user.dart';
import 'package:discyo/utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditAccountPage extends StatefulWidget {
  @override
  _EditAccountPageState createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  final _formKey = GlobalKey<FormState>();
  bool _imageSet = false;
  File? _image;
  bool _usernameTaken = false;
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  String _country = "";
  final _countrySuggestions = getConfigurationMap("countries");
  bool _platformsSet = false;
  Set<String> _subscribedPlatforms = {};
  Future<List<StreamingPlatform>>? _availablePlatforms;

  Future<List<StreamingPlatform>> _getAvailablePlatforms(String country) async {
    var response = await WapitchApi.getProviders(country: country);

    if (response.code != 200) {
      DiscyoApi.error(
        this.runtimeType.toString(),
        "Could not fetch streaming services in edit account! (Code ${response.code})",
      );
      return [];
    }

    return response.body
        .map<StreamingPlatform>(
            (e) => StreamingPlatformExtension.fromId(e["id"])!)
        .toList();
  }

  void _setImage(File? image) {
    setState(() {
      _imageSet = true;
      _image = image;
    });
  }

  Future<void> _saveSettings(UserModel user, BuildContext context) async {
    final localized = DiscyoLocalizations.of(context);
    _usernameTaken = false;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final availablePlatforms = await _availablePlatforms;
    final response = await user.setInfo({
      "username": _usernameController.text,
      "name": _nameController.text,
      "country_code": _country,
      "subscribed_platforms": _subscribedPlatforms
          .where((e) => availablePlatforms?.contains(e) ?? true)
          .toList(),
    });

    if (response != 201) {
      if (response == 406) {
        _usernameTaken = true;
        _formKey.currentState?.validate();
      } else {
        showError(context, localized.error("unexpected"));
      }
      return;
    }

    // If image has been set, try to set it
    if (_imageSet && !(await user.setImage(_image))) {
      showError(context, localized.error("cant_update_profile"));
    }
  }

  @override
  Widget build(BuildContext context) {
    final localized = DiscyoLocalizations.of(context);
    return Consumer<UserModel>(
      builder: (context, user, child) {
        _usernameController.text = _usernameController.text.isEmpty
            ? user.username
            : _usernameController.text;
        _nameController.text = _nameController.text.isEmpty
            ? user.name ?? ""
            : _nameController.text;
        _country = _country.isEmpty ? user.country ?? "" : _country;
        _subscribedPlatforms = _platformsSet
            ? _subscribedPlatforms
            : user.subscribedPlatforms.map<String>((e) => e.id).toSet();
        _availablePlatforms =
            _availablePlatforms ?? _getAvailablePlatforms(_country);
        return PaletteBackground(
          colors: user.colors,
          layout: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  EditPageHeader(
                    title: localized.label("edit_account"),
                    cancel: () => Navigator.of(context).pop(),
                    save: () => showProgress(
                      context,
                      _saveSettings(user, context),
                      localized.label("saving"),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _ProfileImageButton(
                            image: _imageSet
                                ? (_image == null
                                    ? AssetImage(
                                        "assets/other/missing_profile.png")
                                    : FileImage(_image!)) as ImageProvider
                                : user.image,
                            setImage: _setImage,
                          ),
                          buildTextField(context, _usernameController,
                              localized.label("username"), validator: (value) {
                            if (value?.isEmpty ?? true)
                              return localized.error("empty_username");
                            if (_usernameTaken)
                              return localized.error("username_in_use");
                            return null;
                          }),
                          buildTextField(context, _nameController,
                              localized.label("name")),
                          buildDropdownField(
                            context,
                            localized.label("country"),
                            _country,
                            _countrySuggestions,
                            (value) => setState(() {
                              _country = value;
                              _availablePlatforms =
                                  _getAvailablePlatforms(_country);
                            }),
                          ),
                          FutureBuilder(
                            future: _availablePlatforms,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData)
                                return CircularProgressIndicator();
                              return buildCheckboxSetField(
                                context,
                                localized.label("platforms"),
                                (snapshot.data as List<StreamingPlatform>)
                                    .map<Map<String, dynamic>>((e) {
                                  return {
                                    "title": e.name,
                                    "icon": e.logo,
                                    "state":
                                        _subscribedPlatforms.contains(e.id),
                                    "value": e.id,
                                  };
                                }).toList(),
                                (value) => setState(() {
                                  _platformsSet = true;
                                  _subscribedPlatforms.contains(value)
                                      ? _subscribedPlatforms.remove(value)
                                      : _subscribedPlatforms.add(value);
                                }),
                              );
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: user.hasPassword
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _ChangePasswordButton(user: user),
                                      _DeleteAccountButton(user: user),
                                    ],
                                  )
                                : Center(
                                    child: _DeleteAccountButton(user: user),
                                  ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProfileImageButton extends StatelessWidget {
  _ProfileImageButton({
    required this.image,
    required this.setImage,
    Key? key,
  }) : super(key: key);

  final ImageProvider image;
  final _picker = ImagePicker();
  final Function setImage;

  Widget _buildBottomSheetButton(
      IconData icon, String title, void Function() callback) {
    return TextButton.icon(
      onPressed: callback,
      icon: Icon(icon),
      label: Text(title),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.center,
      child: TextButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildBottomSheetButton(Icons.image, "Pick image", () async {
                  final pickedFile =
                      await _picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) setImage(File(pickedFile.path));
                  Navigator.pop(context);
                }),
                _buildBottomSheetButton(Icons.camera, "Take photo", () async {
                  final pickedFile =
                      await _picker.pickImage(source: ImageSource.camera);
                  if (pickedFile != null) setImage(File(pickedFile.path));
                  Navigator.pop(context);
                }),
                _buildBottomSheetButton(Icons.delete, "Remove image", () {
                  setImage(null);
                  Navigator.pop(context);
                })
              ],
            );
          },
        ),
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(fit: BoxFit.cover, image: image),
          ),
        ),
      ),
    );
  }
}

class _ChangePasswordButton extends StatefulWidget {
  const _ChangePasswordButton({
    required this.user,
    Key? key,
  }) : super(key: key);

  final UserModel user;

  @override
  _ChangePasswordButtonState createState() => _ChangePasswordButtonState();
}

class _ChangePasswordButtonState extends State<_ChangePasswordButton> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _wrongPassword = false;

  Future<void> _changePassword(BuildContext context) async {
    _wrongPassword = false;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (await widget.user.changePassword(
        _oldPasswordController.text, _newPasswordController.text)) {
      Navigator.pop(context);
      showMessage(
          context, DiscyoLocalizations.of(context).label("password_changed"));
    }
    _wrongPassword = true;
    _formKey.currentState?.validate(); // show the wrong password error
  }

  @override
  Widget build(BuildContext context) {
    final localized = DiscyoLocalizations.of(context);
    return OutlinedButton(
      child: Text(
        localized.label("change_password"),
        style: Theme.of(context).textTheme.subtitle1,
      ),
      onPressed: () => showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text(localized.label("change_password")),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    buildTextField(context, _oldPasswordController,
                        localized.label("current_password"), obscure: true,
                        validator: (value) {
                      if (value?.isEmpty ?? true)
                        return localized.error("empty_password");
                      if (_wrongPassword)
                        return localized.error("password_incorrect");
                      return null;
                    }),
                    buildTextField(context, _newPasswordController,
                        localized.label("new_password"), obscure: true,
                        validator: (value) {
                      if (value?.isEmpty ?? true)
                        return localized.error("empty_password");
                      if ((value?.length ?? 0) < 6)
                        return localized.error("invalid_password");
                      return null;
                    }),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    localized.label("cancel"),
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  child: Text(
                    localized.label("ok"),
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                  onPressed: () {
                    showProgress(
                      context,
                      _changePassword(context),
                      localized.label("saving"),
                    );
                  },
                ),
              ],
            );
          });
        },
      ),
    );
  }
}

class _DeleteAccountButton extends StatelessWidget {
  const _DeleteAccountButton({
    required this.user,
    Key? key,
  }) : super(key: key);

  final UserModel user;

  Future<void> _deleteAccount(BuildContext context) async {
    if (!(await user.delete()))
      showError(context, DiscyoLocalizations.of(context).error("unexpected"));
  }

  @override
  Widget build(BuildContext context) {
    final localized = DiscyoLocalizations.of(context);
    final controller = TextEditingController();
    return OutlinedButton(
      child: Text(
        localized.label("delete_account"),
        style:
            Theme.of(context).textTheme.subtitle1?.copyWith(color: Colors.red),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.red),
      ),
      onPressed: () => showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(localized.label("confirm_delete_account_title")),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(localized.label("confirm_delete_account_description")),
              TextField(controller: controller),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                localized.label("cancel"),
                style: Theme.of(context).textTheme.subtitle2,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text(
                localized.label("ok"),
                style: Theme.of(context).textTheme.subtitle2,
              ),
              onPressed: () {
                if (controller.text !=
                    localized.label("confirm_delete_account_string")) return;
                _deleteAccount(context);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

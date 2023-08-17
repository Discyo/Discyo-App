/*
 * Copyright (C) 2023  Petr Buchal, Vladimír Jeřábek, Martin Ivančo
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 */

import 'package:flutter/material.dart';
import 'package:discyo/localizations/localizations.dart';

Widget buildTextField(
    BuildContext context, TextEditingController controller, String label,
    {bool hint = false,
    bool obscure = false,
    bool? enabled,
    String? Function(String?)? validator,
    GlobalKey<FormFieldState>? key}) {
  return TextFormField(
    autofillHints: hint ? [AutofillHints.password] : null,
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      errorMaxLines: 3,
    ),
    obscureText: obscure,
    enabled: enabled,
    validator: validator ??
        (value) {
          if (value != null && value.isEmpty)
            return DiscyoLocalizations.of(context).error("empty_field") +
                " ${label.toLowerCase()}";
          return null;
        },
    key: key,
  );
}

Widget buildDropdownField(BuildContext context, String label, String value,
    Future<Map<String, String>> suggestions, Function(dynamic) setter) {
  final localized = DiscyoLocalizations.of(context);
  return FutureBuilder(
    future: suggestions,
    builder: (context, snapshot) {
      List<String> labels = snapshot.hasData
          ? (snapshot.data! as Map<String, String>).keys.toList()
          : [];
      labels.sort();
      List<DropdownMenuItem<String>> items = [
            DropdownMenuItem(
              value: "",
              child: Text(
                "${localized.label('choose')} $label...",
                style: const TextStyle(color: Colors.grey),
              ),
            )
          ] +
          labels
              .map(
                (e) => DropdownMenuItem<String>(
                  value: (snapshot.data! as Map<String, String>)[e],
                  child: Text(e),
                ),
              )
              .toList();

      return DropdownButtonFormField<String>(
        value: snapshot.hasData ? value : "",
        items: items,
        onChanged: setter,
        isExpanded: true,
        validator: (String? value) {
          if (value != null && value.isEmpty)
            return "${localized.error('empty_dropdown')} $label";
          return null;
        },
      );
    },
  );
}

Widget buildCheckboxSetField(BuildContext context, String label,
    List<Map<String, dynamic>> options, Function(dynamic) toggle,
    {bool scrollable = false}) {
  Widget list = Column(
      children: options.map<Widget>((e) {
    return CheckboxListTile(
      activeColor: Theme.of(context).colorScheme.primary,
      checkColor: Theme.of(context).colorScheme.background,
      contentPadding: const EdgeInsets.all(0),
      title: Text(e["title"]),
      secondary: Image(image: e["icon"], width: 40, height: 40),
      value: e["state"],
      onChanged: (_) => toggle(e["value"]),
    );
  }).toList());

  if (scrollable) {
    list = Expanded(child: SingleChildScrollView(child: list));
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(label,
            style: Theme.of(context).textTheme.caption!.copyWith(fontSize: 12)),
      ),
      list
    ],
  );
}

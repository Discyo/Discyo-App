import 'package:flutter/material.dart';

abstract class DiscyoLocalization {
  Map<String, String> get errors;
  Map<String, String> get labels;
  Map<String, RichText> get documents;
}
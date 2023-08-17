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

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

class PaletteBackground extends StatefulWidget {
  const PaletteBackground({
    required this.colors,
    required this.layout,
    Key? key,
  }) : super(key: key);

  static Future<List<Color>> extractGradient(ImageProvider image) async {
    PaletteGenerator palette = await PaletteGenerator.fromImageProvider(image,
        size: Size.fromWidth(50.0), maximumColorCount: 3);
    if (palette.colors.length < 1)
      return [Colors.black, Colors.black, Colors.black];

    List<Color> colors = List<Color>.from(palette.colors);
    colors.sort((a, b) => HSVColor.fromColor(a)
        .saturation
        .compareTo(HSVColor.fromColor(b).saturation));

    List<Color> gradient = [];
    HSVColor c = HSVColor.fromColor(colors[colors.length - 1]);
    c = c.withSaturation(c.saturation > 0.8 ? 0.8 : c.saturation);
    gradient.add(c.withValue(c.value > 0.3 ? 0.3 : c.value).toColor());
    c = colors.length > 1 ? HSVColor.fromColor(colors[colors.length - 2]) : c;
    c = c.withSaturation(c.saturation > 0.8 ? 0.8 : c.saturation);
    gradient.add(c.withValue(c.value > 0.3 ? 0.3 : c.value).toColor());
    c = HSVColor.fromColor(Colors.black);
    gradient.add(c.withValue(c.value * 0.15).toColor());

    return gradient;
  }

  static Future<List<Color>> extractGradientFuture(
      Future<ImageProvider> future) async {
    ImageProvider? image = await future;
    return extractGradient(image);
  }

  static Future<List<Color>> defaultColors = Future.value(
    const <Color>[Color(0xFF390303), Color(0xFF073240), Color(0xFF000000)],
  );

  static Future<List<Color>> loginColors = Future.value(
    const <Color>[Color(0xFF805700), Color(0xFF650024), Color(0xFF000000)],
  );

  final Future<List<Color>> colors;
  final Widget layout;

  @override
  _PaletteBackgroundState createState() => _PaletteBackgroundState();
}

class _PaletteBackgroundState extends State<PaletteBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Color> _currentColors = List<Color>.generate(3, (_) => Colors.black);
  late Future<List<Color>> _targetColors;

  static Animation<Color?> colorAnimation(
      AnimationController parent, Color beginColor, Color endColor) {
    return ColorTween(begin: beginColor, end: endColor)
        .animate(CurvedAnimation(parent: parent, curve: Curves.ease));
  }

  void _setTargetColors(Future<List<Color>> colors) {
    _targetColors = colors;
    _targetColors.then((_) {
      _controller.stop();
      _controller.value = 0.0;
      _controller.forward();
    });
  }

  @override
  void initState() {
    super.initState();

    _setTargetColors(widget.colors);
    _controller = AnimationController(
      duration: Duration(milliseconds: 350),
      vsync: this,
    );
    _controller.addListener(() => setState(() {}));
    _controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _targetColors
              .then((colors) => _currentColors = List<Color>.from(colors));
        });
      }
    });
  }

  @override
  void didUpdateWidget(PaletteBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    _setTargetColors(widget.colors);
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _targetColors,
      builder: (context, snapshot) {
        List<Color> colors;
        if (snapshot.hasData && _controller.status == AnimationStatus.forward)
          colors = [
            colorAnimation(_controller, _currentColors[0],
                        (snapshot.data as List<Color>)[0])
                    .value ??
                Colors.black,
            colorAnimation(_controller, _currentColors[2],
                        (snapshot.data as List<Color>)[2])
                    .value ??
                Colors.black,
            colorAnimation(_controller, _currentColors[2],
                        (snapshot.data as List<Color>)[2])
                    .value ??
                Colors.black,
            colorAnimation(_controller, _currentColors[1],
                        (snapshot.data as List<Color>)[1])
                    .value ??
                Colors.black,
          ];
        else
          colors = [
            _currentColors[0],
            _currentColors[2],
            _currentColors[2],
            _currentColors[1],
          ];

        return Container(
          decoration: BoxDecoration(
            gradient: SweepGradient(
              center: FractionalOffset(-0.4, 0.0),
              startAngle: 0.0,
              endAngle: pi / 2.0,
              stops: [0.0, 0.4, 0.6, 1.0],
              colors: colors,
              transform: GradientRotation(pi / 2.0),
            ),
          ),
          child: SafeArea(child: widget.layout),
        );
      },
    );
  }
}

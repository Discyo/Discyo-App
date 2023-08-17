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
import 'package:discyo/components/icons.dart';
import 'package:discyo/models/media.dart';

class MediaCard extends StatelessWidget {
  const MediaCard({
    required this.medium,
    this.constraints,
    this.onTap,
    Key? key,
  }) : super(key: key);

  final BoxConstraints? constraints;
  final Medium medium;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    Widget content() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              medium.title,
              style: Theme.of(context).textTheme.headline3,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: GestureDetector(
                onTap: onTap,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: medium.getImage(fit: BoxFit.contain),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                medium.genre,
                style: Theme.of(context).textTheme.headline6,
              ),
              Text(
                medium.length,
                style: Theme.of(context).textTheme.headline6,
              ),
            ],
          )
        ],
      );
    }

    if (constraints == null) return content();

    double width, height;
    if (constraints!.maxHeight > constraints!.maxWidth * 1.25) {
      width = 0.9 * constraints!.maxWidth;
      height = 1.25 * width;
    } else {
      height = 0.9 * constraints!.maxHeight;
      width = height / 1.25;
    }

    return SizedBox.fromSize(
      size: Size(width, height),
      child: content(),
    );
  }

  static Widget bottom(Medium medium, AnimationController controller) {
    return LayoutBuilder(builder: (context, constraints) {
      return Center(
        child: Opacity(
          opacity: controller.status == AnimationStatus.forward ||
                  controller.status == AnimationStatus.reverse
              ? MediaCard.fadeInAnimation(controller).value
              : 0.0,
          child: MediaCard(
            medium: medium,
            constraints: controller.status == AnimationStatus.forward ||
                    controller.status == AnimationStatus.reverse
                ? constraints * MediaCard.zoomAnimation(controller).value
                : constraints * 0.8,
          ),
        ),
      );
    });
  }

  static Widget swipeIcons(
      double opacity, int direction, AnimationController controller) {
    return LayoutBuilder(builder: (context, constraints) {
      double width, height;
      if (constraints.maxHeight > constraints.maxWidth * 1.5) {
        width = 0.8 * constraints.maxWidth;
        height = 1.5 * width;
      } else {
        height = 0.8 * constraints.maxHeight;
        width = height / 1.5;
      }

      return Align(
        alignment: Alignment.center,
        child: SizedBox.fromSize(
          size: Size(width, height),
          child: Center(
            child: Opacity(
              opacity: controller.status == AnimationStatus.forward
                  ? MediaCard.fadeOutAnimation(controller).value
                  : 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Opacity(
                    opacity: direction == 1 ? opacity : 0.0,
                    child: Icon(DiscyoIcons.save, size: 0.15 * width),
                  ),
                  Opacity(
                    opacity: direction == 2 ? opacity : 0.0,
                    child: Icon(DiscyoIcons.dismiss, size: 0.15 * width),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  static Widget top(Medium medium, AnimationController controller,
      Alignment alignment, int duration, void Function()? onTap) {
    return LayoutBuilder(builder: (context, constraints) {
      if (controller.status == AnimationStatus.forward ||
          controller.status == AnimationStatus.reverse)
        return Align(
          alignment: MediaCard.flyAnimation(controller, alignment).value,
          child: MediaCard(medium: medium, constraints: constraints),
        );
      else
        return AnimatedAlign(
          alignment: alignment,
          duration: Duration(milliseconds: duration),
          child: MediaCard(
            medium: medium,
            constraints: constraints,
            onTap: onTap,
          ),
        );
    });
  }

  static Animation<double> zoomAnimation(AnimationController parent) {
    return Tween<double>(begin: 0.8, end: 1).animate(CurvedAnimation(
      parent: parent,
      curve: Interval(0, 1, curve: Curves.ease),
    ));
  }

  static Animation<double> fadeInAnimation(AnimationController parent) {
    return Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: parent,
      curve: Interval(0, 1, curve: Curves.ease),
    ));
  }

  static Animation<double> fadeOutAnimation(AnimationController parent) {
    return Tween<double>(begin: 1, end: 0).animate(CurvedAnimation(
      parent: parent,
      curve: Interval(0, 1, curve: Curves.ease),
    ));
  }

  static Animation<Alignment> flyAnimation(
      AnimationController parent, Alignment beginAlign) {
    Alignment endAlign;
    if (beginAlign.x != 0.0)
      endAlign = Alignment(
        beginAlign.x > 0.0 ? 20.0 : -20.0,
        0,
      );
    else
      endAlign = Alignment(
        0.0,
        beginAlign.y > 0.0 ? 20.0 : -20.0,
      );
    return AlignmentTween(begin: beginAlign, end: endAlign).animate(
      CurvedAnimation(
        parent: parent,
        curve: Interval(0, 0.8, curve: Curves.easeIn),
      ),
    );
  }
}

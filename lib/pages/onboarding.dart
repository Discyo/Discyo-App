import 'dart:math';
import 'package:flutter/material.dart';
import 'package:discyo/components/card.dart';
import 'package:discyo/components/icons.dart';
import 'package:discyo/components/palette_background.dart';
import 'package:discyo/localizations/localizations.dart';
import 'package:discyo/models/media.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({
    required this.onboardUser,
    Key? key,
  }) : super(key: key);

  final void Function() onboardUser;

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  List<Future<Medium>> _media = [
    Film.fetchTMDB("866a5b4b-ff15-4897-8371-754820d8b047", 577922),
    Film.fetchTMDB("d9515aeb-3ec3-4786-921e-efe6d23e7067", 398818),
    Film.fetchTMDB("1e235da2-e9e4-4d22-988b-86ab7bc573d7", 389015),
    Film.fetchTMDB("33325c0d-af04-40cf-a76b-63ba663803a3", 426426),
  ];
  int _index = 1;

  void _nextSlide() {
    setState(() => _index += 1);
  }

  Future<List<Color>> _getColors() async {
    if (_index == 1) return PaletteBackground.defaultColors;
    if (_index == 2) return PaletteBackground.defaultColors;
    if (_index == 3) return (await _media[0]).colors;
    if (_index == 4) return (await _media[1]).colors;
    if (_index == 5) return (await _media[2]).colors;
    if (_index == 6) return (await _media[3]).colors;
    if (_index == 7) return (await _media[2]).colors;
    if (_index == 8) return PaletteBackground.defaultColors;
    return PaletteBackground.defaultColors;
  }

  Future<Widget> _buildLayout(DiscyoLocalizations localized) async {
    if (_index == 1)
      return _TextSlide(
        title: localized.label("onboarding_welcome"),
        nextSlide: _nextSlide,
        key: Key("onboarding_text_1"),
      );
    if (_index == 2)
      return _TextSlide(
        title: localized.label("onboarding_gestures"),
        subtitle: localized.label("onboarding_ratings"),
        nextSlide: _nextSlide,
        key: Key("onboarding_text_2"),
      );
    if (_index == 3)
      return _MediaSlide(
        medium: await _media[0],
        nextMedium: await _media[1],
        text: localized.label("onboarding_swipe_right"),
        action: MediaAction.save,
        nextSlide: _nextSlide,
      );
    if (_index == 4)
      return _MediaSlide(
        medium: await _media[1],
        nextMedium: await _media[2],
        text: localized.label("onboarding_swipe_left"),
        action: MediaAction.dismiss,
        nextSlide: _nextSlide,
      );
    if (_index == 5)
      return _MediaSlide(
        medium: await _media[2],
        nextMedium: await _media[3],
        text: localized.label("onboarding_rate"),
        action: MediaAction.rate,
        nextSlide: _nextSlide,
      );
    if (_index == 6)
      return _MediaSlide(
        medium: await _media[2],
        nextMedium: await _media[3],
        text: localized.label("onboarding_rewind"),
        action: MediaAction.rewind,
        nextSlide: _nextSlide,
      );
    if (_index == 7)
      return _CategorySlide(
        medium: await _media[2],
        nextSlide: _nextSlide,
      );
    if (_index == 8)
      return _TextSlide(
        title: localized.label("onboarding_finish"),
        nextSlide: widget.onboardUser,
        key: Key("onboarding_text_3"),
      );
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return PaletteBackground(
      colors: _getColors(),
      layout: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: _buildLayout(DiscyoLocalizations.of(context)),
              builder: (context, snapshot) {
                if (snapshot.hasData)
                  return snapshot.data as Widget;
                else
                  return Center(child: CircularProgressIndicator());
              },
            ),
          ),
          TextButton(
            child: Text(
              DiscyoLocalizations.of(context).label("skip"),
              style: Theme.of(context).textTheme.subtitle1,
            ),
            onPressed: widget.onboardUser,
          ),
        ],
      ),
    );
  }
}

class _TextSlide extends StatefulWidget {
  const _TextSlide({
    required this.title,
    this.subtitle,
    required this.nextSlide,
    Key? key,
  }) : super(key: key);

  final String title;
  final String? subtitle;
  final Function nextSlide;

  @override
  _TextSlideState createState() => _TextSlideState();
}

class _TextSlideState extends State<_TextSlide> {
  double _opacity = 0;

  void animate() {
    Future.delayed(const Duration(milliseconds: 500))
        .then((_) => setState(() => _opacity = 1));
    Future.delayed(const Duration(milliseconds: 4000))
        .then((_) => setState(() => _opacity = 0));
    Future.delayed(const Duration(milliseconds: 5000))
        .then((_) => widget.nextSlide());
  }

  @override
  void initState() {
    super.initState();
    animate();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(seconds: 1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline2,
            ),
            widget.subtitle == null
                ? Container()
                : Text(
                    widget.subtitle!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline5,
                  ),
          ],
        ),
      ),
    );
  }
}

class _MediaSlide extends StatefulWidget {
  const _MediaSlide({
    required this.medium,
    this.nextMedium,
    this.text,
    this.action,
    required this.nextSlide,
    Key? key,
  }) : super(key: key);

  final Medium medium;
  final Medium? nextMedium;
  final String? text;
  final MediaAction? action;
  final Function nextSlide;

  @override
  _MediaSlideState createState() => _MediaSlideState();
}

class _MediaSlideState extends State<_MediaSlide>
    with SingleTickerProviderStateMixin {
  final Duration _ratingButtonsRevealDuration = Duration(milliseconds: 400);
  late AnimationController _controller;
  Alignment _frontCardAlignment = Alignment.center;
  int _alignmentDuration = 0; // miliseconds for AnimatedAlignment
  double _textOpacity = 0;
  bool _ratingButtonsShown = false;
  bool _inBetween = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _controller.addListener(() => setState(() {}));
    _controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _inBetween = true;
          _frontCardAlignment = Alignment.center;
          _alignmentDuration = 0;
        });
        widget.nextSlide();
      }
    });
    Future.delayed(const Duration(milliseconds: 100))
        .then((_) => setState(() => _textOpacity = 1));
  }

  @override
  void didUpdateWidget(covariant _MediaSlide oldWidget) {
    super.didUpdateWidget(oldWidget);
    _inBetween = false;
  }

  void _toggleRatingButtons() {
    setState(() => _ratingButtonsShown = !_ratingButtonsShown);
  }

  void _rewind() {
    _frontCardAlignment = Alignment(0, -0.001);
    _controller.stop();
    _controller.reverse();
    Future.delayed(const Duration(seconds: 1)).then((_) => widget.nextSlide());
  }

  void _rate() {
    _toggleRatingButtons();
    setState(() => _frontCardAlignment = Alignment(0, -0.001));
    _controller.stop();
    _controller.value = 0;
    _controller.forward();
  }

  Widget _gestureDetector() {
    void onPanUpdate(DragUpdateDetails details) {
      setState(() {
        _alignmentDuration = 0;
        _frontCardAlignment = Alignment(
            _frontCardAlignment.x +
                4 * details.delta.dx / MediaQuery.of(context).size.width,
            _frontCardAlignment.y);
      });
    }

    void onPandEnd(DragEndDetails _) {
      // If the correct gesture has been done, animate
      if ((widget.action == MediaAction.save && _frontCardAlignment.x > 1) ||
          (widget.action == MediaAction.dismiss &&
              _frontCardAlignment.x < -1)) {
        _controller.stop();
        _controller.value = 0;
        _controller.forward();
      }
      // otherwise return card back
      else {
        setState(() {
          _frontCardAlignment = Alignment.center;
          _alignmentDuration = 300;
        });
      }
    }

    // If animation is under way, gesture detector must be unavailable
    if (_controller.status == AnimationStatus.forward) return Container();

    // The gesture dector should fill the entire space of RecommenderView
    return SizedBox.expand(
      child: GestureDetector(
        onPanUpdate: onPanUpdate,
        onPanEnd: onPandEnd,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(padding: const EdgeInsets.symmetric(vertical: 8)),
        SizedBox(
          height: (Theme.of(context).textTheme.headline3?.fontSize ?? 24) * 2.5,
          width: double.infinity,
          child: AnimatedOpacity(
            duration: const Duration(seconds: 1),
            opacity: _textOpacity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                widget.text ?? "",
                style: Theme.of(context).textTheme.headline3,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        Expanded(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              MediaCard.swipeIcons(min(_frontCardAlignment.x.abs(), 1),
                  _frontCardAlignment.x > 0 ? 1 : 2, _controller),
              widget.nextMedium == null
                  ? Container()
                  : MediaCard.bottom(widget.nextMedium!, _controller),
              MediaCard.top(
                widget.action == MediaAction.rewind &&
                            _controller.status == AnimationStatus.completed ||
                        _inBetween
                    ? widget.nextMedium!
                    : widget.medium,
                _controller,
                _frontCardAlignment,
                _alignmentDuration,
                null,
              ),
              _gestureDetector(),
              Positioned(
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  duration: _ratingButtonsRevealDuration,
                  opacity: _ratingButtonsShown ? 1 : 0,
                  child: AnimatedAlign(
                    duration: _ratingButtonsRevealDuration,
                    alignment: _ratingButtonsShown
                        ? Alignment.bottomCenter
                        : Alignment(0.25, 1),
                    child: AnimatedContainer(
                        duration: _ratingButtonsRevealDuration,
                        width: _ratingButtonsShown ? 240 : 0,
                        height: _ratingButtonsShown ? 48 : 0,
                        child: _RatingButtons(nextSlide: _rate)),
                  ),
                ),
              ),
            ],
          ),
        ),
        AnimatedOpacity(
          duration: _ratingButtonsRevealDuration,
          opacity: _ratingButtonsShown ? 0.5 : 1,
          child: widget.action == MediaAction.rate ||
                  widget.action == MediaAction.rewind
              ? _ActionButtons(
                  action: widget.action,
                  rate: _toggleRatingButtons,
                  rewind: _rewind,
                )
              : SizedBox(height: 48),
        ),
        Padding(padding: const EdgeInsets.symmetric(vertical: 8)),
      ],
    );
  }
}

class _RatingButtons extends StatelessWidget {
  const _RatingButtons({
    required this.nextSlide,
    Key? key,
  }) : super(key: key);

  final Function nextSlide;

  @override
  Widget build(BuildContext context) {
    Widget _buildButton(MediaAction action) {
      return ConstrainedBox(
        constraints: BoxConstraints.loose(Size(48, 48)),
        child: FittedBox(
          fit: BoxFit.fill,
          child: IconButton(
            icon: Icon(action.icon, size: 32),
            color: Theme.of(context).accentColor,
            onPressed: () => nextSlide(),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        color: Colors.grey[900],
        child: ClipRect(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              _buildButton(MediaAction.rateAwful),
              _buildButton(MediaAction.rateMeh),
              _buildButton(MediaAction.rateGood),
              _buildButton(MediaAction.rateAwesome),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.action,
    required this.rate,
    required this.rewind,
    Key? key,
  }) : super(key: key);

  final MediaAction? action;
  final Function() rate;
  final Function() rewind;

  @override
  Widget build(BuildContext context) {
    Widget _buildButton(MediaAction action, Function()? callback) {
      return IconButton(
        icon: Icon(action.icon, size: 32),
        color: Theme.of(context).accentColor,
        onPressed: callback,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _buildButton(
          MediaAction.rewind,
          action == MediaAction.rewind ? rewind : null,
        ),
        _buildButton(MediaAction.dismiss, null),
        _buildButton(
          MediaAction.rate,
          action == MediaAction.rate ? rate : null,
        ),
        _buildButton(MediaAction.save, null),
      ],
    );
  }
}

class _CategorySlide extends StatefulWidget {
  const _CategorySlide({
    required this.medium,
    required this.nextSlide,
    Key? key,
  }) : super(key: key);

  final Medium medium;
  final Function nextSlide;

  @override
  _CategorySlideState createState() => _CategorySlideState();
}

class _CategorySlideState extends State<_CategorySlide> {
  double _opacity = 0;
  Type _mediaType = Film;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500))
        .then((_) => setState(() => _opacity = 1));
  }

  void _toggle(Type mediaType) {
    setState(() {
      _mediaType = mediaType;
      _opacity = 0;
    });
    Future.delayed(const Duration(seconds: 1)).then((_) => widget.nextSlide());
  }

  Widget _buildCategorySelectors(BuildContext context) {
    Widget _buildButton(Type mediaType) {
      final icon = DiscyoIcons.medium(mediaType, mediaType == _mediaType);
      return IconButton(
        icon: Icon(icon, size: 32),
        onPressed: () => _toggle(mediaType),
        color: Theme.of(context).accentColor,
      );
    }

    return ClipRect(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List<Widget>.generate(
          mediaTypes.length,
          (i) => _buildButton(mediaTypes[i]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(seconds: 1),
      opacity: _opacity,
      child: Column(
        children: <Widget>[
          Padding(padding: const EdgeInsets.symmetric(vertical: 8)),
          _buildCategorySelectors(context),
          Expanded(
            child: LayoutBuilder(builder: (context, constraints) {
              return Center(
                child:
                    MediaCard(medium: widget.medium, constraints: constraints),
              );
            }),
          ),
          SizedBox(
            height: 48,
            child: Center(
              child: Text(
                DiscyoLocalizations.of(context).label("onboarding_selectors"),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
          ),
          Padding(padding: const EdgeInsets.symmetric(vertical: 8)),
        ],
      ),
    );
  }
}

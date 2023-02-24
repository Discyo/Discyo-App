import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:discyo/components/card.dart';
import 'package:discyo/components/dialogs.dart';
import 'package:discyo/components/icons.dart';
import 'package:discyo/components/palette_background.dart';
import 'package:discyo/localizations/localizations.dart';
import 'package:discyo/models/media.dart';
import 'package:discyo/models/recommender.dart';
import 'package:discyo/models/user.dart';

class DiscoverPage extends StatefulWidget {
  static Future<void> _showToasts(BuildContext context, UserModel user) async {
    final localized = DiscyoLocalizations.of(context);
    if (await user.shouldShowNotification("log", 1))
      showMessage(context, localized.label("log_movie_toast"));
    if (await user.shouldShowNotification("rate", 3)) {
      showActionMessage(
        context,
        localized.label("feedback_toast"),
        localized.label("rate"),
        () => showFeedbackForm(context, user),
      );
    }
  }

  static Widget _buildInitButton(
      BuildContext context, RecommenderModel recommender) {
    final localized = DiscyoLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            localized.label("needs_init"),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline6,
          ),
          Padding(padding: const EdgeInsets.symmetric(vertical: 16.0)),
          OutlinedButton(
            onPressed: () => Navigator.pushNamed(
              context,
              "/init_favorites",
              arguments: recommender.mediaType,
            ).then((_) => recommender.reload()),
            child: Text(
              localized.label("do_init"),
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _loading(BuildContext context, Type mediaType) {
    if (mediaType == Film || mediaType == Show)
      return Center(child: CircularProgressIndicator());
    String? label;
    if (mediaType == Album)
      label = DiscyoLocalizations.of(context).error("albums_unsupported");
    if (mediaType == Podcast)
      label = DiscyoLocalizations.of(context).error("podcasts_unsupported");
    if (mediaType == Book)
      label = DiscyoLocalizations.of(context).error("books_unsupported");
    if (mediaType == Game)
      label = DiscyoLocalizations.of(context).error("games_unsupported");
    return Center(
      child: Text(
        label ?? "",
        style: Theme.of(context).textTheme.bodyText1,
      ),
    );
  }

  @override
  _DiscoverPageState createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final Duration _ratingButtonsRevealDuration = Duration(milliseconds: 200);
  final _ActionNotifier _actionNotifier = _ActionNotifier();
  bool _ratingButtonsShown = false;

  void _toggleRatingButtons() {
    setState(() => _ratingButtonsShown = !_ratingButtonsShown);
  }

  Widget _buildRecommender(BuildContext context, RecommenderModel recommender) {
    if (recommender.needsInit)
      return DiscoverPage._buildInitButton(context, recommender);
    if (recommender.length < 1)
      return DiscoverPage._loading(context, recommender.mediaType);
    return _RecommenderView(
      recommender: recommender,
      hideRatingButtons: () {
        if (_ratingButtonsShown) _toggleRatingButtons();
      },
      actionNotifier: _actionNotifier,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (context, user, child) {
        DiscoverPage._showToasts(context, user);
        return ChangeNotifierProvider(
          create: (_) => RecommenderModel(user),
          child: Consumer<RecommenderModel>(
            builder: (context, recommender, child) {
              void _perform(MediaAction action) {
                switch (action) {
                  case MediaAction.rate:
                    _toggleRatingButtons();
                    return;
                  case MediaAction.rateAwful:
                    recommender.setMediaState(MediaState.awful);
                    break;
                  case MediaAction.rateMeh:
                    recommender.setMediaState(MediaState.meh);
                    break;
                  case MediaAction.rateGood:
                    recommender.setMediaState(MediaState.good);
                    break;
                  case MediaAction.rateAwesome:
                    recommender.setMediaState(MediaState.awesome);
                    break;
                  case MediaAction.dismiss:
                    if (_ratingButtonsShown) return _toggleRatingButtons();
                    recommender.setMediaState(MediaState.dismissed);
                    break;
                  case MediaAction.save:
                    if (_ratingButtonsShown) return _toggleRatingButtons();
                    recommender.setMediaState(MediaState.saved);
                    break;
                  case MediaAction.rewind:
                    if (_ratingButtonsShown) return _toggleRatingButtons();
                    break;
                  case MediaAction.share:
                    // Should never happen
                    return;
                }
                if (_ratingButtonsShown) _toggleRatingButtons();
                _actionNotifier.setAction(action);
              }

              return PaletteBackground(
                colors: recommender.length < 1
                    ? PaletteBackground.defaultColors
                    : recommender.current.colors,
                layout: Column(
                  children: <Widget>[
                    Padding(padding: const EdgeInsets.symmetric(vertical: 8.0)),
                    _CategorySelector(
                      selected: recommender.mediaType,
                      toggle: (Type type) {
                        if (_ratingButtonsShown) _toggleRatingButtons();
                        recommender.toggle(type);
                      },
                    ),
                    Expanded(
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          _buildRecommender(context, recommender),
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
                                    child: _RatingButtons(perform: _perform)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedOpacity(
                      duration: _ratingButtonsRevealDuration,
                      opacity: _ratingButtonsShown ? 0.5 : 1,
                      child: _ActionButtons(
                        perform: _perform,
                        rewindDisabled: !recommender.canRewind,
                      ),
                    ),
                    Padding(padding: const EdgeInsets.symmetric(vertical: 8.0)),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _CategorySelector extends StatelessWidget {
  const _CategorySelector({
    required this.selected,
    required this.toggle,
    Key? key,
  }) : super(key: key);

  final Type selected;
  final void Function(Type type) toggle;

  Widget _buildButton(BuildContext context, Type category) {
    final icon = DiscyoIcons.medium(category, category == selected);
    return IconButton(
      icon: Icon(icon, size: 32),
      onPressed:
          category == Film || category == Show ? () => toggle(category) : null,
      color: category == Film || category == Show
          ? Theme.of(context).accentColor
          : Theme.of(context).primaryColorLight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(
        mediaTypes.length,
        (i) => _buildButton(context, mediaTypes[i]),
      ),
    );
  }
}

class _RatingButtons extends StatelessWidget {
  const _RatingButtons({
    required this.perform,
    Key? key,
  }) : super(key: key);

  final void Function(MediaAction) perform;

  Widget _buildButton(BuildContext context, MediaAction action) {
    return ConstrainedBox(
      constraints: BoxConstraints.loose(Size(48, 48)),
      child: FittedBox(
        fit: BoxFit.fill,
        child: IconButton(
          icon: Icon(action.icon, size: 32),
          color: Theme.of(context).accentColor,
          onPressed: () => perform(action),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        color: Colors.grey[900],
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _buildButton(context, MediaAction.rateAwful),
            _buildButton(context, MediaAction.rateMeh),
            _buildButton(context, MediaAction.rateGood),
            _buildButton(context, MediaAction.rateAwesome),
          ],
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.perform,
    this.rewindDisabled = false,
    Key? key,
  }) : super(key: key);

  final Function(MediaAction) perform;
  final bool rewindDisabled;

  Widget _buildButton(BuildContext context, MediaAction action) {
    return IconButton(
      icon: Icon(action.icon, size: 32),
      color: Theme.of(context).accentColor,
      onPressed: action == MediaAction.rewind && rewindDisabled
          ? null
          : () => perform(action),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _buildButton(context, MediaAction.rewind),
        _buildButton(context, MediaAction.dismiss),
        _buildButton(context, MediaAction.rate),
        _buildButton(context, MediaAction.save),
      ],
    );
  }
}

class _RecommenderView extends StatefulWidget {
  const _RecommenderView({
    required this.recommender,
    required this.hideRatingButtons,
    this.actionNotifier,
    Key? key,
  }) : super(key: key);

  final RecommenderModel recommender;
  final void Function() hideRatingButtons;
  final _ActionNotifier? actionNotifier;

  @override
  _RecommenderViewState createState() => _RecommenderViewState();
}

class _RecommenderViewState extends State<_RecommenderView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Alignment _frontCardAlignment = Alignment.center;
  int _alignmentDuration = 0; // miliseconds for AnimatedAlignment

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _controller.addListener(() => setState(() {}));
    _controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          widget.recommender.advance();
          _frontCardAlignment = Alignment.center;
          _alignmentDuration = 0;
        });
      }
    });
    widget.actionNotifier?.addActionListener(_performAction);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _performAction(MediaAction action) {
    // If action is under way, do nothing
    if (_controller.status == AnimationStatus.forward ||
        _controller.status == AnimationStatus.reverse) return;

    if (action == MediaAction.rewind) {
      final previous = widget.recommender.rewind();
      if (previous == null) return;
      setState(() {
        if (previous == MediaState.dismissed)
          _frontCardAlignment = Alignment(-0.001, 0.0);
        else if (previous == MediaState.saved)
          _frontCardAlignment = Alignment(0.001, 0.0);
        else
          _frontCardAlignment = Alignment(0.0, -0.001);
      });
      _controller.stop();
      _controller.reverse();
      return;
    }
    if (action == MediaAction.dismiss)
      setState(() => _frontCardAlignment = Alignment(-0.001, 0.0));
    if (action == MediaAction.save)
      setState(() => _frontCardAlignment = Alignment(0.001, 0.0));
    if (action == MediaAction.rateAwful ||
        action == MediaAction.rateMeh ||
        action == MediaAction.rateGood ||
        action == MediaAction.rateAwesome)
      setState(() => _frontCardAlignment = Alignment(0.0, -0.001));
    _controller.stop();
    _controller.value = 0.0;
    _controller.forward();
  }

  Widget _buildGestureDetector() {
    void _onPanUpdate(DragUpdateDetails details) {
      setState(() {
        _alignmentDuration = 0;
        _frontCardAlignment = Alignment(
            _frontCardAlignment.x +
                4.0 * details.delta.dx / MediaQuery.of(context).size.width,
            _frontCardAlignment.y);
      });
    }

    void _onPandEnd(DragEndDetails _) {
      // If past certain threshold, start card switch animation
      if (_frontCardAlignment.x.abs() > 1.0) {
        if (_frontCardAlignment.x > 1.0)
          widget.recommender.setMediaState(MediaState.saved);
        if (_frontCardAlignment.x < -1.0)
          widget.recommender.setMediaState(MediaState.dismissed);
        _controller.stop();
        _controller.value = 0.0;
        _controller.forward();
      }
      // Else return the card back to center
      else {
        setState(() {
          _alignmentDuration = 300;
          _frontCardAlignment = Alignment.center;
        });
      }
    }

    // If animation is under way, gesture detector must be unavailable
    if (_controller.status == AnimationStatus.forward ||
        _controller.status == AnimationStatus.reverse) return Container();

    // The gesture dector should fill the entire space of RecommenderView
    return SizedBox.expand(
      child: GestureDetector(
        onPanStart: (_) => widget.hideRatingButtons(),
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPandEnd,
      ),
    );
  }

  Widget _buildTopCard() {
    void _onTap() async {
      widget.hideRatingButtons();
      // Open detail page of the current medium
      await Navigator.pushNamed(
        context,
        "/details",
        arguments: widget.recommender.current,
      );
      // Check if state has been set
      if (widget.recommender.current.state != null)
        widget.recommender.advance();
    }

    return MediaCard.top(
      widget.recommender.current,
      _controller,
      _frontCardAlignment,
      _alignmentDuration,
      _onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        MediaCard.swipeIcons(
          min(_frontCardAlignment.x.abs(), 1),
          _frontCardAlignment.x > 0 ? 1 : 2,
          _controller,
        ),
        widget.recommender.length < 2
            ? Container()
            : MediaCard.bottom(widget.recommender.next, _controller),
        _buildTopCard(),
        _buildGestureDetector(),
      ],
    );
  }
}

class _ActionNotifier extends ChangeNotifier {
  MediaAction? _action;

  void setAction(MediaAction a) {
    _action = a;
    notifyListeners();
  }

  void addActionListener(void Function(MediaAction) listener) {
    addListener(() => listener(_action!));
  }
}

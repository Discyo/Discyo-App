import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:discyo/api.dart';
import 'package:discyo/components/dialogs.dart';
import 'package:discyo/components/header.dart';
import 'package:discyo/components/icons.dart';
import 'package:discyo/components/palette_background.dart';
import 'package:discyo/localizations/localizations.dart';
import 'package:discyo/models/media.dart';
import 'package:discyo/models/user.dart';
import 'package:discyo/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tmdb_dart/tmdb_dart.dart';

class DetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Medium medium = ModalRoute.of(context)?.settings.arguments as Medium;

    return PaletteBackground(
      colors: medium.colors,
      layout: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: PageHeader(),
          ),
          Expanded(
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment(0, -0.9),
                  colors: [Colors.transparent, Colors.black],
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstIn,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 24),
                        child: _DetailsHeader(medium: medium),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _DetailsBody(medium: medium),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 24),
                        child: _DetailsFooter(medium: medium),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _DetailsHeader extends StatefulWidget {
  const _DetailsHeader({
    required this.medium,
    Key? key,
  }) : super(key: key);

  final Medium medium;

  Widget _buildVideoButton(BuildContext context) {
    if ((medium is Podcast) || (medium is Book)) return Container();
    if ((medium is Film) && (medium as Film).trailerUrls.isEmpty)
      return Container();
    if ((medium is Show) && (medium as Show).trailerUrls.isEmpty)
      return Container();

    final localized = DiscyoLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: OutlinedButton.icon(
        icon: Icon(DiscyoIcons.play, size: 20),
        label: Text(
          medium is Album
              ? localized.label("video")
              : localized.label("trailer"),
          style: Theme.of(context).textTheme.bodyText1,
        ),
        onPressed: () {
          if (medium is Film)
            openLink((medium as Film).trailerUrls[0], context);
          if (medium is Show)
            openLink((medium as Show).trailerUrls[0], context);
          if (medium is Album)
            openLink((medium as Album).videoUrls[0], context);
          if (medium is Game)
            openLink((medium as Game).trailerUrls[0], context);
        },
      ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          medium.title,
          style: Theme.of(context).textTheme.headline4,
          overflow: TextOverflow.ellipsis,
          maxLines: 3,
        ),
        Padding(padding: const EdgeInsets.symmetric(vertical: 4)),
        Text(
          medium.headline,
          style: Theme.of(context).textTheme.bodyText1,
        ),
        Text(
          medium.genre,
          style: Theme.of(context).textTheme.bodyText1,
        ),
        Padding(padding: const EdgeInsets.symmetric(vertical: 4)),
        Text(
          medium.creator(DiscyoLocalizations.of(context)),
          style: Theme.of(context).textTheme.subtitle2,
        ),
        Padding(padding: const EdgeInsets.symmetric(vertical: 4)),
        _buildVideoButton(context),
      ],
    );
  }

  Widget _buildPoster(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: medium.getImage(fit: BoxFit.contain),
      ),
    );
  }

  @override
  _DetailsHeaderState createState() => _DetailsHeaderState();
}

class _DetailsHeaderState extends State<_DetailsHeader> {
  final Duration _ratingButtonsRevealDuration = Duration(milliseconds: 200);
  bool _ratingButtonsShown = false;

  void _toggleRatingButtons() {
    setState(() => _ratingButtonsShown = !_ratingButtonsShown);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(builder: (context, user, child) {
      void _perform(MediaAction action) {
        switch (action) {
          case MediaAction.rate:
            _toggleRatingButtons();
            return;
          case MediaAction.rateAwful:
            user
                .setMediaState(
                  widget.medium,
                  widget.medium.state == MediaState.awful
                      ? null
                      : MediaState.awful,
                )
                .then((_) => setState(() {}));
            break;
          case MediaAction.rateMeh:
            user
                .setMediaState(
                  widget.medium,
                  widget.medium.state == MediaState.meh ? null : MediaState.meh,
                )
                .then((_) => setState(() {}));
            break;
          case MediaAction.rateGood:
            user
                .setMediaState(
                  widget.medium,
                  widget.medium.state == MediaState.good
                      ? null
                      : MediaState.good,
                )
                .then((_) => setState(() {}));
            break;
          case MediaAction.rateAwesome:
            user
                .setMediaState(
                  widget.medium,
                  widget.medium.state == MediaState.awesome
                      ? null
                      : MediaState.awesome,
                )
                .then((_) => setState(() {}));
            break;
          case MediaAction.dismiss:
            // Should never happen
            return;
          case MediaAction.save:
            if (_ratingButtonsShown) return _toggleRatingButtons();
            user
                .setMediaState(
                  widget.medium,
                  widget.medium.state == MediaState.saved
                      ? null
                      : MediaState.saved,
                )
                .then((_) => setState(() {}));
            break;
          case MediaAction.rewind:
            // Should never happen
            return;
          case MediaAction.share:
            if (_ratingButtonsShown) return _toggleRatingButtons();
            Share.share(DiscyoWeb.shareUrl(
              widget.medium.runtimeType,
              widget.medium.id,
              user.country,
            ));
            return;
        }
        if (_ratingButtonsShown) _toggleRatingButtons();
      }

      return Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: widget._buildPoster(context),
                    flex: 2,
                  ),
                  Expanded(
                    child: widget._buildInfo(context),
                    flex: 3,
                  ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  duration: _ratingButtonsRevealDuration,
                  opacity: _ratingButtonsShown ? 1 : 0,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: AnimatedContainer(
                      duration: _ratingButtonsRevealDuration,
                      width: _ratingButtonsShown ? 240 : 0,
                      height: _ratingButtonsShown ? 48 : 0,
                      child: _RatingButtons(
                        perform: _perform,
                        mediaState: widget.medium.state,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(padding: const EdgeInsets.symmetric(vertical: 4)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _RatingGraph(
                    histogram: widget.medium.getRatings(),
                    mediaState: widget.medium.state,
                  ),
                ),
                flex: 2,
              ),
              Expanded(
                child: AnimatedOpacity(
                  duration: _ratingButtonsRevealDuration,
                  opacity: _ratingButtonsShown ? 0.5 : 1,
                  child: _ActionButtons(
                    perform: _perform,
                    mediaState: widget.medium.state,
                  ),
                ),
                flex: 3,
              ),
            ],
          )
        ],
      );
    });
  }
}

class _RatingButtons extends StatelessWidget {
  const _RatingButtons({
    required this.perform,
    this.mediaState,
    Key? key,
  }) : super(key: key);

  final Function(MediaAction) perform;
  final MediaState? mediaState;

  @override
  Widget build(BuildContext context) {
    Widget _buildButton(MediaAction action) {
      return ConstrainedBox(
        constraints: BoxConstraints.loose(Size(48, 48)),
        child: FittedBox(
          fit: BoxFit.fill,
          child: Container(
            decoration: ShapeDecoration(
              color: mediaState?.isResultOfAction(action) ?? false
                  ? Theme.of(context).accentColor
                  : Colors.transparent,
              shape: CircleBorder(),
            ),
            child: IconButton(
              icon: Icon(action.icon, size: 32),
              color: mediaState?.isResultOfAction(action) ?? false
                  ? Theme.of(context).primaryColorDark
                  : Theme.of(context).accentColor,
              onPressed: () => perform(action),
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        color: Colors.grey[900],
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _buildButton(MediaAction.rateAwful),
            _buildButton(MediaAction.rateMeh),
            _buildButton(MediaAction.rateGood),
            _buildButton(MediaAction.rateAwesome),
          ],
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.perform,
    this.mediaState,
    Key? key,
  }) : super(key: key);

  final Function(MediaAction) perform;
  final MediaState? mediaState;

  @override
  Widget build(BuildContext context) {
    Widget _buildButton(IconData icon, bool selected, MediaAction action) {
      return Container(
        decoration: ShapeDecoration(
          color: selected ? Theme.of(context).accentColor : Colors.transparent,
          shape: CircleBorder(),
        ),
        child: IconButton(
          icon: Icon(icon, size: 32),
          color: selected
              ? Theme.of(context).primaryColorDark
              : Theme.of(context).accentColor,
          onPressed: () => perform(action),
        ),
      );
    }

    IconData ratingIcon;
    switch (mediaState) {
      case MediaState.awful:
      case MediaState.meh:
      case MediaState.good:
      case MediaState.awesome:
        ratingIcon = mediaState!.icon;
        break;
      default:
        ratingIcon = DiscyoIcons.rate;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _buildButton(
          ratingIcon,
          ratingIcon != DiscyoIcons.rate,
          MediaAction.rate,
        ),
        _buildButton(
          MediaAction.save.icon,
          mediaState == MediaState.saved,
          MediaAction.save,
        ),
        _buildButton(
          MediaAction.share.icon,
          false,
          MediaAction.share,
        ),
      ],
    );
  }
}

class _RatingGraph extends StatelessWidget {
  const _RatingGraph({
    required this.histogram,
    this.mediaState,
    Key? key,
  }) : super(key: key);

  final Future<List<int>?> histogram;
  final MediaState? mediaState;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final deselectedColor = charts.Color(
      r: t.primaryColorLight.red,
      g: t.primaryColorLight.green,
      b: t.primaryColorLight.blue,
    );
    final selectedColor = charts.Color(
      r: t.accentColor.red,
      g: t.accentColor.green,
      b: t.accentColor.blue,
    );

    charts.Series<double, String> _buildBar(double value, bool selected) {
      return charts.Series<double, String>(
        id: '0',
        colorFn: (_, __) => selected ? selectedColor : deselectedColor,
        domainFn: (_, __) => '0',
        measureFn: (double v, _) => v,
        data: [value],
      );
    }

    return SizedBox(
      height: 48,
      child: FutureBuilder(
        future: histogram,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Container();

          final counts = snapshot.data as List<int>?;
          if (counts == null ||
              counts.length != 4 ||
              counts.reduce((a, b) => a + b) < 10)
            return Center(
              child: Text(
                DiscyoLocalizations.of(context).label("not_enough_ratings"),
                style:
                    Theme.of(context).textTheme.caption!.copyWith(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            );

          final countsMaximum = counts.reduce(max);
          final data = List<double>.generate(
              4, (i) => max(counts[i].toDouble(), countsMaximum / 48));
          return charts.BarChart(
            [
              _buildBar(data[0], mediaState == MediaState.awful),
              _buildBar(data[1], mediaState == MediaState.meh),
              _buildBar(data[2], mediaState == MediaState.good),
              _buildBar(data[3], mediaState == MediaState.awesome),
            ],
            animate: false,
            primaryMeasureAxis: charts.NumericAxisSpec(
              renderSpec: charts.NoneRenderSpec(),
              tickProviderSpec: charts.StaticNumericTickProviderSpec(
                [charts.TickSpec(0), charts.TickSpec(countsMaximum)],
              ),
            ),
            domainAxis:
                charts.OrdinalAxisSpec(renderSpec: charts.NoneRenderSpec()),
            layoutConfig: charts.LayoutConfig(
              leftMarginSpec: charts.MarginSpec.fixedPixel(8),
              topMarginSpec: charts.MarginSpec.fixedPixel(8),
              rightMarginSpec: charts.MarginSpec.fixedPixel(8),
              bottomMarginSpec: charts.MarginSpec.fixedPixel(8),
            ),
          );
        },
      ),
    );
  }
}

class _DetailsBody extends StatelessWidget {
  const _DetailsBody({
    required this.medium,
    Key? key,
  }) : super(key: key);

  final Medium medium;

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(builder: (context, user, child) {
      // Description
      List<Widget> widgets = [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            medium.description,
            style: Theme.of(context).textTheme.bodyText2,
          ),
        ),
      ];

      // Crew list
      if (!(medium is Film) && !(medium is Show))
        return Column(children: widgets);
      widgets.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: _DetailsCreatorList(medium: medium),
      ));

      final sources = medium.sources
          .where((e) => e.country == user.country)
          .toList(growable: false);
      if (sources.isNotEmpty) {
        widgets.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: _DetailsSources(sources: sources),
        ));
      }

      // Similar media list
      if (medium is Film && (medium as Film).similar.length < 1)
        return Column(children: widgets);
      if (medium is Show && (medium as Show).similar.length < 1)
        return Column(children: widgets);
      widgets.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: _DetailsSimilarList(medium: medium, user: user),
      ));

      return Column(children: widgets);
    });
  }
}

class _DetailsCreatorList extends StatelessWidget {
  const _DetailsCreatorList({
    required this.medium,
    Key? key,
  }) : super(key: key);

  final Medium medium;

  Widget _buildItem(BuildContext context, Creator c) {
    final ip = c.profilePath != null
        ? CachedNetworkImageProvider(c.profilePath!)
        : AssetImage("assets/other/missing_profile.png");
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: SizedBox(
        width: 80,
        height: 100,
        child: Column(
          children: <Widget>[
            SizedBox(
              child: ClipOval(
                child: Image(image: ip as ImageProvider, fit: BoxFit.cover),
              ),
              width: 60,
              height: 60,
            ),
            Padding(padding: const EdgeInsets.symmetric(vertical: 4)),
            Text(
              c.name,
              style: Theme.of(context).textTheme.bodyText2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localized = DiscyoLocalizations.of(context);
    List<Widget> creators = [], cast = [];
    if (medium is Film) {
      creators = (medium as Film)
          .crew
          .where((c) => c.job == "Director")
          .map((c) => _buildItem(context, c))
          .toList();
      cast = (medium as Film)
          .cast
          .sublist(0, min(10, (medium as Film).cast.length))
          .map((c) => _buildItem(context, c))
          .toList();
    }
    if (medium is Show) {
      creators =
          (medium as Show).creators.map((c) => _buildItem(context, c)).toList();
      cast = (medium as Show)
          .cast
          .sublist(0, min(10, (medium as Show).cast.length))
          .map((c) => _buildItem(context, c))
          .toList();
    }
    if (creators.isEmpty && cast.isEmpty) return Container();

    List<Widget> widgets = [];
    if (creators.isNotEmpty) {
      widgets.add(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              medium is Film
                  ? localized.label("director")
                  : localized.label("created_by"),
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ),
          Row(children: creators)
        ],
      ));
    }
    if (widgets.isNotEmpty && cast.isNotEmpty) {
      widgets.add(
          VerticalDivider(thickness: 1, color: Theme.of(context).accentColor));
    }
    if (cast.isNotEmpty) {
      widgets.add(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              localized.label("cast"),
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ),
          Row(children: cast)
        ],
      ));
    }
    widgets.add(TextButton(
      onPressed: () =>
          Navigator.pushNamed(context, "/creators", arguments: medium),
      child: Text(localized.label("show_more"),
          style: Theme.of(context).textTheme.subtitle2),
    ));

    return Column(
      children: <Widget>[
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 125),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            children: widgets,
          ),
        ),
      ],
    );
  }
}

class _DetailsSimilarList extends StatefulWidget {
  const _DetailsSimilarList({
    required this.medium,
    required this.user,
    Key? key,
  }) : super(key: key);

  final Medium medium;
  final UserModel user;

  @override
  _DetailsSimilarListState createState() => _DetailsSimilarListState();
}

class _DetailsSimilarListState extends State<_DetailsSimilarList> {
  bool _loadingDetail = false;

  void _openItem(BuildContext context, int i) async {
    if (_loadingDetail) return;
    _loadingDetail = true;
    ApiResponse? response;
    if (widget.medium is Film)
      response =
          await WapitchApi.getMovieId((widget.medium as Film).similar[i].id);
    if (widget.medium is Show)
      response =
          await WapitchApi.getShowId((widget.medium as Show).similar[i].id);
    if ((response?.code ?? 0) != 200 || response?.body["id"] == null) {
      showMessage(context, DiscyoLocalizations.of(context).label("not_in_db"));
      return;
    }
    if (widget.medium is Film)
      Navigator.pushNamed(
        context,
        "/details",
        arguments: await Film.fetch(
          response!.body["id"],
          (widget.medium as Film).similar[i].id,
          language: widget.user.language,
          state: await widget.user.getMediaState(response.body["id"]),
        ),
      ).then((_) {
        _loadingDetail = false;
      });
    if (widget.medium is Show)
      Navigator.pushNamed(
        context,
        "/details",
        arguments: await Show.fetch(
          response!.body["id"],
          (widget.medium as Show).similar[i].id,
          language: widget.user.language,
          state: await widget.user.getMediaState(response.body["id"]),
        ),
      ).then((_) {
        _loadingDetail = false;
      });
  }

  Widget _buildItem(BuildContext context, int i) {
    ImageProvider ip = AssetImage("assets/other/missing_image.png");
    if (widget.medium is Film &&
        (widget.medium as Film).similar[i].posterPath != null)
      ip = CachedNetworkImageProvider(
          (widget.medium as Film).similar[i].posterPath!);
    if (widget.medium is Show &&
        (widget.medium as Show).similar[i].posterPath != null)
      ip = CachedNetworkImageProvider(
          (widget.medium as Show).similar[i].posterPath!);
    return Padding(
      padding: EdgeInsets.only(left: i == 0 ? 0 : 8),
      child: TextButton(
        child: SizedBox(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image(image: ip, fit: BoxFit.cover),
          ),
          width: 120,
          height: 180,
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.all(0),
        ),
        onPressed: () => _openItem(context, i),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 24),
            child: Text(
              DiscyoLocalizations.of(context)
                  .label("fans_also_like")
                  .toUpperCase(),
              style: Theme.of(context).textTheme.caption,
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 180),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, i) => _buildItem(context, i),
            itemCount: widget.medium is Film
                ? (widget.medium as Film).similar.length
                : (widget.medium as Show).similar.length,
          ),
        ),
      ],
    );
  }
}

class _DetailsSources extends StatelessWidget {
  const _DetailsSources({
    required this.sources,
    Key? key,
  })  : assert(sources.length != 0),
        super(key: key);

  final List<MediaSource> sources;

  Widget _buildSource(BuildContext context, int i) {
    return Padding(
      padding: EdgeInsets.only(left: i == 0 ? 0 : 8),
      child: SizedBox(
        child: TextButton(
          child: Image(image: sources[i].platform.logo, fit: BoxFit.cover),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.all(0),
          ),
          onPressed: () => openLink(sources[i].url, context),
        ),
        width: 50,
        height: 50,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 24),
            child: Text(
              DiscyoLocalizations.of(context).label("watch_on").toUpperCase(),
              style: Theme.of(context).textTheme.caption,
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 50),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, i) => _buildSource(context, i),
            itemCount: sources.length,
          ),
        ),
      ],
    );
  }
}

class _DetailsFooter extends StatelessWidget {
  const _DetailsFooter({
    required this.medium,
    Key? key,
  }) : super(key: key);

  final Medium medium;

  Widget _buildTMDBLink(BuildContext context) {
    String tmdbLink = "https://www.themoviedb.org/";
    if (medium is Film)
      tmdbLink += "movie/${(medium as Film).tmdb}";
    else
      tmdbLink += "tv/${(medium as Show).tmdb}";
    return SizedBox(
      height: 14,
      child: TextButton(
        child: Image.asset("assets/other/tmdb.png"),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.only(top: 3),
        ),
        onPressed: () => openLink(tmdbLink, context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!(medium is Film || medium is Show)) return Container();
    final localized = DiscyoLocalizations.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(localized.label("info_credit"),
            style: Theme.of(context).textTheme.caption),
        _buildTMDBLink(context),
      ],
    );
  }
}

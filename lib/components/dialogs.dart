import 'package:flutter/material.dart';
import 'package:discyo/localizations/localizations.dart';
import 'package:discyo/models/user.dart';

Future showProgress(BuildContext context, Future future, String message) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      future.then((_) => Navigator.of(context).pop());
      return Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 8)),
              Text(
                message,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.normal),
              ),
            ],
          ),
        ),
      );
    },
  );
  return future;
}

void showMessage(BuildContext context, String message,
    {SnackBarAction? action, Color? color}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: TextStyle(color: color ?? Theme.of(context).accentColor),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
      action: action,
    ),
  );
}

void showActionMessage(BuildContext context, String message, String actionLabel,
    Function actionCallback) {
  showMessage(
    context,
    message,
    action: SnackBarAction(
      label: actionLabel,
      textColor: Theme.of(context).accentColor,
      onPressed: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        actionCallback();
      },
    ),
  );
}

void showError(BuildContext context, String error) {
  showMessage(context, error, color: Theme.of(context).errorColor);
}

void showInfoDialog(BuildContext context, String title, String description) {
  showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(
        title,
        style: Theme.of(context).textTheme.headline6,
      ),
      titlePadding: EdgeInsets.fromLTRB(20, 20, 20, 8),
      content: Text(
        description,
        style: Theme.of(context).textTheme.bodyText1,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      actions: [
        TextButton(
          child: Text(
            DiscyoLocalizations.of(context).label("ok"),
            style: Theme.of(context).textTheme.subtitle2,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}

void showDocument(BuildContext context, String key) {
  final localized = DiscyoLocalizations.of(context);
  showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(
        localized.label(key),
        style: Theme.of(context).textTheme.headline6,
      ),
      titlePadding: EdgeInsets.fromLTRB(20, 20, 20, 8),
      content: SingleChildScrollView(
        child: localized.document(key),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      actions: [
        TextButton(
          child: Text(
            localized.label("ok"),
            style: Theme.of(context).textTheme.subtitle2,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}

void showReportProblemForm(BuildContext context, UserModel user) {
  final localized = DiscyoLocalizations.of(context);
  var controller = TextEditingController();
  showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(
        localized.label("report_problem_title"),
        style: Theme.of(context).textTheme.headline6,
      ),
      titlePadding: EdgeInsets.fromLTRB(20, 20, 20, 8),
      content: SingleChildScrollView(
        child: _FeedbackForm(
          controller: controller,
          placeholder: localized.label("report_problem_placeholder"),
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      actions: [
        TextButton(
          child: Text(
            localized.label("cancel"),
            style: Theme.of(context).textTheme.subtitle2,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text(
            localized.label("send"),
            style: Theme.of(context).textTheme.subtitle2,
          ),
          onPressed: () {
            user.reportProblem(controller.text);
            Navigator.of(context).pop();
            showMessage(context, localized.label("thanks_for_feedback"));
          },
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}

void showFeedbackForm(BuildContext context, UserModel user) {
  final localized = DiscyoLocalizations.of(context);
  var rating = 0;
  var controller = TextEditingController();
  showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(
        localized.label("feedback_title"),
        style: Theme.of(context).textTheme.headline6,
      ),
      titlePadding: EdgeInsets.fromLTRB(20, 20, 20, 8),
      content: SingleChildScrollView(
        child: _FeedbackForm(
          rate: (val) => rating = val,
          controller: controller,
          placeholder: localized.label("feedback_placeholder"),
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      actions: [
        TextButton(
          child: Text(
            localized.label("cancel"),
            style: Theme.of(context).textTheme.subtitle2,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text(
            localized.label("send"),
            style: Theme.of(context).textTheme.subtitle2,
          ),
          onPressed: () {
            user.sendFeedback(rating, controller.text);
            Navigator.of(context).pop();
            showMessage(context, localized.label("thanks_for_feedback"));
          },
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}

class _FeedbackForm extends StatefulWidget {
  const _FeedbackForm({
    Key? key,
    this.rate,
    required this.controller,
    required this.placeholder,
  }) : super(key: key);

  final Function(int)? rate;
  final TextEditingController controller;
  final String placeholder;

  @override
  _FeedbackFormState createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<_FeedbackForm> {
  int _rating = 0;

  Widget buildRating(BuildContext context) {
    if (widget.rate == null) return Container();
    return Row(
      children: List<Widget>.generate(5, (i) {
        return IconButton(
          onPressed: () => setState(() {
            _rating = i + 1;
            widget.rate!(i + 1);
          }),
          icon: Icon(
            Icons.star,
            color: _rating > i
                ? Theme.of(context).accentColor
                : Theme.of(context).primaryColorLight,
          ),
          padding: const EdgeInsets.all(4),
          constraints: BoxConstraints.tight(Size(30, 30)),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        buildRating(context),
        TextField(
          controller: widget.controller,
          decoration: InputDecoration(labelText: widget.placeholder),
          keyboardType: TextInputType.multiline,
          maxLines: null,
        ),
      ],
    );
  }
}

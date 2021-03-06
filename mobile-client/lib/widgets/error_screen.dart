import 'package:flutter/material.dart';
import 'package:mutube/services/services.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final errorTextWidget = (text) => Text(
          text,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .caption
              .merge(TextStyle(fontSize: 20)),
        );
    final localizations = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error,
            color: Theme.of(context).textTheme.caption.color,
            size: 100,
          ),
          SizedBox(height: 15),
          errorTextWidget(localizations.errorOccurred),
          SizedBox(height: 15),
          errorTextWidget(localizations.restartApp),
        ],
      ),
    );
  }
}

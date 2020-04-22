import 'package:flutter/material.dart';
import 'package:mutube/models/models.dart';
import 'package:mutube/services/services.dart';
import 'package:mutube/widgets/widgets.dart';
import 'package:provider/provider.dart';

class LoginFlow extends StatelessWidget {
  final Widget child;

  LoginFlow({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    return StreamBuilder<GoogleMusicCredentials>(
      stream: auth.credentials,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final credentials = snapshot.data;

          if (credentials.mobileClient != null &&
              credentials.musicManager != null) {
            return Provider<GoogleMusicCredentials>.value(
              value: credentials,
              child: child,
            );
          } else {
            return _StepperFlow(
              config: Provider.of<AppConfig>(context),
              auth: auth,
              currentStep: credentials.mobileClient != null ? 1 : 0,
            );
          }
        } else if (snapshot.hasError) {
          return ErrorScreen();
        } else {
          return LoadingScreen();
        }
      },
    );
  }
}

class _StepperFlow extends StatelessWidget {
  final TextEditingController mobileClientCodeController =
      TextEditingController();
  final TextEditingController musicManagerCodeController =
      TextEditingController();

  final AppConfig config;
  final AuthService auth;
  final int currentStep;

  _StepperFlow({Key key, this.config, this.auth, this.currentStep})
      : super(key: key);

  Function(String) Function(BuildContext) _submitCode(
    GoogleMusicOAuthClient client,
    void Function(OAuth2Credentials) save,
  ) =>
      (context) => (code) async {
            try {
              final creds = await Provider.of<AuthService>(
                context,
                listen: false,
              ).getCredentials(client, code);
              save(creds.orElse(null));
            } catch (e) {}
          };
  Function(String) Function(BuildContext) get submitMobileClientCode =>
      _submitCode(config.googleMusicOAuth.mobileClient,
          auth.saveMobileClientCredentials);
  Function(String) Function(BuildContext) get submitMusicManagerCode =>
      _submitCode(config.googleMusicOAuth.musicManager,
          auth.saveMusicManagerCredentials);

  @override
  Widget build(BuildContext context) {
    final stepper = Stepper(
      currentStep: currentStep,
      onStepContinue: currentStep == 1
          ? () => submitMusicManagerCode(context)(
                musicManagerCodeController.text,
              )
          : () => submitMobileClientCode(context)(
                mobileClientCodeController.text,
              ),
      steps: <Step>[
        _LoginStep.mobileClient(
          context,
          textController: mobileClientCodeController,
          submitCode: submitMobileClientCode(context),
        ),
        _LoginStep.musicManager(
          context,
          textController: musicManagerCodeController,
          submitCode: submitMusicManagerCode(context),
        ),
      ],
    );

    return stepper;
  }
}

class _LoginStep {
  static Step _stepForParams(
    BuildContext context, {
    GoogleMusicOAuthClient client,
    String title,
    String subtitle,
    String buttonLabel,
    String hintText,
    TextEditingController textController,
    void Function(String) submitCode,
  }) =>
      Step(
        title: Text(title),
        subtitle: SizedBox(
          width: MediaQuery.of(context).size.width - 84,
          child: Text(subtitle),
        ),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RaisedButton(
              onPressed: () => Provider.of<AuthService>(context, listen: false)
                  .obtainAccessCode(client),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(buttonLabel),
                  SizedBox(width: 10),
                  Icon(Icons.launch)
                ],
              ),
            ),
            TextField(
              controller: textController,
              onSubmitted: submitCode,
              decoration: InputDecoration(hintText: hintText),
            ),
          ],
        ),
      );

  static Step mobileClient(
    BuildContext context, {
    TextEditingController textController,
    void Function(String) submitCode,
  }) {
    final localizations = AppLocalizations.of(context);
    return _stepForParams(
      context,
      client: Provider.of<AppConfig>(context).googleMusicOAuth.mobileClient,
      title: localizations.mobileClientLoginStepTitle,
      subtitle: localizations.mobileClientLoginStepSubtitle,
      buttonLabel: localizations.mobileClientLoginStepButtonLabel,
      hintText: localizations.mobileClientLoginStepHintText,
      textController: textController,
      submitCode: submitCode,
    );
  }

  static Step musicManager(
    BuildContext context, {
    TextEditingController textController,
    void Function(String) submitCode,
  }) {
    final localizations = AppLocalizations.of(context);
    return _stepForParams(
      context,
      client: Provider.of<AppConfig>(context).googleMusicOAuth.musicManager,
      title: localizations.musicManagerLoginStepTitle,
      subtitle: localizations.musicManagerLoginStepSubtitle,
      buttonLabel: localizations.musicManagerLoginStepButtonLabel,
      hintText: localizations.musicManagerLoginStepHintText,
      textController: textController,
      submitCode: submitCode,
    );
  }
}

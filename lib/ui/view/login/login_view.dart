import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/app-routes.dart';
import 'package:guide7/connect/login/zpa/response/zpa_login_response.dart';
import 'package:guide7/connect/repository.dart';
import 'package:guide7/main.dart';
import 'package:guide7/model/credentials/username_password_credentials.dart';
import 'package:guide7/ui/common/headline.dart';
import 'package:guide7/ui/view/base_view.dart';
import 'package:guide7/ui/view/login/form/login_form.dart';

/// View showing the login dialog.
class LoginView extends StatefulWidget implements BaseView {
  @override
  State<StatefulWidget> createState() => _LoginViewState();
}

/// State of the login view.
class _LoginViewState extends State<LoginView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _buildHeader(),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 25.0, horizontal: 40.0),
                      child: LoginForm(
                        onLoginAttempt: _onLoginAttempt,
                        onSuccess: _onLoginSuccess,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the login header.
  Widget _buildHeader() => Padding(
        padding: EdgeInsets.only(top: 50.0, left: 25.0, right: 25.0, bottom: 25.0),
        child: Column(
          children: <Widget>[
            Headline("Anmeldung"),
            Padding(
              padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
              child: Text(
                "Gib deine ZPA Anmeldedaten an um dich anzumelden.",
                style: TextStyle(fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ),
            Divider(),
          ],
        ),
      );

  /// Attempt a login with the provided [username] and [password].
  Future<bool> _onLoginAttempt(String username, String password) async {
    Repository repo = Repository();

    UsernamePasswordCredentials credentials = UsernamePasswordCredentials(username: username, password: password);

    ZPALoginResponse response = await repo.getZPALoginRepository().tryLogin(credentials);

    bool success = response != null;

    if (success) {
      await repo.getLocalCredentialsRepository().storeLocalCredentials(credentials);
    }

    return success;
  }

  /// What to do when the login succeeded.
  void _onLoginSuccess() {
    App.router.navigateTo(context, AppRoutes.notice_board, transition: TransitionType.inFromBottom, replace: true);
  }
}

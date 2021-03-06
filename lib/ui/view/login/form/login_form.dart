import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/localization/app_localizations.dart';
import 'package:guide7/util/custom_colors.dart';
import 'package:guide7/util/functional_interfaces.dart';

/// The login form provides text fields for entering the login data.
class LoginForm extends StatefulWidget {
  /// Callback to check whether the provided username and password are correct.
  final BiFunc<Future<bool>, String, String> onLoginAttempt;

  /// Callback deciding on what to do in case the form finished.
  final Runnable onSuccess;

  /// Create login form.
  LoginForm({
    @required this.onLoginAttempt,
    @required this.onSuccess,
  });

  @override
  State<StatefulWidget> createState() => _LoginFormState();
}

/// State of the login form.
class _LoginFormState extends State<LoginForm> {
  /// Background color of the input field.
  static const Color _inputFieldBackground = Color.fromRGBO(240, 240, 240, 1.0);

  /// Key of this form used to validate the form later.
  final _formKey = GlobalKey<FormState>();

  /// Controller managing username text field contents.
  final TextEditingController _usernameController = TextEditingController();

  /// Controller managing password text field contents.
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(key: _formKey, child: Column(children: _buildFormContents()));
  }

  /// Build contents of the form (input fields, buttons, ...).
  List<Widget> _buildFormContents() => <Widget>[
        _wrapTextField(
          child: TextFormField(
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).username,
              icon: Icon(
                Icons.person,
                color: CustomColors.slateGrey,
              ),
              border: InputBorder.none,
            ),
            style: TextStyle(fontFamily: "Roboto", color: Colors.black87, fontSize: 16.0),
            validator: (value) => value.isEmpty ? AppLocalizations.of(context).usernameError : null,
            controller: _usernameController,
          ),
        ),
        _wrapTextField(
          child: TextFormField(
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).password,
              icon: Icon(
                Icons.lock,
                color: CustomColors.slateGrey,
              ),
              border: InputBorder.none,
            ),
            style: TextStyle(fontFamily: "Roboto", color: Colors.black87, fontSize: 16.0),
            validator: (value) => value.isEmpty ? AppLocalizations.of(context).passwordError : null,
            obscureText: true,
            controller: _passwordController,
          ),
        ),
        _buildSubmitButton(),
      ];

  /// Wrap text field in a container applying some styles.
  Widget _wrapTextField({@required Widget child}) => Container(
        decoration: BoxDecoration(color: _inputFieldBackground, borderRadius: BorderRadius.circular(10.0)),
        padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        margin: EdgeInsets.only(bottom: 10.0),
        child: child,
      );

  /// Build button for submitting form data.
  Widget _buildSubmitButton() => Center(
        child: RaisedButton.icon(
          onPressed: () => _submitForm(),
          icon: Icon(Icons.keyboard_arrow_right),
          label: Text(
            AppLocalizations.of(context).doLogin,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100000.0)),
          textColor: Colors.white,
          color: CustomColors.slateGrey,
        ),
      );

  /// Submit the form and validate input fields.
  void _submitForm() async {
    if (_formKey.currentState.validate()) {
      String username = _usernameController.text;
      String password = _passwordController.text;

      // Show a snack bar until the credentials have been checked.
      var snackBarController = Scaffold.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).checkLogin)));

      bool success = await widget.onLoginAttempt(username, password);

      // Close snack bar.
      snackBarController.close();

      if (success) {
        widget.onSuccess();
      } else {
        Scaffold.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).loginFailed)));
      }
    }
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:roblo_firebase/consts.dart';
import 'package:roblo_firebase/services/alert_service.dart';
import 'package:roblo_firebase/services/auth_service.dart';
import 'package:roblo_firebase/services/navigation_service.dart';
import 'package:roblo_firebase/widgets/custom_form_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GetIt _getIt = GetIt.instance;

  final GlobalKey<FormState> _loginFormKey = GlobalKey();

  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;

  String? email, password;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
        child: Column(
          children: [
            _headerText(),
            _loginForm(),
            _createAccountLink(),
          ],
        ),
      ),
    );
  }

  Widget _headerText() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: const Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hi, Welcome Back",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black),
          ),
          Text(
            "Hello again, you've been missed",
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w500, color: Colors.grey),
          )
        ],
      ),
    );
  }

  Widget _loginForm() {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.40,
      margin: EdgeInsets.symmetric(
          vertical: MediaQuery.sizeOf(context).height * 0.05),
      child: Form(
        key: _loginFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomFormField(
              hintText: "Email",
              height: MediaQuery.sizeOf(context).height * 0.1,
              validationRegExp: EMAIL_VALIDATION_REGEX,
              onSaved: (value) {
                email = value;
              },
            ),
            CustomFormField(
              hintText: "Password",
              height: MediaQuery.sizeOf(context).height * 0.1,
              validationRegExp: PASSWORD_VALIDATION_REGEX,
              obscureText: true,
              onSaved: (value) {
                password = value;
              },
            ),
            _loginButton(),
          ],
        ),
      ),
    );
  }

  Widget _loginButton() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: TextButton(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.all(15),
          backgroundColor: Colors.amber[400],
          foregroundColor: Colors.amber[600],
          elevation: 4,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
        ),
        onPressed: () async {
          if (_loginFormKey.currentState?.validate() ?? false) {
            _loginFormKey.currentState?.save();
            bool result = await _authService.login(email!, password!);

            if (result) {
              _alertService.showToast(
                text: "Login Successfull",
                color: Colors.greenAccent,
                icon: Icons.check,
              );
              _navigationService.pushReplaceMentNamed('/home');
            } else {
              _alertService.showToast(
                text: "Failed to login,please try again!",
                color: Colors.redAccent,
                icon: Icons.error,
              );
            }
          }
        },
        child: const Text(
          'Login',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _createAccountLink() {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text("Dont have an Account "),
          GestureDetector(
            onTap: () {
              _navigationService.pushNamed("/register");
            },
            child: const Text(
              " Sign Up",
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          )
        ],
      ),
    );
  }
}

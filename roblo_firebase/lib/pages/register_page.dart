import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:roblo_firebase/consts.dart';
import 'package:roblo_firebase/models/user_profile.dart';
import 'package:roblo_firebase/services/alert_service.dart';
import 'package:roblo_firebase/services/auth_service.dart';
import 'package:roblo_firebase/services/database_service.dart';
import 'package:roblo_firebase/services/media_service.dart';
import 'package:roblo_firebase/services/navigation_service.dart';
import 'package:roblo_firebase/services/storage_service.dart';
import 'package:roblo_firebase/widgets/custom_form_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _regsiterFormKey = GlobalKey();
  final GetIt _getIt = GetIt.instance;

  late MediaService _mediaService;
  late NavigationService _navigationService;
  late AuthService _authService;
  late AlertService _alertService;
  late StorageService _storageService;
  late DatabaseService _databaseService;

  File? selectedImage;
  String? email, password, mobileNo, name;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _mediaService = _getIt.get<MediaService>();
    _navigationService = _getIt.get<NavigationService>();
    _authService = _getIt.get<AuthService>();
    _alertService = _getIt.get<AlertService>();
    _storageService = _getIt.get<StorageService>();
    _databaseService = _getIt.get<DatabaseService>();
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
        padding: const EdgeInsets.symmetric(
          horizontal: 15.0,
          vertical: 20.0,
        ),
        child: Column(
          children: [
            _headerText(),
            if (!isLoading) _registerForm(),
            if (!isLoading) _loginAccountLink(),
            if (isLoading)
              Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.amber[400],
                  ),
                ),
              )
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
            "Let's, get going!",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black),
          ),
          Text(
            "Register your account using the form below",
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w500, color: Colors.grey),
          )
        ],
      ),
    );
  }

  Widget _registerForm() {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.70,
      margin: EdgeInsets.symmetric(
        vertical: MediaQuery.sizeOf(context).height * 0.05,
      ),
      child: Form(
        key: _regsiterFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _pfpSelectionField(),
            CustomFormField(
              hintText: "Full Name",
              height: MediaQuery.sizeOf(context).height * 0.1,
              validationRegExp: FULL_NAME_VALIDATION_REGEX,
              onSaved: (value) {
                setState(
                  () {
                    name = value;
                  },
                );
              },
            ),
            CustomFormField(
              hintText: "Email",
              height: MediaQuery.sizeOf(context).height * 0.1,
              validationRegExp: EMAIL_VALIDATION_REGEX,
              onSaved: (value) {
                setState(
                  () {
                    email = value;
                  },
                );
              },
            ),
            CustomFormField(
              hintText: "Mobile number",
              height: MediaQuery.sizeOf(context).height * 0.1,
              validationRegExp: MOBILE_VALIDATION_REGEX,
              onSaved: (value) {
                setState(
                  () {
                    mobileNo = value;
                  },
                );
              },
            ),
            CustomFormField(
              obscureText: true,
              hintText: "Password",
              height: MediaQuery.sizeOf(context).height * 0.1,
              validationRegExp: PASSWORD_VALIDATION_REGEX,
              onSaved: (value) {
                setState(
                  () {
                    password = value;
                  },
                );
              },
            ),
            _registerButton(),
          ],
        ),
      ),
    );
  }

  Widget _pfpSelectionField() {
    // picture selection box
    return GestureDetector(
      onTap: () async {
        File? file = await _mediaService.getImageFromGallery();
        if (file != null) {
          setState(() {
            selectedImage = file;
          });
        }
      },
      child: CircleAvatar(
        radius: MediaQuery.sizeOf(context).width * 0.15,
        backgroundColor: Colors.amber[400],
        backgroundImage: selectedImage != null
            ? FileImage(selectedImage!)
            : NetworkImage(PLACEHOLDER_PFP) as ImageProvider,
      ),
    );
  }

  Widget _registerButton() {
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
          setState(() {
            isLoading = true;
          });
          try {
            if (selectedImage == null) {
              _alertService.showToast(
                text: "Please select a valid profile image!",
                color: Colors.redAccent,
                icon: Icons.warning,
              );
              return;
            }
            if ((_regsiterFormKey.currentState?.validate() ?? false) &&
                selectedImage != null) {
              _regsiterFormKey.currentState?.save();
              bool result = await _authService.signup(email!, password!);
              if (result) {
                String? pfpURL = await _storageService.uploadUserPfp(
                  file: selectedImage!,
                  uid: _authService.user!.uid,
                );

                if (pfpURL != null) {
                  await _databaseService.createUserProfile(
                    userProfile: UserProfile(
                        uid: _authService.user!.uid,
                        name: name,
                        pfpURL: pfpURL,
                        mobileNo: mobileNo),
                  );
                  _alertService.showToast(
                    text:
                        "User registered successfully!, Reloading to dashboard",
                    color: Colors.greenAccent,
                    icon: Icons.check,
                  );
                  _navigationService.goback();
                  _navigationService.pushReplaceMentNamed("/home");
                } else {
                  throw Exception("Unable to register user");
                }
              } else {
                throw Exception("Unable to register user");
              }
            }
          } catch (e) {
            _alertService.showToast(
              text: "Failed to register your account, $e",
              color: Colors.redAccent,
              icon: Icons.warning,
            );
          } finally {
            setState(() {
              isLoading = false;
            });
          }
        },
        child: const Text(
          'Register',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _loginAccountLink() {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text("Already have an account? "),
          GestureDetector(
            onTap: () {
              _navigationService.goback();
            },
            child: const Text(
              " Login",
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          )
        ],
      ),
    );
  }
}

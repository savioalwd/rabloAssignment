import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:roblo_firebase/consts.dart';
import 'package:roblo_firebase/models/user_profile.dart';
import 'package:roblo_firebase/services/alert_service.dart';
import 'package:roblo_firebase/services/auth_service.dart';
import 'package:roblo_firebase/services/database_service.dart';
import 'package:roblo_firebase/services/media_service.dart';
import 'package:roblo_firebase/services/storage_service.dart';
import 'package:roblo_firebase/widgets/custom_form_field.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GetIt _getIt = GetIt.instance;
  late DatabaseService _databaseService;
  late MediaService _mediaService;
  late StorageService _storageService;
  late AlertService _alertService;

  String? uid;
  String? email;
  String? name;
  String? mobileNo;
  String? pfpURL;
  File? selectedImage;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _databaseService = _getIt.get<DatabaseService>();
    _mediaService = _getIt.get<MediaService>();
    _storageService = _getIt.get<StorageService>();
    _alertService = _getIt.get<AlertService>();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    final authService = _getIt.get<AuthService>();
    uid = authService.user?.uid;
    if (uid != null) {
      final userProfileStream = _databaseService.getUserProfile();
      userProfileStream.listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final userProfile = snapshot.docs.map((doc) => doc.data()).firstWhere(
              (profile) => profile.uid == uid,
              orElse: () =>
                  UserProfile(uid: uid!, name: '', mobileNo: '', pfpURL: ''));
          setState(() {
            email = authService.user?.email;
            name = userProfile.name;
            mobileNo = userProfile.mobileNo;
            pfpURL = userProfile.pfpURL;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      });
    }
  }

  Future<void> _updateUserProfile() async {
    if (uid != null && name != null && mobileNo != null && pfpURL != null) {
      if (selectedImage != null) {
        pfpURL = await _storageService.uploadUserPfp(
          file: selectedImage!,
          uid: uid!,
        );
      }
      final userProfile = UserProfile(
        uid: uid!,
        name: name!,
        mobileNo: mobileNo!,
        pfpURL: pfpURL!,
      );
      await _databaseService.createUserProfile(userProfile: userProfile);
      _alertService.showToast(
        text: 'Profile updated successfully!',
        color: Colors.green,
        icon: Icons.check,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.amber[400],
        automaticallyImplyLeading: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        File? file = await _mediaService.getImageFromGallery();
                        if (file != null) {
                          setState(() {
                            selectedImage = file;
                          });
                        }
                      },
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: selectedImage != null
                            ? FileImage(selectedImage!)
                            : pfpURL != null
                                ? NetworkImage(pfpURL!)
                                : AssetImage(PLACEHOLDER_PFP),
                        child: selectedImage == null && pfpURL == null
                            ? Icon(
                                Icons.camera_alt,
                                color: Colors.grey[800],
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomFormField(
                      hintText: "Email",
                      height: 60.0,
                      validationRegExp: EMAIL_VALIDATION_REGEX,
                      onSaved: (value) {},
                      initialValue: email,
                      readOnly: true,
                    ),
                    CustomFormField(
                      hintText: "Full Name",
                      height: 60.0,
                      validationRegExp: FULL_NAME_VALIDATION_REGEX,
                      onSaved: (value) {
                        name = value;
                      },
                      initialValue: name,
                    ),
                    CustomFormField(
                      hintText: "Mobile Number",
                      height: 60.0,
                      validationRegExp: MOBILE_VALIDATION_REGEX,
                      onSaved: (value) {
                        mobileNo = value;
                      },
                      initialValue: mobileNo,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });
                        await _updateUserProfile();
                        setState(() {
                          isLoading = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[400],
                      ),
                      child: const Text('Update'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

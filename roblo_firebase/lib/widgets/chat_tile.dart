import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:roblo_firebase/models/user_profile.dart';

class ChatTile extends StatelessWidget {
  final UserProfile userProfile;
  final Function onTap;

  const ChatTile({
    super.key,
    required this.userProfile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => onTap(),
      dense: false,
      leading: Container(
        width: 75.0, // Adjust the width as needed
        height: 100.0, // Adjust the height as needed
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          shape: BoxShape.rectangle,
          image: DecorationImage(
            image: NetworkImage(userProfile.pfpURL!),
            fit: BoxFit.cover,
          ),
        ),
      ),
      title: Text(
        userProfile.name!,
        style: const TextStyle(
          fontSize: 18.0, // Increase the font size as needed
          fontWeight: FontWeight.w700, // Increase the font weight
        ),
      ),
      subtitle: Text(
        userProfile.mobileNo!,
        style: const TextStyle(
          fontSize: 14.0, // Increase the font size as needed
          fontWeight: FontWeight.w500, // Increase the font weight
        ),
      ),
    );
  }
}

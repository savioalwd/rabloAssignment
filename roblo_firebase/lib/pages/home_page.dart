import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:roblo_firebase/models/user_profile.dart';
import 'package:roblo_firebase/pages/chat_page.dart';
import 'package:roblo_firebase/services/alert_service.dart';
import 'package:roblo_firebase/services/auth_service.dart';
import 'package:roblo_firebase/services/database_service.dart';
import 'package:roblo_firebase/services/navigation_service.dart';
import 'package:roblo_firebase/widgets/chat_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GetIt _getIt = GetIt.instance;

  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;
  late DatabaseService _databaseService;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
    _databaseService = _getIt.get<DatabaseService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber[400],
        title: const Text(
          "Messages",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _navigationService.pushNamed("/profile");
            },
            color: Colors.black,
            icon: const Icon(Icons.settings),
          ),
          IconButton(
            onPressed: () async {
              bool result = await _authService.logout();
              if (result) {
                _alertService.showToast(
                  text: "Successfully logged out!",
                  color: Colors.greenAccent,
                  icon: Icons.check,
                );
                _navigationService.pushReplaceMentNamed("/login");
              }
            },
            color: Colors.black,
            icon: const Icon(Icons.logout_sharp),
          ),
        ],
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return StreamBuilder(
        stream: _databaseService.getUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            const Center(
              child: Text("Unable to load data!"),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            final users = snapshot.data!.docs;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                UserProfile user = users[index].data();
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5.0,
                  ),
                  child: ChatTile(
                    userProfile: user,
                    onTap: () async {
                      final chatExists = await _databaseService.checkChatExists(
                          _authService.user!.uid, user.uid!);
                      if (!chatExists) {
                        await _databaseService.createNewChat(
                          _authService.user!.uid,
                          user.uid!,
                        );
                      }
                      _navigationService.push(
                        MaterialPageRoute(
                          builder: (context) {
                            return ChatPage(
                              chatUser: user,
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
          return Center(
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.amber[400],
              ),
            ),
          );
        });
  }
}

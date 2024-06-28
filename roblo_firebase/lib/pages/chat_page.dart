import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:roblo_firebase/models/chat.dart';
import 'package:roblo_firebase/models/message.dart';
import 'package:roblo_firebase/models/user_profile.dart';
import 'package:roblo_firebase/services/alert_service.dart';
import 'package:roblo_firebase/services/auth_service.dart';
import 'package:roblo_firebase/services/database_service.dart';
import 'package:roblo_firebase/services/media_service.dart';
import 'package:roblo_firebase/services/storage_service.dart';
import 'package:roblo_firebase/utils.dart';

class ChatPage extends StatefulWidget {
  final UserProfile chatUser;

  const ChatPage({
    super.key,
    required this.chatUser,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final GetIt _getIt = GetIt.instance;

  late MediaService _mediaService;
  late AuthService _authService;
  late AlertService _alertService;
  late DatabaseService _databaseService;
  late StorageService _storageService;

  ChatUser? currentUser, otherUser;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();
    _mediaService = _getIt.get<MediaService>();
    _storageService = _getIt.get<StorageService>();
    _alertService = _getIt.get<AlertService>();

    currentUser = ChatUser(
      id: _authService.user!.uid,
      firstName: _authService.user!.displayName,
      profileImage: _authService.user!.photoURL,
    );
    otherUser = ChatUser(
      id: widget.chatUser.uid!,
      firstName: widget.chatUser.name,
      profileImage: widget.chatUser.pfpURL,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber[400],
        title: Text(
          widget.chatUser.name!,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return StreamBuilder(
      stream: _databaseService.getChatData(
        currentUser!.id,
        otherUser!.id,
      ),
      builder: (context, snapshot) {
        Chat? chat = snapshot.data?.data();
        List<ChatMessage> messages = [];
        if (chat != null && chat.messages != null) {
          messages = _generateChatMessageList(chat.messages!);
        }
        return DashChat(
          messageOptions: const MessageOptions(
            showOtherUsersAvatar: true,
            showCurrentUserAvatar: true,
            showTime: true,
          ),
          inputOptions: InputOptions(
              alwaysShowSend: true,
              sendButtonBuilder: (send) {
                return IconButton(
                  icon: const Icon(Icons.send, color: Colors.amber),
                  onPressed: send,
                );
              },
              trailing: [
                _mediaMessageButton(),
              ]),
          currentUser: currentUser!,
          onSend: (message) => _sendMessage(message),
          messages: messages,
        );
      },
    );
  }

  Future<void> _sendMessage(ChatMessage chatMessage) async {
    if (chatMessage.medias?.isNotEmpty ?? false) {
      if (chatMessage.medias!.first.type == MediaType.image) {
        Message message = Message(
          senderID: chatMessage.user.id,
          content: chatMessage.medias!.first.url,
          messageType: MessageType.image,
          sentAt: Timestamp.fromDate(
            chatMessage.createdAt,
          ),
        );
        await _databaseService.sendChatMessage(
            currentUser!.id, otherUser!.id, message);
      }
    } else {
      Message message = Message(
        senderID: currentUser!.id,
        content: chatMessage.text,
        messageType: MessageType.text,
        sentAt: Timestamp.fromDate(
          chatMessage.createdAt,
        ),
      );
      await _databaseService.sendChatMessage(
        currentUser!.id,
        otherUser!.id,
        message,
      );
    }
  }

  List<ChatMessage> _generateChatMessageList(List<Message> messages) {
    List<ChatMessage> chatMessages = messages.map((m) {
      if (m.messageType == MessageType.image) {
        return ChatMessage(
          user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
          createdAt: m.sentAt!.toDate(),
          medias: [
            ChatMedia(
              url: m.content!,
              fileName: '',
              type: MediaType.image,
            ),
          ],
        );
      } else {
        return ChatMessage(
          user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
          createdAt: m.sentAt!.toDate(),
          text: m.content!,
        );
      }
    }).toList();
    chatMessages.sort((a, b) {
      return b.createdAt.compareTo(a.createdAt);
    });
    return chatMessages;
  }

  Widget _mediaMessageButton() {
    return IconButton(
      onPressed: () async {
        File? file = await _mediaService.getImageFromGallery();
        if (file != null) {
          String chatID = generateChatID(
            uid1: currentUser!.id,
            uid2: otherUser!.id,
          );
          String? downloadURL = await _storageService.uploadImagetoChat(
              file: file, chatID: chatID);

          if (downloadURL != null) {
            ChatMessage chatMessage = ChatMessage(
                user: currentUser!,
                createdAt: DateTime.now(),
                medias: [
                  ChatMedia(
                    url: downloadURL,
                    fileName: "",
                    type: MediaType.image,
                  )
                ]);
            _sendMessage(chatMessage);
            _alertService.showToast(
              text: "Media send success",
              color: Colors.grey,
              icon: Icons.file_copy,
            );
          }
        }
      },
      icon: Icon(
        Icons.image,
        color: Colors.amber[400],
      ),
    );
  }
}

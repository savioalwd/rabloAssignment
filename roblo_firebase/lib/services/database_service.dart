import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:roblo_firebase/models/chat.dart';
import 'package:roblo_firebase/models/message.dart';
import 'package:roblo_firebase/models/user_profile.dart';
import 'package:roblo_firebase/services/auth_service.dart';
import 'package:roblo_firebase/utils.dart';

class DatabaseService {
  final FirebaseFirestore _firebaseFireStore = FirebaseFirestore.instance;
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;

  CollectionReference? _usersCollection;
  CollectionReference? _chatCollection;

  DatabaseService() {
    _setupCollectionReference();
    _authService = _getIt.get<AuthService>();
  }

  void _setupCollectionReference() {
    _usersCollection =
        _firebaseFireStore.collection('users').withConverter<UserProfile>(
              fromFirestore: (snapshot, _) =>
                  UserProfile.fromJson(snapshot.data()!),
              toFirestore: (userProfile, _) => userProfile.toJson(),
            );
    _chatCollection = _firebaseFireStore
        .collection("chats")
        .withConverter<Chat>(
            fromFirestore: (snapshots, _) => Chat.fromJson(snapshots.data()!),
            toFirestore: (chat, _) => chat.toJson());
  }

  Future<void> createUserProfile({required UserProfile userProfile}) async {
    await _usersCollection?.doc(userProfile.uid).set(userProfile);
  }

  Stream<QuerySnapshot<UserProfile>> getUserProfile() {
    return _usersCollection!
        .where("uid", isNotEqualTo: _authService.user!.uid)
        .snapshots() as Stream<QuerySnapshot<UserProfile>>;
  }

  Future<bool> checkChatExists(String uid1, String uid2) async {
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    final result = await _chatCollection?.doc(chatID).get();
    if (result != null) {
      return result.exists;
    }
    return false;
  }

  Future<void> createNewChat(String uid1, String uid2) async {
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    final docRef = _chatCollection!.doc(chatID);
    final chat = Chat(
      id: chatID,
      participants: [uid1, uid2],
      messages: [],
    );
    await docRef.set(chat);
  }

  Future<void> sendChatMessage(
      String uid1, String uid2, Message message) async {
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    final docRef = _chatCollection!.doc(chatID);

    await docRef.update({
      "messages": FieldValue.arrayUnion(
        [
          message.toJson(),
        ],
      ),
    });
  }

  Stream<DocumentSnapshot<Chat>> getChatData(String uid1, String uid2) {
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    return _chatCollection?.doc(chatID).snapshots()
        as Stream<DocumentSnapshot<Chat>>;
  }

  Future<bool> updateUserProfile(
      {required String uid, required UserProfile updatedProfile}) async {
    try {
      await _usersCollection?.doc(uid).update(updatedProfile.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }
}
